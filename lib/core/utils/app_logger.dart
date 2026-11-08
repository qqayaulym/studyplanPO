import 'dart:developer' as developer;

/// Қолданбадағы маңызды оқиғалар мен қателерге ортақ лог нүктесі.
class AppLogger {
  AppLogger._();

  static void info(String message, {String name = 'StudyPlan'}) {
    developer.log(message, name: name, level: 800);
  }

  static void error(String message, Object error, StackTrace stackTrace,
      {String name = 'StudyPlan'}) {
    developer.log(message,
        name: name, error: error, stackTrace: stackTrace, level: 1000);
  }
}
