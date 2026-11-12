import 'package:flutter/foundation.dart';
import 'package:sleep_buddy/features/study_plan/presentation/model/models.dart';

@immutable
class StudyPlannerState {
  const StudyPlannerState({
    required this.selectedDate,
    this.selectedFilter = LessonFilter.all,
    this.lessons = const [],
    this.isLoading = true,
    this.loadError,
  });

  final DateTime selectedDate;
  final LessonFilter selectedFilter;
  final List<StudyLesson> lessons;
  final bool isLoading;
  final Object? loadError;

  int get totalLessons => lessons.length;

  int get completedLessons =>
      lessons.where((lesson) => lesson.status == LessonStatus.completed).length;

  List<StudyLesson> get visibleLessons => selectedFilter == LessonFilter.all
      ? lessons
      : lessons
            .where((lesson) => lesson.status.name == selectedFilter.name)
            .toList();

  List<PlannerFilterItem> get filters {
    final counts = {for (final status in LessonStatus.values) status: 0};
    for (final lesson in lessons) {
      counts.update(lesson.status, (count) => count + 1);
    }

    return [
      PlannerFilterItem(
        value: LessonFilter.all,
        label: 'Tất cả',
        count: lessons.length,
      ),
      PlannerFilterItem(
        value: LessonFilter.notStarted,
        label: 'Chưa học',
        count: counts[LessonStatus.notStarted]!,
      ),
      PlannerFilterItem(
        value: LessonFilter.inProgress,
        label: 'Đang học',
        count: counts[LessonStatus.inProgress]!,
      ),
      PlannerFilterItem(
        value: LessonFilter.completed,
        label: 'Đã học',
        count: counts[LessonStatus.completed]!,
      ),
    ];
  }

  List<DateTime> get days {
    final weekStart = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    ).subtract(Duration(days: selectedDate.weekday - 1));
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  String get dateLabel =>
      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

  StudyPlannerState copyWith({
    DateTime? selectedDate,
    LessonFilter? selectedFilter,
    List<StudyLesson>? lessons,
    bool? isLoading,
    Object? loadError,
    bool clearLoadError = false,
  }) => StudyPlannerState(
    selectedDate: selectedDate ?? this.selectedDate,
    selectedFilter: selectedFilter ?? this.selectedFilter,
    lessons: lessons ?? this.lessons,
    isLoading: isLoading ?? this.isLoading,
    loadError: clearLoadError ? null : loadError ?? this.loadError,
  );
}
