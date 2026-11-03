import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/id_gen.dart';
import '../../auth/data/auth_service.dart';
import '../../subjects/data/subject_repository.dart';
import '../domain/task.dart';
import 'subtask_repository.dart';

/// Мәртебе бойынша сүзгі.
enum TaskStatus { all, active, done, overdue }

/// Сұрыптау параметрлері.
enum TaskSort { deadline, title, created }

/// Тапсырмалар қоймасы (Repository қабаты).
/// Экрандар Hive-пен тікелей жұмыс істемейді — тек осы класс арқылы.
/// Ағымдағы пайдаланушының тапсырмалары жадта (кэш) ұсталады, әр өзгеріс алдымен
/// дерекқорға жазылады, сәтті болса ғана кэш жаңарады.
class TaskRepository extends ChangeNotifier {
  TaskRepository._();

  static final TaskRepository instance = TaskRepository._();

  static const String _recentPrefix = 'recent_';

  List<Task> _tasks = [];
  String? _loadedFor;
  bool _loadedOnce = false;

  String? get _uid => AuthService.instance.currentUser?.id;

  /// Пайдаланушы ауысқанда (немесе қайта іске қосқанда) деректерді қораптан оқиды.
  void _sync() {
    final uid = _uid;
    if (_loadedOnce && uid == _loadedFor) return;
    _loadedOnce = true;
    _loadedFor = uid;
    if (uid == null) {
      _tasks = [];
      return;
    }
    try {
      _tasks = AppDatabase.tasks.values
          .map((e) => Task.fromMap(e as Map))
          .where((t) => t.userId == uid)
          .toList();
    } catch (e) {
      debugPrint('Read error: $e');
      _tasks = [];
    }
  }

