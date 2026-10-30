import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Тізім жолы: белгіше + атау + оң жағында кез келген виджет (Figma: List Item).
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = danger ? cs.error : cs.primary;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(28),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: danger ? cs.error : null,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null && !danger)
                Icon(Icons.chevron_right, color: secondaryTextColor(context)),
            ],
          ),
        ),
      ),
    );
  }
}
