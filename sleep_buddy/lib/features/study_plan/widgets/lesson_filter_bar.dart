import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/study_plan/model/models.dart';
import 'package:sleep_buddy/features/study_plan/screens/planner_style.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class LessonFilterBar extends StatelessWidget {
  const LessonFilterBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });
  final List<PlannerFilterItem> items;
  final LessonFilter selected;
  final ValueChanged<LessonFilter>? onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final style = TextStyle(
        fontSize: 11,
        color: PlannerStyle.secondary(context),
        fontFamily: DefaultTextStyle.of(context).style.fontFamily,
      );
      final widths = items.map((item) {
        final painter = TextPainter(
          text: TextSpan(
            text: '${item.label} · ${item.count}',
            style: style.copyWith(fontWeight: FontWeight.w700),
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final result = painter.width + 24;
        painter.dispose();
        return result < 48 ? 48.0 : result;
      }).toList();
      final total =
          widths.fold<double>(0, (sum, value) => sum + value) +
          (items.isEmpty ? 0 : items.length - 1) * 6;
      final extra = items.isEmpty || total >= constraints.maxWidth
          ? 0.0
          : (constraints.maxWidth - total) / items.length;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0) const SizedBox(width: 6),
              Semantics(
                selected: items[index].value == selected,
                button: true,
                child: SizedBox(
                  width: widths[index] + extra,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: ValueKey('filter-${items[index].value.name}'),
                      borderRadius: BorderRadius.circular(24),
                      onTap: onChanged == null
                          ? null
                          : () => onChanged!(items[index].value),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 36),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: items[index].value == selected
                                  ? AppStyle.tinted(context)
                                  : AppStyle.surface(context),
                              border: Border.all(
                                width: .5,
                                color: items[index].value == selected
                                    ? AppStyle.border(context)
                                    : AppStyle.border(context),
                              ),
                            ),
                            child: Text(
                              '${items[index].label} · ${items[index].count}',
                              textAlign: TextAlign.center,
                              style: style.copyWith(
                                fontWeight: items[index].value == selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: items[index].value == selected
                                    ? const Color(0xFF4922B5)
                                    : PlannerStyle.secondary(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
