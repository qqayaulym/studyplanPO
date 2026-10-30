import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_utils.dart';
import '../../core/widgets/content_width.dart';
import '../../core/widgets/empty_state.dart';
import '../subjects/data/subject_repository.dart';
import '../tasks/data/task_repository.dart';

/// Статистика: жалпы прогресс, пәндер бойынша орындалу, жақын 7 күндегі мерзімдер.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository.instance;
    final subjects = SubjectRepository.instance;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.statistics)),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: Listenable.merge([repo, subjects]),
            builder: (context, _) {
              if (repo.total == 0) {
                return const EmptyState(
                    icon: Icons.bar_chart, text: AppStrings.noTasks);
              }
              final today = dateOnly(DateTime.now());
              final week = repo.active
                  .where((t) {
                    final d = dateOnly(t.deadline);
                    return !d.isBefore(today) &&
                        d.isBefore(today.add(const Duration(days: 7)));
                  })
                  .toList();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.weekProgress,
                                  style: TextStyle(
                                      color: cs.onPrimary.withAlpha(200))),
                              Text('${repo.progressPercent}%',
                                  style: TextStyle(
                                      color: cs.onPrimary,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800)),
                              Text(
                                  '${repo.doneCount} / ${repo.total} ${AppStrings.done.toLowerCase()}',
                                  style: TextStyle(
                                      color: cs.onPrimary.withAlpha(220))),
                            ],
                          ),
                        ),
                        Icon(Icons.bar_chart, size: 48, color: cs.onPrimary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(AppStrings.bySubject,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final s in subjects.all)
                    Builder(builder: (context) {
                      final total = repo.totalBySubject(s.id);
                      final done = repo.doneBySubject(s.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(s.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),
                                Text('$done / $total',
                                    style: TextStyle(
                                        color: secondaryTextColor(context))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : done / total,
                                minHeight: 8,
                                color: cs.primary,
                                backgroundColor: cs.primary.withAlpha(30),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 12),
                  Text(AppStrings.dueThisWeek,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (week.isEmpty)
                    Text(AppStrings.noReminders,
                        style: TextStyle(color: secondaryTextColor(context)))
                  else
                    for (final t in week)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.event, color: cs.primary),
                        title: Text(t.title),
                        subtitle: Text(
                            '${formatDayMonth(t.deadline)} · ${weekdayShort[t.deadline.weekday - 1]}'),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
