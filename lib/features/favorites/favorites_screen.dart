import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/content_width.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/task_card.dart';
import '../tasks/data/task_repository.dart';

/// Таңдаулылар: isFavorite == true тапсырмалар (дерекқордан оқылады).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository.instance;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.favorites)),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: repo,
            builder: (context, _) {
              final list = repo.favorites;
              if (list.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 220,
                      child: EmptyState(
                          icon: Icons.star_border,
                          text: AppStrings.emptyFavorites),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        AppStrings.favoritesTip,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor(context)),
                      ),
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: list.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Text(AppStrings.favoritesHint,
                        style: TextStyle(color: secondaryTextColor(context)));
                  }
                  final t = list[i - 1];
                  return TaskCard(
                    task: t,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.taskDetail, arguments: t.id),
                    onToggleDone: () => repo.toggleDone(t.id),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
