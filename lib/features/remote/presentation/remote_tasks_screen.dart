import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/content_width.dart';
import '../../../core/widgets/empty_state.dart';
import '../../tasks/data/task_repository.dart';
import '../data/remote_repository.dart';
import '../domain/remote_todo.dart';

/// Серверден деректер алатын экран: GET тізім, POST қосу, PUT өзгерту,
/// PATCH орындалды белгісі, DELETE жою. Loading / Success / Error / Empty күйлері бар.
class RemoteTasksScreen extends StatefulWidget {
  const RemoteTasksScreen({super.key});

  @override
  State<RemoteTasksScreen> createState() => _RemoteTasksScreenState();
}

class _RemoteTasksScreenState extends State<RemoteTasksScreen> {
  final RemoteRepository _repo = RemoteRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.load();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Нәтижені көрсету: null — сәтті (success хабарламасы), әйтпесе қате мәтіні.
  void _report(String? error, String success) {
    if (!mounted) return;
    _snack(error ?? success);
  }

  Future<String?> _askTitle({String? initial, required String heading}) async {
    final controller = TextEditingController(text: initial ?? '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(heading),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: AppStrings.remoteTitle),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? AppStrings.enterTitle
                : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(controller.text);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _add() async {
    final title = await _askTitle(heading: AppStrings.newRemote);
    if (title == null) return;
    _report(await _repo.add(title), AppStrings.serverAdded);
  }

  Future<void> _edit(RemoteTodo todo) async {
    final title =
        await _askTitle(initial: todo.title, heading: AppStrings.editRemote);
    if (title == null) return;
    _report(await _repo.rename(todo, title), AppStrings.serverUpdated);
  }

  Future<void> _delete(RemoteTodo todo) async {
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
    if (ok != true) return;
    _report(await _repo.remove(todo), AppStrings.serverDeleted);
  }

  Future<void> _import(RemoteTodo todo) async {
    _report(await _repo.importToLocal(todo), AppStrings.imported);
  }

  Future<void> _upload() async {
    final r = await _repo.uploadLocal();
    if (!mounted) return;
    if (r.error != null) {
      _snack(r.error!);
    } else if (r.sent == 0) {
      _snack(AppStrings.nothingToUpload);
    } else {
      _snack('${AppStrings.uploadedCount}: ${r.sent}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.serverTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: _repo.load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: AppStrings.addTask,
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ContentWidth(
          child: AnimatedBuilder(
            animation: Listenable.merge([_repo, TaskRepository.instance]),
            builder: (context, _) {
              return Column(
                children: [
                  if (_repo.busy) const LinearProgressIndicator(minHeight: 3),
                  _InfoCard(onUpload: _repo.busy ? null : _upload),
                  Expanded(child: _body()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_repo.state) {
      case LoadState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(AppStrings.loading),
            ],
          ),
        );
      case LoadState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off,
                    size: 56, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text(_repo.error, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: AppButton(
                      label: AppStrings.retry,
                      icon: Icons.refresh,
                      onPressed: _repo.load),
                ),
              ],
            ),
          ),
        );
      case LoadState.empty:
        return const EmptyState(
            icon: Icons.cloud_queue, text: AppStrings.serverEmpty);
      case LoadState.success:
        final items = _repo.items;
        return RefreshIndicator(
          onRefresh: _repo.load,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _TodoTile(
              todo: items[i],
              imported: _repo.isImported(items[i]),
              onToggle: () async => _report(
                  await _repo.toggle(items[i]), AppStrings.serverUpdated),
              onEdit: () => _edit(items[i]),
              onDelete: () => _delete(items[i]),
              onImport: () => _import(items[i]),
            ),
          ),
        );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final VoidCallback? onUpload;
  const _InfoCard({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final notSynced = TaskRepository.instance.notSynced.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.serverNote,
              style: TextStyle(fontSize: 12, color: secondaryTextColor(context))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('${AppStrings.localNotSynced}: $notSynced',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text(AppStrings.uploadLocal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final RemoteTodo todo;
  final bool imported;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onImport;

  const _TodoTile({
    required this.todo,
    required this.imported,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Checkbox(value: todo.completed, onChanged: (_) => onToggle()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration:
                          todo.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('id: ${todo.id}',
                      style: TextStyle(
                          fontSize: 12, color: secondaryTextColor(context))),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: imported
                ? AppStrings.alreadyImported
                : AppStrings.importLocal,
            icon: Icon(imported ? Icons.check_circle : Icons.download_outlined,
                color: imported ? cs.primary : null),
            onPressed: imported ? null : onImport,
          ),
          IconButton(
            tooltip: AppStrings.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: AppStrings.delete,
            icon: Icon(Icons.delete_outline, color: cs.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
