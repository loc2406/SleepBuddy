import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/features/study_plan/presentation/cubit/study_planner_cubit.dart';
import 'package:sleep_buddy/features/study_plan/presentation/cubit/study_planner_state.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/day_progress_card.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/lesson_card.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/lesson_filter_bar.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/planner_header.dart';
import 'package:sleep_buddy/features/study_plan/presentation/widgets/week_day_selector.dart';

import '../model/models.dart';
import 'planner_style.dart';

class StudyPlannerScreen extends StatelessWidget {
  const StudyPlannerScreen({
    super.key,
    this.today,
    this.onFilterChanged,
    this.onLessonAction,
    this.onAddLesson,
    this.onAddMissionPressed,
    this.onNavigationSelected,
    this.selectedNavigationIndex = 1,
    this.title = 'Lịch trình học tập',
    this.listTitle = 'Nhiệm vụ hôm nay',
    this.addButtonLabel = 'Thêm nhiệm vụ mới',
    this.emptyMessage = 'Không có nhiệm vụ.',
    this.maxContentWidth = 600,
  }) : assert(maxContentWidth > 0);

  final DateTime? today;
  final ValueChanged<LessonFilter>? onFilterChanged;
  final ValueChanged<StudyLesson>? onLessonAction;
  final VoidCallback? onAddLesson;
  final Future<bool?> Function()? onAddMissionPressed;
  final ValueChanged<int>? onNavigationSelected;
  final int selectedNavigationIndex;
  final String title;
  final String listTitle;
  final String addButtonLabel;
  final String emptyMessage;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StudyPlannerCubit>();
    return BlocBuilder<StudyPlannerCubit, StudyPlannerState>(
      builder: (context, state) => Scaffold(
        backgroundColor: AppStyle.pageBackground(context),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: PlannerStyle.pageGradient(context),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, viewport) {
                final gutter = viewport.maxWidth < 300 ? 12.0 : 16.0;
                final addMission = onAddMissionPressed;

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 2),
                      sliver: SliverToBoxAdapter(
                        child: _center(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PlannerHeader(
                                title: title,
                                dateLabel: state.dateLabel,
                                onAddMissionPressed: addMission == null
                                    ? null
                                    : () => cubit.addMission(addMission),
                              ),
                              const SizedBox(height: 18),
                              WeekDaySelector(
                                days: state.days,
                                selectedDate: state.selectedDate,
                                today:
                                    today ?? DateUtils.dateOnly(DateTime.now()),
                                onDateSelected: cubit.selectDate,
                              ),
                              const SizedBox(height: 12),
                              DayProgressCard(
                                totalLessons: state.totalLessons,
                                completedLessons: state.completedLessons,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    listTitle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                      color: PlannerStyle.ink(context),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${state.totalLessons} bài học',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: PlannerStyle.secondary(context),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LessonFilterBar(
                                items: state.filters,
                                selected: state.selectedFilter,
                                onChanged: (filter) {
                                  cubit.selectFilter(filter);
                                  onFilterChanged?.call(filter);
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (state.isLoading)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        sliver: const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      )
                    else if (state.loadError != null)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        sliver: SliverToBoxAdapter(
                          child: _center(
                            context,
                            PlannerSurface(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Không thể tải nhiệm vụ: ${state.loadError}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: PlannerStyle.secondary(context),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: cubit.loadLessons,
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (state.visibleLessons.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: gutter),
                        sliver: SliverToBoxAdapter(
                          child: _center(
                            context,
                            PlannerSurface(
                              child: Text(
                                emptyMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: PlannerStyle.secondary(context),
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
                              context,
                              LessonCard(
                                key: ValueKey(state.visibleLessons[index].id),
                                lesson: state.visibleLessons[index],
                                onAction: onLessonAction,
                              ),
                            ),
                          ),
                          childCount: state.isLoading || state.loadError != null
                              ? 0
                              : state.visibleLessons.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _center(BuildContext context, Widget child) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
