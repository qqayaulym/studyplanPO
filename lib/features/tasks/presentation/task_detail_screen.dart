import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/subject_chip.dart';
import '../../subjects/data/subject_repository.dart';
import '../data/subtask_repository.dart';
import '../data/task_repository.dart';
import '../domain/subtask.dart';

/// Тапсырма мәліметі: мерзім, еске салғыш, сипаттама; орындау, таңдаулы, өңдеу, жою.
class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmText),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(AppStrings.cancel)),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppStrings.delete,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final deleted = await TaskRepository.instance.remove(taskId);
    if (!deleted) return; // қате хабарламасын AppDatabase.run көрсетті
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text(AppStrings.taskDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository.instance;
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: Listenable.merge([repo, SubTaskRepository.instance, SubjectRepository.instance]),
      builder: (context, _) {
        final task = repo.byId(taskId);
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
                icon: Icons.search_off, text: AppStrings.notFound),
          );
        }
        final days = dateOnly(task.deadline)
            .difference(dateOnly(DateTime.now()))
            .inDays;
        final overdue = !task.isDone && days < 0;
        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.tasks),
            actions: [
              IconButton(
                tooltip: AppStrings.addToFavorites,
                icon: Icon(task.isFavorite ? Icons.star : Icons.star_border,
                    color: task.isFavorite ? const Color(0xFFFFB300) : null),
                onPressed: () => repo.toggleFavorite(task.id),
              ),
            ],
          ),
          body: SafeArea(
            child: ContentWidth(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SubjectChip.of(
                            SubjectRepository.instance.byId(task.subjectId))),
                    const SizedBox(height: 12),
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            decoration:
                                task.isDone ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: AppStrings.deadline,
                        value: formatDate(task.deadline),
                        valueColor: overdue ? cs.error : null,
                      ),
                      _InfoRow(
                        icon: Icons.schedule,
                        label: 'Қалды',
                        value: task.isDone
                            ? AppStrings.done
                            : daysLeftText(task.deadline),
                        valueColor: overdue ? cs.error : null,
                      ),
                      _InfoRow(
                        icon: Icons.notifications_none,
                        label: AppStrings.reminder,
                        value: task.reminder,
                      ),
                    ]),
                    if (task.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Сипаттамасы',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(task.description,
                          style: TextStyle(
                              fontSize: 16, color: secondaryTextColor(context))),
                    ],
                    const SizedBox(height: 24),
                    _SubTaskSection(taskId: task.id),
                    const SizedBox(height: 24),
                    AppButton(
                      label: task.isDone
                          ? AppStrings.markUndone
                          : AppStrings.markDone,
                      icon: Icons.check,
                      onPressed: () => repo.toggleDone(task.id),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: AppStrings.edit,
                      type: AppButtonType.outline,
                      icon: Icons.edit_outlined,
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRoutes.taskForm, arguments: task),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: AppStrings.delete,
                      type: AppButtonType.danger,
                      icon: Icons.delete_outline,
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(color: secondaryTextColor(context))),
          ),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? cs.onSurface)),
          ),
        ],
      ),
    );
  }
}


/// Қадамдар (чек-лист): қосу, белгілеу, өшіру — Task 1—N SubTask.
class _SubTaskSection extends StatefulWidget {
  final String taskId;
  const _SubTaskSection({required this.taskId});

  @override
  State<_SubTaskSection> createState() => _SubTaskSectionState();
}

class _SubTaskSectionState extends State<_SubTaskSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    final ok = await SubTaskRepository.instance.add(widget.taskId, text);
    if (ok) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final repo = SubTaskRepository.instance;
    final steps = repo.forTask(widget.taskId);
    final done = steps.where((s) => s.isDone).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(AppStrings.subtasks,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            if (steps.isNotEmpty)
              Text('$done / ${steps.length}',
                  style: TextStyle(color: secondaryTextColor(context))),
          ],
        ),
        const SizedBox(height: 8),
        if (steps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(AppStrings.noSubtasks,
                style: TextStyle(color: secondaryTextColor(context))),
          )
        else
          for (final SubTask s in steps)
            Row(
              children: [
                Checkbox(value: s.isDone, onChanged: (_) => repo.toggle(s)),
                Expanded(
                  child: Text(
                    s.title,
                    style: TextStyle(
                      decoration: s.isDone ? TextDecoration.lineThrough : null,
                      color: s.isDone ? secondaryTextColor(context) : null,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.delete,
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => repo.remove(s.id),
                ),
              ],
            ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _add(),
                decoration: const InputDecoration(hintText: AppStrings.subtaskHint),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: AppStrings.addSubtask,
              icon: const Icon(Icons.add),
              onPressed: _add,
            ),
          ],
        ),
      ],
    );
  }
}
