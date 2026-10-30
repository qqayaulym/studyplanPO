import 'package:flutter/material.dart';

/// Мазмұнның енін шектеп, орталыққа орналастырады.
/// Телефонда толық енін алады, планшет пен кең экранда 600 dp-ден аспайды.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({super.key, required this.child, this.maxWidth = 600});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
