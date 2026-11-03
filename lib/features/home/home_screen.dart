import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/content_width.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/task_card.dart';
import '../auth/data/auth_service.dart';
import '../tasks/data/task_repository.dart';

/// Басты бет: сәлемдесу, жалпы прогресс, жақын мерзімдер.
class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenTasks;
  const HomeScreen({super.key, required this.onOpenTasks});

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository.instance;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: AppStrings.addTask,
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.taskForm),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: repo,
          builder: (context, _) {
            final upcoming = repo.active
              ..sort((a, b) => a.deadline.compareTo(b.deadline));
            final shown = upcoming.take(4).toList();
            final name = AuthService.instance.currentUser?.name ?? '';
            final first = name.split(' ').first;
            return ContentWidth(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(
                    first.isEmpty ? AppStrings.hello : '${AppStrings.hello}, $first!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.weekProgress,
                            style: TextStyle(
                                color: cs.onPrimary.withAlpha(200),
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('${repo.progressPercent}%',
                            style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: repo.progressPercent / 100,
                            minHeight: 8,
                            backgroundColor: cs.onPrimary.withAlpha(60),
                            color: const Color(0xFFFFB300),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${repo.doneCount} / ${repo.total} ${AppStrings.done.toLowerCase()}',
                          style: TextStyle(color: cs.onPrimary.withAlpha(220)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(AppStrings.upcoming,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      TextButton(
                          onPressed: onOpenTasks,
                          child: const Text(AppStrings.all)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (shown.isEmpty)
                    const SizedBox(
                      height: 220,
                      child: EmptyState(
                          icon: Icons.task_alt, text: AppStrings.noTasks),
                    )
                  else
                    for (final t in shown)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(
                          task: t,
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.taskDetail, arguments: t.id),
                          onToggleDone: () => repo.toggleDone(t.id),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
