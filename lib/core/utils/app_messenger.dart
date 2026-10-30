import 'package:flutter/material.dart';

/// Кез келген жерден SnackBar көрсету үшін (мысалы, дерекқор қателері).
class AppMessenger {
  AppMessenger._();

  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static void show(String message) {
    final state = key.currentState;
    if (state == null) return;
    state.hideCurrentSnackBar();
    state.showSnackBar(SnackBar(content: Text(message)));
  }
}
