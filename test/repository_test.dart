import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:studyplan/core/database/app_database.dart';
import 'package:studyplan/features/auth/data/auth_service.dart';
import 'package:studyplan/features/subjects/data/subject_repository.dart';
import 'package:studyplan/features/tasks/data/subtask_repository.dart';
import 'package:studyplan/features/tasks/data/task_repository.dart';

/// Дерекқор қабатының автоматты тесттері (Hive уақытша папкада, интернетсіз).
void main() {
  late Directory dir;
  final tasks = TaskRepository.instance;
  final subjects = SubjectRepository.instance;
  final auth = AuthService.instance;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('studyplan_test_');
    await AppDatabase.init(testPath: dir.path);
    await auth.login('aidana@mail.kz', '12345678');
    tasks.reload();
  });

  tearDown(() async {
    await AppDatabase.close();
    dir.deleteSync(recursive: true);
  });

  test('бірінші іске қосуда демо деректер жасалады', () {
    expect(tasks.all.length, 6);
    expect(subjects.all.length, 4);
    expect(auth.isLoggedIn, isTrue);
  });

  test('Create + Read: жаңа тапсырма қосылады', () async {
    final ok = await tasks.create(
      title: 'Жаңа тапсырма',
      subjectId: 'subj-Мобильді',
      deadline: DateTime.now().add(const Duration(days: 3)),
    );
    expect(ok, isTrue);
    expect(tasks.all.length, 7);
  });

  test('Update + Favorites', () async {
    final t = tasks.byId('seed-3')!;
    expect(t.isFavorite, isFalse);
    await tasks.toggleFavorite('seed-3');
    expect(tasks.byId('seed-3')!.isFavorite, isTrue);
    expect(tasks.favorites.length, 3);
    await tasks.update(tasks.byId('seed-3')!.copyWith(title: 'SQL (өзгертілді)'));
    expect(tasks.byId('seed-3')!.title, 'SQL (өзгертілді)');
  });

  test('Delete: тапсырма және оның қадамдары өшеді (cascade)', () async {
    expect(SubTaskRepository.instance.forTask('seed-1').length, 3);
    final ok = await tasks.remove('seed-1');
    expect(ok, isTrue);
    expect(tasks.byId('seed-1'), isNull);
    expect(SubTaskRepository.instance.forTask('seed-1'), isEmpty);
  });

  test('Іздеу, сүзгілеу, сұрыптау', () {
    expect(tasks.query(text: 'sql').length, 1);
    expect(tasks.query(text: 'дерекқор').length, 2); // пән атауы бойынша
    expect(tasks.query(subjectId: 'subj-Мобильді').length, 2);
    expect(tasks.query(status: TaskStatus.done).length, 1);
    expect(tasks.query(status: TaskStatus.overdue).length, 1);
    expect(tasks.query(favoritesOnly: true).length, 2);
    expect(tasks.query(text: 'жоқ-мұндай-сөз'), isEmpty);

    final byDeadline = tasks.query(sort: TaskSort.deadline);
    expect(byDeadline.first.id, 'seed-6'); // ең ерте (кешіккен)
    final byDeadlineDesc =
        tasks.query(sort: TaskSort.deadline, ascending: false);
    expect(byDeadlineDesc.first.id, 'seed-5'); // ең кеш

    final byTitle = tasks.query(sort: TaskSort.title);
    final titles = byTitle.map((t) => t.title.toLowerCase()).toList();
    final sorted = List<String>.from(titles)..sort();
    expect(titles, sorted);
  });

  test('Деректер қайта іске қосқаннан кейін сақталады', () async {
    await tasks.create(
      title: 'Сақталу тесті',
      subjectId: 'subj-Тестілеу',
      deadline: DateTime.now().add(const Duration(days: 1)),
    );
    // "Қосымшаны жабу" және қайта ашу
    await AppDatabase.close();
    await AppDatabase.init(testPath: dir.path);
    auth.restoreSession();
    tasks.reload();
    expect(auth.isLoggedIn, isTrue);
    expect(tasks.all.where((t) => t.title == 'Сақталу тесті').length, 1);
  });

  test('Пән: қайталануға және тапсырмасы бар пәнді жоюға болмайды', () async {
    expect(await subjects.add('Мобильді'), isNotNull); // бар
    expect(await subjects.add('Физика'), isNull);
    expect(subjects.all.length, 5);
    expect(await subjects.remove('subj-Мобильді'), isNotNull); // тапсырмасы бар
    final physics = subjects.byName('Физика')!;
    expect(await subjects.remove(physics.id), isNull);
    expect(subjects.all.length, 4);
  });

  test('Тіркелу және кіру', () async {
    expect(await auth.register('Тест', 'aidana@mail.kz', '12345678'), isFalse);
    expect(await auth.register('Тест', 'new@mail.kz', 'abcdefgh'), isTrue);
    tasks.reload();
    expect(tasks.all, isEmpty); // жаңа пайдаланушыда тапсырма жоқ → empty state
    expect(await auth.login('new@mail.kz', 'қате-құпиясөз'), isFalse);
    expect(await auth.login('new@mail.kz', 'abcdefgh'), isTrue);
  });
}
