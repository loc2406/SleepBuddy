import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/day_progress_card.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/lesson_card.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/lesson_filter_bar.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/planner_header.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/week_day_selector.dart';

import 'models.dart';
import 'planner_style.dart';

/// Controlled presentation screen. The parent owns fetching, dates, filtering,
/// persistence and navigation. [lessons] is the list to render, already filtered.
class StudyPlannerScreen extends StatelessWidget {
  const StudyPlannerScreen({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.dateLabel,
    required this.lessons,
    required this.totalLessons,
    required this.completedLessons,
    required this.filters,
    this.selectedFilter = LessonFilter.all,
    this.today,
    this.onDateSelected,
    this.onFilterChanged,
    this.onLessonAction,
    this.onAddLesson,
    this.onAddMissionPressed,
    this.onNavigationSelected,
    this.selectedNavigationIndex = 1,
    this.title = 'Lịch trình học tập',
    this.listTitle = 'Bài học hôm nay',
    this.addButtonLabel = 'Thêm bài học mới',
    this.emptyMessage = 'Chưa có bài học trong danh sách này.',
    this.maxContentWidth = 600,
  }) : assert(maxContentWidth > 0);

  final List<DateTime> days;
  final DateTime selectedDate;
  final DateTime? today;
  final String dateLabel;
  final List<StudyLesson> lessons;
  final int totalLessons;
  final int completedLessons;
  final List<PlannerFilterItem> filters;
  final LessonFilter selectedFilter;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<LessonFilter>? onFilterChanged;
  final ValueChanged<StudyLesson>? onLessonAction;
  final VoidCallback? onAddLesson;
  final VoidCallback? onAddMissionPressed;
  final ValueChanged<int>? onNavigationSelected;
  final int selectedNavigationIndex;
  final String title;
  final String listTitle;
  final String addButtonLabel;
  final String emptyMessage;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEFEDFF),
    body: DecoratedBox(
      decoration: const BoxDecoration(gradient: PlannerStyle.background),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final gutter = viewport.maxWidth < 300 ? 12.0 : 16.0;
            final width = viewport.maxWidth;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 2),
                  sliver: SliverToBoxAdapter(
                    child: _center(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PlannerHeader(
                            title: title,
                            dateLabel: dateLabel,
                            onAddMissionPressed: onAddMissionPressed,
                          ),
                          const SizedBox(height: 18),
                          WeekDaySelector(
                            days: days,
                            selectedDate: selectedDate,
                            today: today,
                            onDateSelected: onDateSelected,
                          ),
                          const SizedBox(height: 12),
                          DayProgressCard(
                            totalLessons: totalLessons,
                            completedLessons: completedLessons,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  listTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                    color: PlannerStyle.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '$totalLessons bài học',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: PlannerStyle.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          LessonFilterBar(
                            items: filters,
                            selected: selectedFilter,
                            onChanged: onFilterChanged,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (lessons.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: SliverToBoxAdapter(
                      child: _center(
                        PlannerSurface(
                          child: Text(
                            emptyMessage,
                            style: const TextStyle(
                              fontSize: 14,
                              color: PlannerStyle.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: gutter,
                    right: gutter,
                    bottom:
                        kBottomNavigationBarHeight +
                        MediaQuery.paddingOf(context).bottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: _center(
                          LessonCard(
                            key: ValueKey(lessons[index].id),
                            lesson: lessons[index],
                            onAction: onLessonAction,
                          ),
                        ),
                      ),
                      childCount: lessons.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  Widget _center(Widget child) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
