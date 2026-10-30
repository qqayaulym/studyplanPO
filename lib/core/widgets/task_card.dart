import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../features/subjects/data/subject_repository.dart';
import '../../features/tasks/domain/task.dart';
import '../constants/app_colors.dart';
import '../utils/date_utils.dart';
import 'subject_chip.dart';

/// Тапсырма карточкасы (Figma: Card/Task). Басты бет, тізім, іздеу, таңдаулылар экрандарында қолданылады.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleDone;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = dateOnly(task.deadline).difference(dateOnly(DateTime.now())).inDays;
    final overdue = !task.isDone && days < 0;
    final soon = !task.isDone && days >= 0 && days <= 2;
    final dueColor = overdue
        ? cs.error
        : soon
            ? (Theme.of(context).brightness == Brightness.dark
                ? AppColors.accent
                : AppColors.warning)
            : secondaryTextColor(context);

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Орындалды белгісі
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onToggleDone,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: task.isDone ? AppColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: task.isDone ? AppColors.success : secondaryTextColor(context),
                      width: 2,
                    ),
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? secondaryTextColor(context) : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SubjectChip.of(SubjectRepository.instance.byId(task.subjectId)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: dueColor),
                            const SizedBox(width: 4),
                            Text(
                              '${formatDayMonth(task.deadline)} · ${daysLeftText(task.deadline)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: dueColor,
                                fontWeight: (overdue || soon)
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (task.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.star, size: 22, color: AppColors.accent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
