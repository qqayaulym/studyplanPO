import 'package:flutter/material.dart';

import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/splash/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/remote/presentation/remote_tasks_screen.dart';
import '../features/subjects/presentation/subjects_screen.dart';
import '../features/tasks/domain/task.dart';
import '../features/tasks/presentation/task_detail_screen.dart';
import '../features/tasks/presentation/task_form_screen.dart';

/// Барлық маршруттар бір жерде. Навигация: Navigator.pushNamed(context, AppRoutes.xxx).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String taskDetail = '/task';
  static const String taskForm = '/task/form';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String subjects = '/subjects';
  static const String remote = '/remote';

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    Widget page;
    switch (s.name) {
      case splash:
        page = const SplashScreen();
        break;
      case onboarding:
        page = const OnboardingScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case register:
        page = const RegisterScreen();
        break;
      case forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case home:
        page = const MainShell();
        break;
      case taskDetail:
        page = TaskDetailScreen(taskId: s.arguments as String);
        break;
      case taskForm:
        // arguments == null → жаңа тапсырма, Task → өңдеу
        page = TaskFormScreen(task: s.arguments as Task?);
        break;
      case statistics:
        page = const StatisticsScreen();
        break;
      case settings:
        page = const SettingsScreen();
        break;
      case remote:
        page = const RemoteTasksScreen();
        break;
      case subjects:
        page = const SubjectsScreen();
        break;
      default:
        page = const SplashScreen();
    }
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: s);
  }
}
