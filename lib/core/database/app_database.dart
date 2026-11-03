import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_strings.dart';
import '../constants/subjects.dart';
import '../utils/app_messenger.dart';
import '../utils/password_hasher.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/subjects/domain/subject.dart';
import '../../features/tasks/domain/subtask.dart';
import '../../features/tasks/domain/task.dart';

/// Дерекқормен жұмыс кезіндегі қате.
class DbException implements Exception {
  final String message;
  const DbException(this.message);

  @override
  String toString() => message;
}

/// Hive дерекқорын инициализациялайды және "кесте" (box) нысандарын береді.
///
/// Hive-та деректер key–value қорапшаларында (Box) сақталады:
///   users, subjects, tasks, subtasks, settings.
/// Әр жазба — Map (toMap/fromMap арқылы модельмен түрлендіріледі).
class AppDatabase {
  AppDatabase._();

  static const String usersBoxName = 'users';
  static const String subjectsBoxName = 'subjects';
  static const String tasksBoxName = 'tasks';
  static const String subtasksBoxName = 'subtasks';
  static const String settingsBoxName = 'settings';

  static const String demoUserId = 'demo-user';

  static late Box users;
  static late Box subjects;
  static late Box tasks;
  static late Box subtasks;
  static late Box settings;

  /// [testPath] берілсе, Flutter-сіз (unit-тест) жұмыс істейді.
  static Future<void> init({String? testPath}) async {
    try {
      if (testPath != null) {
        Hive.init(testPath);
      } else {
        await Hive.initFlutter();
      }
      users = await Hive.openBox(usersBoxName);
      subjects = await Hive.openBox(subjectsBoxName);
      tasks = await Hive.openBox(tasksBoxName);
      subtasks = await Hive.openBox(subtasksBoxName);
      settings = await Hive.openBox(settingsBoxName);
      await _seedIfEmpty();
    } catch (e) {
      debugPrint('DB init error: $e');
      throw DbException('${AppStrings.dbOpenError}: $e');
    }
  }

  /// Тест үшін: барлық қораптарды жауып, жадты босатады.
  static Future<void> close() async {
    await Hive.close();
  }

  /// Жазу операциясын қауіпсіз орындайды: қате болса SnackBar көрсетіп, false қайтарады.
  static Future<bool> run(
    Future<void> Function() operation, {
    String message = AppStrings.saveError,
  }) async {
    try {
      await operation();
      return true;
    } catch (e) {
      debugPrint('DB error: $e');
      AppMessenger.show(message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Бастапқы деректер (тек бірінші іске қосуда)
  // ---------------------------------------------------------------------------
  static Future<void> _seedIfEmpty() async {
    if (subjects.isEmpty) {
      var t = DateTime.now().millisecondsSinceEpoch;
      for (final info in AppSubjects.all) {
        final s = Subject(
          id: 'subj-${info.name}',
          name: info.name,
          backgroundValue: info.background.toARGB32(),
          foregroundValue: info.foreground.toARGB32(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(t++),
        );
        await subjects.put(s.id, s.toMap());
      }
    }
    if (users.isEmpty) {
      const email = 'aidana@mail.kz';
      final user = AppUser(
        id: demoUserId,
        name: 'Айдана Сәрсенбаева',
        email: email,
        passwordHash: PasswordHasher.hash(email, '12345678'),
        createdAt: DateTime.now(),
      );
      await users.put(user.id, user.toMap());
      await _seedDemoTasks(user.id);
    }
  }

  static Future<void> _seedDemoTasks(String userId) async {
    final today = DateTime.now();
    DateTime inDays(int d) =>
        DateTime(today.year, today.month, today.day).add(Duration(days: d));
    final now = DateTime.now().millisecondsSinceEpoch;

    Task make(int i, String title, String subject, int days,
        {String description = '',
        String reminder = 'Еске салғышсыз',
        bool done = false,
        bool fav = false}) {
      return Task(
        id: 'seed-$i',
        userId: userId,
        subjectId: 'subj-$subject',
        title: title,
        description: description,
        deadline: inDays(days),
        reminder: reminder,
        isDone: done,
        isFavorite: fav,
        createdAt: DateTime.fromMillisecondsSinceEpoch(now + i),
      );
    }

    final list = [
      make(1, 'Flutter практикалық жұмысы №1', 'Мобильді', 2,
          description:
              'Техникалық тапсырма құжатын дайындап, Flutter-де бастапқы жобаны құру және тестілеу.',
          reminder: '1 күн бұрын',
          fav: true),
      make(2, 'Figma прототипі (ПЖ №2)', 'Мобильді', 4,
          description: 'Экрандарды жобалап, интерактивті прототип жасау.',
          reminder: '2 күн бұрын',
          fav: true),
      make(3, 'SQL сұраныстарын жазу', 'Дерекқор', 5,
          description: 'JOIN және GROUP BY бойынша 10 сұраныс жазу.'),
      make(4, 'Тест-кейстер кестесін толтыру', 'Тестілеу', 7, done: true),
      make(5, 'Реферат: IT саласындағы кәсіптер', 'Қазақ тілі', 9,
          reminder: '1 күн бұрын'),
      make(6, 'Алгоритмдерді талдау', 'Дерекқор', -1,
          description: 'Мерзімі өтіп кеткен тапсырма (мысал).'),
    ];
    for (final t in list) {
      await tasks.put(t.id, t.toMap());
    }
    final steps = [
      SubTask(
          id: 'seed-s1',
          taskId: 'seed-1',
          title: 'Техникалық тапсырманы жазу',
          isDone: true,
          createdAt: DateTime.fromMillisecondsSinceEpoch(now + 1)),
      SubTask(
          id: 'seed-s2',
          taskId: 'seed-1',
          title: 'Flutter жобасын құру',
          createdAt: DateTime.fromMillisecondsSinceEpoch(now + 2)),
      SubTask(
          id: 'seed-s3',
          taskId: 'seed-1',
          title: 'Құжатты тапсыру',
          createdAt: DateTime.fromMillisecondsSinceEpoch(now + 3)),
    ];
    for (final s in steps) {
      await subtasks.put(s.id, s.toMap());
    }
  }
}
