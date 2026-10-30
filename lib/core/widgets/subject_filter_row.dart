import 'package:flutter/material.dart';

import '../../features/subjects/domain/subject.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'subject_chip.dart';

/// Пән бойынша сүзгі: көлденең тізім («Барлығы» + әр пән).
class SubjectFilterRow extends StatelessWidget {
  final List<Subject> subjects;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const SubjectFilterRow({
    super.key,
    required this.subjects,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SubjectChip(
            label: AppStrings.all,
            background: AppColors.primaryLight,
            foreground: AppColors.primaryDark,
            selected: selectedId == null,
            onTap: () => onChanged(null),
          ),
          for (final s in subjects) ...[
            const SizedBox(width: 8),
            SubjectChip.of(s,
                selected: selectedId == s.id, onTap: () => onChanged(s.id)),
          ],
        ],
      ),
    );
  }
}
