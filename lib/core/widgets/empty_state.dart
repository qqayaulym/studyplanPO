import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Бос тізім күйі.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyState({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 56, color: secondaryTextColor(context)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: secondaryTextColor(context)),
          ),
        ],
      ),
    );
  }
}
