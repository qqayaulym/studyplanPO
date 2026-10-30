import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'features/auth/data/auth_service.dart';
import 'features/settings/app_settings.dart';

/// Дерекқорды ашып, сессия мен параметрлерді қалпына келтіреді.
/// Қате болса — қате хабарламасын қайтарады.
Future<String?> bootstrap() async {
  try {
    await AppDatabase.init();
    AppSettings.instance.load();
    AuthService.instance.restoreSession();
    return null;
  } catch (e) {
    return e.toString();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final error = await bootstrap();
  runApp(error == null ? const StudyPlanApp() : DbErrorApp(message: error));
}

/// Дерекқор ашылмаса көрсетілетін экран (қатені өңдеу).
class DbErrorApp extends StatefulWidget {
  final String message;
  const DbErrorApp({super.key, required this.message});

  @override
  State<DbErrorApp> createState() => _DbErrorAppState();
}

class _DbErrorAppState extends State<DbErrorApp> {
  late String _message = widget.message;
  bool _busy = false;

  Future<void> _retry() async {
    setState(() => _busy = true);
    final error = await bootstrap();
    if (!mounted) return;
    if (error == null) {
      runApp(const StudyPlanApp());
    } else {
      setState(() {
        _message = error;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _retry,
                    child: const Text('Қайталау'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
