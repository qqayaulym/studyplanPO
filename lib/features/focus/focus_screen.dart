import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FocusController extends ChangeNotifier {
  static const _sessionLength = Duration(minutes: 25);
  Duration remaining = _sessionLength;
  Timer? _ticker;
  bool get running => _ticker != null;

  void toggle() {
    if (running) {
      _ticker?.cancel();
      _ticker = null;
      notifyListeners();
      return;
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining.inSeconds <= 1) {
        remaining = Duration.zero;
        _ticker?.cancel();
        _ticker = null;
      } else {
        remaining -= const Duration(seconds: 1);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    remaining = _sessionLength;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => FocusController(),
        child: const _FocusView(),
      );
}

class _FocusView extends StatelessWidget {
  const _FocusView();

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusController>();
    final seconds = focus.remaining.inSeconds;
    final display = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    final progress = 1 - seconds / const Duration(minutes: 25).inSeconds;
    return Scaffold(
      appBar: AppBar(title: const Text('Назар қою уақыты')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_bottom_rounded, size: 48),
              const SizedBox(height: 12),
              const Text('25 минут бойы бір тапсырмаға көңіл бөліңіз.'),
              const SizedBox(height: 28),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(value: progress, strokeWidth: 10),
                    Center(
                      child: Text(display,
                          style: Theme.of(context).textTheme.displayMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: focus.toggle,
                    icon: Icon(focus.running ? Icons.pause : Icons.play_arrow),
                    label: Text(focus.running ? 'Кідірту' : 'Бастау'),
                  ),
                  OutlinedButton.icon(
                    onPressed: focus.reset,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Қайта бастау'),
                  ),
                ],
              ),
              if (seconds == 0) ...[
                const SizedBox(height: 20),
                Text('Жарайсыз! Назар қою кезеңі аяқталды.',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
