import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/planner_style.dart';

class WeekDaySelector extends StatelessWidget {
  const WeekDaySelector(
      {super.key,
      required this.days,
      required this.selectedDate,
      required this.onDateSelected,
      this.today,
      this.weekdayFormatter});
  final List<DateTime> days;
  final DateTime selectedDate;
  final DateTime? today;
  final ValueChanged<DateTime>? onDateSelected;
  final String Function(DateTime)? weekdayFormatter;

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) => PlannerSurface(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: LayoutBuilder(builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
          final minWidth = math.max(48.0, 46 * textScale);
          final cellWidth = days.isEmpty
              ? minWidth
              : math.max(minWidth, constraints.maxWidth / days.length);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final date in days)
                SizedBox(
                    width: cellWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Semantics(
                        selected: sameDay(date, selectedDate),
                        label: '${date.day}/${date.month}/${date.year}',
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: sameDay(date, selectedDate)
                                ? PlannerStyle.primaryGradient
                                : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: onDateSelected == null
                                    ? null
                                    : () => onDateSelected!(date),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 2),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            weekdayFormatter?.call(date) ??
                                                (date.weekday == 7
                                                    ? 'CN'
                                                    : 'Th ${date.weekday + 1}'),
                                            style: TextStyle(
                                                fontSize: 11.5,
                                                height: 1.1,
                                                color: sameDay(
                                                        date, selectedDate)
                                                    ? const Color(0xFFEEE7FF)
                                                    : const Color(0xFF8A7FA8))),
                                        const SizedBox(height: 4),
                                        Text(
                                            date.day.toString().padLeft(2, '0'),
                                            style: TextStyle(
                                                fontSize: 16,
                                                height: 1.2,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    sameDay(date, selectedDate)
                                                        ? Colors.white
                                                        : PlannerStyle.ink)),
                                        const SizedBox(height: 4),
                                        Container(
                                            width: 3,
                                            height: 3,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: today != null &&
                                                        sameDay(date, today!)
                                                    ? (sameDay(
                                                            date, selectedDate)
                                                        ? Colors.white
                                                        : PlannerStyle.purple)
                                                    : Colors.transparent)),
                                      ]),
                                ),
                              )),
                        ),
                      ),
                    )),
            ]),
          );
        }),
      );
}