  /// Кэшті мәжбүрлі түрде қайта оқу.
  void reload() {
    _loadedOnce = false;
    _sync();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------
  List<Task> get all {
    _sync();
    final list = List<Task>.from(_tasks);
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return list;
  }

  List<Task> get active => all.where((t) => !t.isDone).toList();
  List<Task> get completed => all.where((t) => t.isDone).toList();
  List<Task> get favorites => all.where((t) => t.isFavorite).toList();

  Task? byId(String id) {
    _sync();
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool isOverdue(Task t) =>
      !t.isDone && dateOnly(t.deadline).isBefore(dateOnly(DateTime.now()));

  /// ІЗДЕУ + СҮЗГІЛЕУ + СҰРЫПТАУ бір жерде.
  ///  - [text]: атауы, сипаттамасы немесе пән атауы бойынша іздеу;
  ///  - [subjectId], [status], [favoritesOnly]: сүзгілер;
  ///  - [sort], [ascending]: сұрыптау (мерзімі / атауы / қосылған күні).
  List<Task> query({
    String text = '',
    String? subjectId,
    TaskStatus status = TaskStatus.all,
    bool favoritesOnly = false,
    TaskSort sort = TaskSort.deadline,
    bool ascending = true,
  }) {
    _sync();
    final q = text.trim().toLowerCase();
    final result = _tasks.where((t) {
      if (subjectId != null && t.subjectId != subjectId) return false;
      if (favoritesOnly && !t.isFavorite) return false;
      switch (status) {
        case TaskStatus.all:
          break;
        case TaskStatus.active:
          if (t.isDone) return false;
          break;
        case TaskStatus.done:
          if (!t.isDone) return false;
          break;
        case TaskStatus.overdue:
          if (!isOverdue(t)) return false;
          break;
      }
      if (q.isEmpty) return true;
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          SubjectRepository.instance.nameOf(t.subjectId).toLowerCase().contains(q);
    }).toList();

    int Function(Task, Task) cmp;
    switch (sort) {
      case TaskSort.deadline:
        cmp = (a, b) => a.deadline.compareTo(b.deadline);
        break;
      case TaskSort.title:
        cmp = (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase());
        break;
      case TaskSort.created:
        cmp = (a, b) => a.createdAt.compareTo(b.createdAt);
        break;
    }
    result.sort((a, b) => ascending ? cmp(a, b) : cmp(b, a));
    return result;
  }

  /// Серверлік id бойынша жергілікті тапсырманы табу (сервер ↔ локал байланысы).
  Task? byRemoteId(int remoteId) {
    _sync();
    for (final t in _tasks) {
      if (t.remoteId == remoteId) return t;
    }
    return null;
  }

  /// Серверге әлі жіберілмеген жергілікті тапсырмалар.
  List<Task> get notSynced {
    _sync();
    return _tasks.where((t) => t.remoteId == null).toList();
  }

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------
  Future<bool> create({
    required String title,
    required String subjectId,
    required DateTime deadline,
    String description = '',
    String reminder = 'Еске салғышсыз',
    bool isDone = false,
    int? remoteId,
  }) async {
    final uid = _uid;
    if (uid == null) return false;
    _sync();
    final task = Task(
      id: IdGen.next(),
      userId: uid,
      subjectId: subjectId,
      title: title.trim(),
      description: description.trim(),
      deadline: dateOnly(deadline),
      reminder: reminder,
      isDone: isDone,
      remoteId: remoteId,
      createdAt: DateTime.now(),
    );
    final ok = await AppDatabase.run(
        () => AppDatabase.tasks.put(task.id, task.toMap()));
    if (!ok) return false;
    _tasks.add(task);
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------
  Future<bool> update(Task task) async {
    _sync();
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) return false;
    final ok = await AppDatabase.run(
        () => AppDatabase.tasks.put(task.id, task.toMap()));
    if (!ok) return false;
    _tasks[i] = task;
    notifyListeners();
    return true;
  }

  Future<bool> toggleDone(String id) async {
    final t = byId(id);
    if (t == null) return false;
    return update(t.copyWith(isDone: !t.isDone));
  }

  /// FAVORITES: таңдаулы белгісі дерекқорда сақталады.
  Future<bool> toggleFavorite(String id) async {
    final t = byId(id);
    if (t == null) return false;
    return update(t.copyWith(isFavorite: !t.isFavorite));
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------
  Future<bool> remove(String id) async {
    _sync();
    final ok = await AppDatabase.run(() async {
      await AppDatabase.tasks.delete(id);
      await SubTaskRepository.instance.removeForTask(id);
    }, message: AppStrings.deleteError);
    if (!ok) return false;
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Соңғы іздеулер (дерекқорда, әр пайдаланушыға бөлек)
  // ---------------------------------------------------------------------------
  List<String> get recentSearches {
    final uid = _uid;
    if (uid == null) return const [];
    final raw = AppDatabase.settings.get('$_recentPrefix$uid');
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  Future<void> addRecentSearch(String query) async {
    final uid = _uid;
    final q = query.trim();
    if (uid == null || q.isEmpty) return;
    final list = recentSearches.toList()..remove(q);
    list.insert(0, q);
    if (list.length > 5) list.removeLast();
    await AppDatabase.run(
        () => AppDatabase.settings.put('$_recentPrefix$uid', list));
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    final uid = _uid;
    if (uid == null) return;
    final list = recentSearches.toList()..remove(query);
    await AppDatabase.run(
        () => AppDatabase.settings.put('$_recentPrefix$uid', list));
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Статистика
  // ---------------------------------------------------------------------------
  int get total => all.length;
  int get doneCount {
    _sync();
    return _tasks.where((t) => t.isDone).length;
  }

  int get overdueCount {
    _sync();
    return _tasks.where(isOverdue).length;
  }

  /// 0..100
  int get progressPercent =>
      total == 0 ? 0 : ((doneCount / total) * 100).round();

  int totalBySubject(String subjectId) =>
      all.where((t) => t.subjectId == subjectId).length;
  int doneBySubject(String subjectId) {
    _sync();
    return _tasks.where((t) => t.subjectId == subjectId && t.isDone).length;
  }
}
