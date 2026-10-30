import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/id_gen.dart';
import '../../../core/utils/password_hasher.dart';
import '../domain/app_user.dart';

/// Аутентификация қызметі. Пайдаланушылар Hive 'users' қорапшасында,
/// ағымдағы сессия 'settings' қорапшасында (session_user_id) сақталады —
/// сондықтан қосымшаны қайта іске қосқанда жүйеден шықпайсыз.
class AuthService extends ChangeNotifier {
  AuthService._();

  static final AuthService instance = AuthService._();
  static const String _sessionKey = 'session_user_id';

  AppUser? _current;
  AppUser? get currentUser => _current;
  bool get isLoggedIn => _current != null;

  /// Іске қосылғанда сақталған сессияны қалпына келтіреді.
  void restoreSession() {
    final id = AppDatabase.settings.get(_sessionKey);
    final raw = id == null ? null : AppDatabase.users.get(id);
    _current = raw == null ? null : AppUser.fromMap(raw as Map);
    notifyListeners();
  }

  AppUser? _findByEmail(String key) {
    for (final raw in AppDatabase.users.values) {
      final u = AppUser.fromMap(raw as Map);
      if (u.email == key) return u;
    }
    return null;
  }

  /// Сәтті болса true. Дерекқор қатесі болса DbException тастайды.
  Future<bool> login(String email, String password) async {
    final key = email.trim().toLowerCase();
    final user = _findByEmail(key);
    if (user == null ||
        user.passwordHash != PasswordHasher.hash(key, password)) {
      return false;
    }
    await _startSession(user);
    return true;
  }

  /// false — егер email бұрын тіркелген болса.
  Future<bool> register(String name, String email, String password) async {
    final key = email.trim().toLowerCase();
    if (_findByEmail(key) != null) return false;
    final user = AppUser(
      id: IdGen.next(),
      name: name.trim(),
      email: key,
      passwordHash: PasswordHasher.hash(key, password),
      createdAt: DateTime.now(),
    );
    try {
      await AppDatabase.users.put(user.id, user.toMap());
    } catch (e) {
      throw const DbException(AppStrings.saveError);
    }
    await _startSession(user);
    return true;
  }

  Future<void> _startSession(AppUser user) async {
    try {
      await AppDatabase.settings.put(_sessionKey, user.id);
    } catch (e) {
      throw const DbException(AppStrings.saveError);
    }
    _current = user;
    notifyListeners();
  }

  Future<bool> updateName(String name) async {
    final c = _current;
    if (c == null) return false;
    final updated = c.copyWith(name: name.trim());
    final ok = await AppDatabase.run(
        () => AppDatabase.users.put(updated.id, updated.toMap()));
    if (!ok) return false;
    _current = updated;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await AppDatabase.run(() => AppDatabase.settings.delete(_sessionKey));
    _current = null;
    notifyListeners();
  }
}
