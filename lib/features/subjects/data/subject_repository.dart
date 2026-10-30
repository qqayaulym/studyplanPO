import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/subjects.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/id_gen.dart';
import '../domain/subject.dart';

/// Пәндер қоймасы (Hive 'subjects' қорапшасы). CRUD: add / all / rename / remove.
class SubjectRepository extends ChangeNotifier {
  SubjectRepository._();

  static final SubjectRepository instance = SubjectRepository._();

  // ---- READ ----
  List<Subject> get all {
    final list = AppDatabase.subjects.values
        .map((e) => Subject.fromMap(e as Map))
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Subject? byId(String id) {
    final raw = AppDatabase.subjects.get(id);
    return raw == null ? null : Subject.fromMap(raw as Map);
  }

  String nameOf(String id) => byId(id)?.name ?? AppStrings.noSubject;

  Subject? byName(String name) {
    for (final s in all) {
      if (s.name.toLowerCase() == name.trim().toLowerCase()) return s;
    }
    return null;
  }

  int taskCount(String subjectId) => AppDatabase.tasks.values
      .where((e) => (e as Map)['subjectId'] == subjectId)
      .length;

  // ---- CREATE ----
  /// Қате мәтінін қайтарады (null — сәтті).
  Future<String?> add(String name) async {
    final n = name.trim();
    if (n.isEmpty) return AppStrings.enterSubject;
    if (byName(n) != null) return AppStrings.subjectExists;
    final palette = AppSubjects.all;
    final p = palette[AppDatabase.subjects.length % palette.length];
    final subject = Subject(
      id: IdGen.next(),
      name: n,
      backgroundValue: p.background.value,
      foregroundValue: p.foreground.value,
      createdAt: DateTime.now(),
    );
    final ok = await AppDatabase.run(
        () => AppDatabase.subjects.put(subject.id, subject.toMap()));
    if (!ok) return AppStrings.saveError;
    notifyListeners();
    return null;
  }

  // ---- UPDATE ----
  Future<String?> rename(String id, String name) async {
    final n = name.trim();
    final current = byId(id);
    if (current == null) return AppStrings.readError;
    if (n.isEmpty) return AppStrings.enterSubject;
    final same = byName(n);
    if (same != null && same.id != id) return AppStrings.subjectExists;
    final updated = current.copyWith(name: n);
    final ok = await AppDatabase.run(
        () => AppDatabase.subjects.put(id, updated.toMap()));
    if (!ok) return AppStrings.saveError;
    notifyListeners();
    return null;
  }

  // ---- DELETE ----
  /// Тапсырмасы бар пәнді жоюға болмайды (тұтастық сақталады).
  Future<String?> remove(String id) async {
    if (taskCount(id) > 0) return AppStrings.subjectInUse;
    final ok = await AppDatabase.run(() => AppDatabase.subjects.delete(id),
        message: AppStrings.deleteError);
    if (!ok) return AppStrings.deleteError;
    notifyListeners();
    return null;
  }
}
