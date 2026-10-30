import 'package:flutter/material.dart';

import '../../features/subjects/domain/subject.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Пән белгісі (Figma: Chip/Subject). Сүзгі ретінде де қолданылады (selected).
class SubjectChip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool selected;
  final VoidCallback? onTap;

  const SubjectChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.selected = false,
    this.onTap,
  });

  /// Subject моделінен жасау (null болса — «Пәнсіз»).
  factory SubjectChip.of(Subject? subject,
      {Key? key, bool selected = false, VoidCallback? onTap}) {
    return SubjectChip(
      key: key,
      label: subject?.name ?? AppStrings.noSubject,
      background: subject?.background ?? AppColors.primaryLight,
      foreground: subject?.foreground ?? AppColors.primaryDark,
      selected: selected,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = selected ? cs.primary : background;
    final fg = selected ? cs.onPrimary : foreground;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
