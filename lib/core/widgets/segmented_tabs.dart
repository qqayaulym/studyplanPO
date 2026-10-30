import 'package:flutter/material.dart';

/// Үш-төрт бөліктен тұратын таб-ауыстырғыш (Барлығы / Белсенді / Орындалды).
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: i == selected ? cs.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: i == selected
                          ? cs.primary
                          : cs.onSurface.withAlpha(166),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
