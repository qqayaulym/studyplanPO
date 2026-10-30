import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../constants/app_colors.dart';

enum AppButtonType { primary, secondary, accent, danger, outline }

/// Қайталанатын батырма (Figma: Button/Primary, Secondary, Accent, Danger, Outline).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    switch (type) {
      case AppButtonType.primary:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case AppButtonType.secondary:
        bg = cs.primary.withAlpha(30);
        fg = cs.primary;
        break;
      case AppButtonType.accent:
        bg = AppColors.accent;
        fg = AppColors.onAccent;
        break;
      case AppButtonType.danger:
        bg = cs.error.withAlpha(28);
        fg = cs.error;
        break;
      case AppButtonType.outline:
        bg = Colors.transparent;
        fg = cs.primary;
        break;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
    );
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 22), const SizedBox(width: 8)],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    if (type == AppButtonType.outline) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fg,
            side: BorderSide(color: cs.primary, width: 2),
            shape: shape,
            textStyle: textStyle,
          ),
          child: child,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: shape,
          textStyle: textStyle,
        ),
        child: child,
      ),
    );
  }
}
