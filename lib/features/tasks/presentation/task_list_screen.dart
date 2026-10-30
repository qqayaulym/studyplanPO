import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../core/widgets/sort_sheet.dart';
import '../../../core/widgets/subject_filter_row.dart';
import '../../../core/widgets/task_card.dart';
import '../../subjects/data/subject_repository.dart';
import '../data/task_repository.dart';

/// Тапсырмалар тізімі (Read): мәртебе, пән, таңдаулы/кешіккен сүзгілері және сұрыптау.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  int _tab = 0;
  String? _subjectId;
  bool _overdueOnly = false;
  bool _favoritesOnly = false;
  TaskSort _sort = TaskSort.deadline;
  bool _ascending = true;

  TaskStatus get _status {
    if (_overdueOnly) return TaskStatus.overdue;
    switch (_tab) {
      case 1:
        return TaskStatus.active;
      case 2:
        return TaskStatus.done;
      default:
        return TaskStatus.all;
    }
  }

  Future<void> _openSort() async {
    final choice =
        await showSortSheet(context, sort: _sort, ascending: _ascending);
    if (choice == null) return;
    setState(() {
      _sort = choice.sort;
      _ascending = choice.ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = TaskRepository.instance;
    final subjects = SubjectRepository.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tasks),
        actions: [
          IconButton(
            tooltip: AppStrings.sort,
            icon: const Icon(Icons.sort),
            onPressed: _openSort,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppStrings.addTask,
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.taskForm),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: Listenable.merge([repo, subjects]),
            builder: (context, _) {
              final list = repo.query(
                subjectId: _subjectId,
                status: _status,
                favoritesOnly: _favoritesOnly,
                sort: _sort,
                ascending: _ascending,
              );
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SegmentedTabs(
                      labels: const [
                        AppStrings.tabAll,
                        AppStrings.tabActive,
                        AppStrings.tabDone,
                      ],
                      selected: _overdueOnly ? -1 : _tab,
                      onChanged: (i) => setState(() {
                        _tab = i;
                        _overdueOnly = false;
                      }),
                    ),
                  ),
                  SubjectFilterRow(
                    subjects: subjects.all,
                    selectedId: _subjectId,
                    onChanged: (id) => setState(() => _subjectId = id),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text(AppStrings.tabOverdue),
                          selected: _overdueOnly,
                          onSelected: (v) => setState(() => _overdueOnly = v),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text(AppStrings.onlyFavorites),
                          selected: _favoritesOnly,
                          onSelected: (v) => setState(() => _favoritesOnly = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? EmptyState(
                            icon: Icons.task_alt,
                            text: repo.total == 0
                                ? AppStrings.noTasks
                                : AppStrings.filterNothing,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final t = list[i];
                              return TaskCard(
                                task: t,
                                onTap: () => Navigator.of(context).pushNamed(
                                    AppRoutes.taskDetail,
                                    arguments: t.id),
                                onToggleDone: () => repo.toggleDone(t.id),
                              );
                            },
                          ),
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
