import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/content_width.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/sort_sheet.dart';
import '../../core/widgets/subject_filter_row.dart';
import '../../core/widgets/task_card.dart';
import '../subjects/data/subject_repository.dart';
import '../tasks/data/task_repository.dart';
import '../tasks/domain/task.dart';

/// Іздеу: атауы / сипаттамасы / пәні бойынша; пән сүзгісі; сұрыптау; соңғы іздеулер (дерекқорда).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _text = '';
  String? _subjectId;
  TaskSort _sort = TaskSort.deadline;
  bool _ascending = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setText(String v) {
    _controller.text = v;
    _controller.selection = TextSelection.collapsed(offset: v.length);
    setState(() => _text = v);
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
    final hasQuery = _text.trim().isNotEmpty || _subjectId != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navSearch),
        actions: [
          IconButton(
            tooltip: AppStrings.sort,
            icon: const Icon(Icons.sort),
            onPressed: _openSort,
          ),
        ],
      ),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: Listenable.merge([repo, subjects]),
            builder: (context, _) {
              final List<Task> results = hasQuery
                  ? repo.query(
                      text: _text,
                      subjectId: _subjectId,
                      sort: _sort,
                      ascending: _ascending,
                    )
                  : <Task>[];
              final recent = repo.recentSearches;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _text = v),
                      onSubmitted: (v) => repo.addRecentSearch(v),
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: AppStrings.clear,
                                icon: const Icon(Icons.close),
                                onPressed: () => _setText(''),
                              ),
                      ),
                    ),
                  ),
                  SubjectFilterRow(
                    subjects: subjects.all,
                    selectedId: _subjectId,
                    onChanged: (id) => setState(() => _subjectId = id),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: !hasQuery
                        ? _RecentList(
                            recent: recent,
                            onPick: (q) {
                              _setText(q);
                              repo.addRecentSearch(q);
                            },
                            onRemove: repo.removeRecentSearch,
                          )
                        : results.isEmpty
                            ? const EmptyState(
                                icon: Icons.search_off,
                                text: AppStrings.nothingFound)
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                itemCount: results.length + 1,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  if (i == 0) {
                                    return Text(
                                      '${AppStrings.results}: ${results.length}',
                                      style: TextStyle(
                                          color: secondaryTextColor(context)),
                                    );
                                  }
                                  final t = results[i - 1];
                                  return TaskCard(
                                    task: t,
                                    onTap: () {
                                      repo.addRecentSearch(_text);
                                      Navigator.of(context).pushNamed(
                                          AppRoutes.taskDetail,
                                          arguments: t.id);
                                    },
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

class _RecentList extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onPick;
  final ValueChanged<String> onRemove;

  const _RecentList({
    required this.recent,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) {
      return const EmptyState(
          icon: Icons.search, text: AppStrings.emptySearch);
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Text(AppStrings.recent, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        for (final q in recent)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(q),
            trailing: IconButton(
              tooltip: AppStrings.delete,
              icon: const Icon(Icons.close),
              onPressed: () => onRemove(q),
            ),
            onTap: () => onPick(q),
          ),
      ],
    );
  }
}
