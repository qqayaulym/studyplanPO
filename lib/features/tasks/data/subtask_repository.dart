import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/id_gen.dart';
import '../domain/subtask.dart';

/// Тапсырма қадамдары (Hive 'subtasks'). Task 1 — N SubTask.
class SubTaskRepository extends ChangeNotifier {
  SubTaskRepository._();

  static final SubTaskRepository instance = SubTaskRepository._();

  // ---- READ ----
  List<SubTask> forTask(String taskId) {
    final list = AppDatabase.subtasks.values
        .map((e) => SubTask.fromMap(e as Map))
        .where((s) => s.taskId == taskId)
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  // ---- CREATE ----
  Future<bool> add(String taskId, String title) async {
    final t = title.trim();
    if (t.isEmpty) return false;
    final s = SubTask(
        id: IdGen.next(), taskId: taskId, title: t, createdAt: DateTime.now());
    final ok =
        await AppDatabase.run(() => AppDatabase.subtasks.put(s.id, s.toMap()));
    if (ok) notifyListeners();
    return ok;
  }

  // ---- UPDATE ----
  Future<bool> toggle(SubTask s) async {
    final updated = s.copyWith(isDone: !s.isDone);
    final ok = await AppDatabase.run(
        () => AppDatabase.subtasks.put(s.id, updated.toMap()));
    if (ok) notifyListeners();
    return ok;
  }

  // ---- DELETE ----
  Future<bool> remove(String id) async {
    final ok = await AppDatabase.run(() => AppDatabase.subtasks.delete(id),
        message: AppStrings.deleteError);
    if (ok) notifyListeners();
    return ok;
  }

  /// Тапсырма өшірілгенде оның қадамдары да өшіріледі (cascade).
  Future<void> removeForTask(String taskId) async {
    final keys = AppDatabase.subtasks.values
        .map((e) => SubTask.fromMap(e as Map))
        .where((s) => s.taskId == taskId)
        .map((s) => s.id)
        .toList();
    await AppDatabase.subtasks.deleteAll(keys);
    notifyListeners();
  }
}
