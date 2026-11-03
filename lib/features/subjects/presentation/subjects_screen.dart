import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/subject_chip.dart';
import '../data/subject_repository.dart';
import '../domain/subject.dart';

/// Пәндерді басқару: қосу (Create), тізім (Read), атын өзгерту (Update), жою (Delete).
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  Future<void> _edit(BuildContext context, {Subject? subject}) async {
    final repo = SubjectRepository.instance;
    final controller = TextEditingController(text: subject?.name ?? '');
    String? error;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(subject == null
              ? AppStrings.addSubject
              : AppStrings.renameSubject),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppStrings.subjectName,
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(AppStrings.cancel)),
            TextButton(
              onPressed: () async {
                final err = subject == null
                    ? await repo.add(controller.text)
                    : await repo.rename(subject.id, controller.text);
                if (err == null) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  setState(() => error = err);
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.subjectSaved)));
    }
  }

  Future<void> _delete(BuildContext context, Subject s) async {
    final messenger = ScaffoldMessenger.of(context);
    final err = await SubjectRepository.instance.remove(s.id);
    messenger.showSnackBar(
        SnackBar(content: Text(err ?? AppStrings.subjectDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final repo = SubjectRepository.instance;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subjectsTitle)),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: AppStrings.addSubject,
        onPressed: () => _edit(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: repo,
            builder: (context, _) {
              final list = repo.all;
              if (list.isEmpty) {
                return const EmptyState(
                    icon: Icons.menu_book_outlined, text: AppStrings.noSubjects);
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final s = list[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: ListTile(
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: SubjectChip.of(s),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                            '${repo.taskCount(s.id)} ${AppStrings.taskCount}'),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: AppStrings.edit,
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _edit(context, subject: s),
                          ),
                          IconButton(
                            tooltip: AppStrings.delete,
                            icon: Icon(Icons.delete_outline, color: cs.error),
                            onPressed: () => _delete(context, s),
                          ),
                        ],
                      ),
                    ),
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
