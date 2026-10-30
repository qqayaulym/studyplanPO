import 'package:flutter/material.dart';

import '../utils/date_utils.dart';

/// Тізімнен таңдайтын өріс (bottom sheet арқылы). Figma: Input + chevron.
class PickerFormField extends FormField<String> {
  PickerFormField({
    super.key,
    required String label,
    required List<String> items,
    required IconData icon,
    String? initialValue,
    String hint = 'Таңдаңыз',
    super.validator,
    required ValueChanged<String> onSelected,
  }) : super(
          initialValue: initialValue,
          builder: (state) {
            final context = state.context;
            Future<void> open() async {
              final picked = await showModalBottomSheet<String>(
                context: context,
                showDragHandle: true,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final item in items)
                        ListTile(
                          title: Text(item),
                          trailing: item == state.value
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.of(ctx).pop(item),
                        ),
                    ],
                  ),
                ),
              );
              if (picked != null) {
                state.didChange(picked);
                onSelected(picked);
              }
            }

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: open,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  suffixIcon: const Icon(Icons.chevron_right),
                  errorText: state.errorText,
                ),
                child: Text(
                  state.value ?? hint,
                  style: TextStyle(
                    fontSize: 16,
                    color: state.value == null
                        ? Theme.of(context).hintColor
                        : null,
                  ),
                ),
              ),
            );
          },
        );
}

/// Күн таңдайтын өріс (DatePicker арқылы).
class DateFormField extends FormField<DateTime> {
  DateFormField({
    super.key,
    required String label,
    DateTime? initialValue,
    super.validator,
    required ValueChanged<DateTime> onSelected,
  }) : super(
          initialValue: initialValue,
          builder: (state) {
            final context = state.context;
            Future<void> open() async {
              final now = DateTime.now();
              final first = DateTime(now.year - 1);
              final start = state.value ?? now;
              final picked = await showDatePicker(
                context: context,
                initialDate: start.isBefore(first) ? now : start,
                firstDate: first,
                lastDate: DateTime(now.year + 3),
              );
              if (picked != null) {
                state.didChange(picked);
                onSelected(picked);
              }
            }

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: open,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  errorText: state.errorText,
                ),
                child: Text(
                  state.value == null
                      ? 'Күнді таңдаңыз'
                      : formatDate(state.value!),
                  style: TextStyle(
                    fontSize: 16,
                    color: state.value == null
                        ? Theme.of(context).hintColor
                        : null,
                  ),
                ),
              ),
            );
          },
        );
}
