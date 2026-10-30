import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';

/// Қолданушы параметрлері (тақырып, хабарландыру). Hive 'settings' қорапшасында сақталады.
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _darkKey = 'dark_mode';
  static const _remindKey = 'reminders_on';
  static const _timeKey = 'reminder_minutes';

  bool _darkMode = false;
  bool _remindersOn = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  bool get darkMode => _darkMode;
  bool get remindersOn => _remindersOn;
  TimeOfDay get reminderTime => _reminderTime;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  /// Дерекқор ашылғаннан кейін шақырылады.
  void load() {
    final box = AppDatabase.settings;
    _darkMode = (box.get(_darkKey) as bool?) ?? false;
    _remindersOn = (box.get(_remindKey) as bool?) ?? true;
    final minutes = (box.get(_timeKey) as int?) ?? 9 * 60;
    _reminderTime = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    notifyListeners();
    await AppDatabase.run(() => AppDatabase.settings.put(_darkKey, v));
  }

  Future<void> setRemindersOn(bool v) async {
    _remindersOn = v;
    notifyListeners();
    await AppDatabase.run(() => AppDatabase.settings.put(_remindKey, v));
  }

  Future<void> setReminderTime(TimeOfDay t) async {
    _reminderTime = t;
    notifyListeners();
    await AppDatabase.run(
        () => AppDatabase.settings.put(_timeKey, t.hour * 60 + t.minute));
  }
}
