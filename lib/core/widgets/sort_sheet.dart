import 'package:flutter/material.dart';

import '../../features/tasks/data/task_repository.dart';
import '../constants/app_strings.dart';

/// Сұрыптау таңдауы: өріс + бағыт.
class SortChoice {
  final TaskSort sort;
  final bool ascending;
  const SortChoice(this.sort, this.ascending);
}

/// Сұрыптау параметрлерін таңдайтын төменгі парақ (мерзімі / атауы / қосылған күні; өсу / кему).
Future<SortChoice?> showSortSheet(
  BuildContext context, {
  required TaskSort sort,
  required bool ascending,
}) {
  return showModalBottomSheet<SortChoice>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      Widget field(String label, TaskSort value) {
        final selected = value == sort;
        return ListTile(
          title: Text(label),
          trailing: selected
              ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
              : null,
          onTap: () => Navigator.of(ctx).pop(SortChoice(value, ascending)),
        );
      }

      Widget direction(String label, bool asc, IconData icon) {
        final selected = asc == ascending;
        return ListTile(
          leading: Icon(icon),
          title: Text(label),
          trailing: selected
              ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
              : null,
          onTap: () => Navigator.of(ctx).pop(SortChoice(sort, asc)),
        );
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            field(AppStrings.sortDeadline, TaskSort.deadline),
            field(AppStrings.sortTitle, TaskSort.title),
            field(AppStrings.sortCreated, TaskSort.created),
            const Divider(),
            direction(AppStrings.ascending, true, Icons.arrow_upward),
            direction(AppStrings.descending, false, Icons.arrow_downward),
          ],
        ),
      );
    },
  );
}
