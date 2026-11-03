import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/utils/date_utils.dart';
import '../../subjects/data/subject_repository.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/task.dart';
import '../domain/remote_todo.dart';
import 'todo_api_service.dart';

/// Экранның күйі.
enum LoadState { loading, success, error, empty }

/// Серверлік деректердің күйі мен әрекеттері (Repository).
/// UI: state → Loading / Success / Error / Empty; busy → жолақ индикаторы.
class RemoteRepository extends ChangeNotifier {
  RemoteRepository({TodoApiService? api}) : _api = api ?? TodoApiService();

  static final RemoteRepository instance = RemoteRepository();

  final TodoApiService _api;

  LoadState _state = LoadState.loading;
  List<RemoteTodo> _items = [];
  String _error = '';
  bool _busy = false;

  LoadState get state => _state;
  List<RemoteTodo> get items => List.unmodifiable(_items);
  String get error => _error;
  bool get busy => _busy;

  // ---------------------------------------------------------------- GET
  Future<void> load() async {
    _state = LoadState.loading;
    _error = '';
    notifyListeners();
    try {
      _items = await _api.fetchAll();
      _state = _items.isEmpty ? LoadState.empty : LoadState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _state = LoadState.error;
    }
    notifyListeners();
  }

  /// Жазба операцияларына арналған ортақ орауыш:
  /// busy → әрекет → сәтті болса null, қате болса қате мәтінін қайтарады.
  Future<String?> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------- POST
  Future<String?> add(String title) => _run(() async {
        final created = await _api.create(title.trim());
        // JSONPlaceholder әрдайым id=201 қайтарады → бірегей болу үшін жергілікті id береміз
        final unique = _items.any((e) => e.id == created.id)
            ? created.copyWith(id: _nextLocalId())
            : created;
        _items = [unique, ..._items];
        _state = LoadState.success;
      });

  // ---------------------------------------------------------------- PUT
  Future<String?> rename(RemoteTodo todo, String title) => _run(() async {
        final saved = await _api.replace(todo.copyWith(title: title.trim()));
        _replace(todo.id, saved.copyWith(id: todo.id));
        await _syncLocal(todo.id, title: title.trim());
      });

  // -------------------------------------------------------------- PATCH
  Future<String?> toggle(RemoteTodo todo) => _run(() async {
        final saved = await _api.patch(todo.id, {'completed': !todo.completed});
        _replace(todo.id, saved.copyWith(id: todo.id));
        await _syncLocal(todo.id, isDone: !todo.completed);
      });

  // ------------------------------------------------------------- DELETE
  Future<String?> remove(RemoteTodo todo) => _run(() async {
        await _api.delete(todo.id);
        _items = _items.where((e) => e.id != todo.id).toList();
        if (_items.isEmpty) _state = LoadState.empty;
      });

  // ------------------------------------------------ сервер ↔ локал байланысы
  /// Серверлік жазбаны жергілікті Hive қорына көшіру.
  Future<String?> importToLocal(RemoteTodo todo) async {
    final local = TaskRepository.instance;
    if (local.byRemoteId(todo.id) != null) return AppStrings.alreadyImported;
    final subjects = SubjectRepository.instance.all;
    if (subjects.isEmpty) return AppStrings.noSubjects;
    final ok = await local.create(
      title: todo.title,
      subjectId: subjects.first.id,
      deadline: dateOnly(DateTime.now()).add(const Duration(days: 7)),
      isDone: todo.completed,
      remoteId: todo.id,
    );
    return ok ? null : AppStrings.saveError;
  }

  bool isImported(RemoteTodo todo) =>
      TaskRepository.instance.byRemoteId(todo.id) != null;

  /// Серверге жіберілмеген жергілікті тапсырмаларды POST арқылы жіберу.
  /// Сәтті жіберілген санын қайтарады; қате болса ApiException тастамайды, мәтін береді.
  Future<({int sent, String? error})> uploadLocal() async {
    final local = TaskRepository.instance;
    var sent = 0;
    _busy = true;
    notifyListeners();
    try {
      for (final Task t in local.notSynced) {
        final created = await _api.create(t.title, completed: t.isDone);
        final id = _items.any((e) => e.id == created.id)
            ? _nextLocalId()
            : created.id;
        await local.update(t.copyWith(remoteId: id));
        _items = [created.copyWith(id: id), ..._items];
        sent++;
      }
      if (sent > 0) _state = LoadState.success;
      return (sent: sent, error: null);
    } on ApiException catch (e) {
      return (sent: sent, error: e.message);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------- көмекшілер
  void _replace(int id, RemoteTodo updated) {
    _items = _items.map((e) => e.id == id ? updated : e).toList();
  }

  /// Сервердегі өзгеріс жергілікті тапсырмаға да түседі (егер ол көшірілген болса).
  Future<void> _syncLocal(int remoteId, {String? title, bool? isDone}) async {
    final local = TaskRepository.instance;
    final t = local.byRemoteId(remoteId);
    if (t == null) return;
    await local.update(t.copyWith(title: title, isDone: isDone));
  }

  int _nextLocalId() {
    var max = 1000;
    for (final e in _items) {
      if (e.id > max) max = e.id;
    }
    return max + 1;
  }
}
