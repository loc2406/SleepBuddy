import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/study_plan/cubit/study_planner_state.dart';
import 'package:sleep_buddy/features/study_plan/model/models.dart';

class StudyPlannerCubit extends Cubit<StudyPlannerState> {
  StudyPlannerCubit() : super(_initialState()) {
    loadLessons();
  }

  int _loadGeneration = 0;

  static StudyPlannerState _initialState() {
    final now = DateTime.now();
    return StudyPlannerState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  Future<void> loadLessons() async {
    final generation = ++_loadGeneration;
    final selectedDate = state.selectedDate;
    emit(state.copyWith(isLoading: true, clearLoadError: true));

    try {
      final lessons = await StudyTaskDao.getByDate(selectedDate);
      if (isClosed || generation != _loadGeneration) return;
      emit(state.copyWith(lessons: lessons, isLoading: false));
    } on Exception catch (error) {
      if (isClosed || generation != _loadGeneration) return;
      emit(state.copyWith(loadError: error, isLoading: false));
    }
  }

  void selectDate(DateTime date) {
    final selectedDate = DateTime(date.year, date.month, date.day);
    if (selectedDate == state.selectedDate) return;
    emit(state.copyWith(selectedDate: selectedDate));
    loadLessons();
  }

  void selectFilter(LessonFilter filter) {
    if (filter == state.selectedFilter) return;
    emit(state.copyWith(selectedFilter: filter));
  }

  Future<void> addMission(Future<bool?> Function() openAddMission) async {
    final created = await openAddMission();
    if (created == true && !isClosed) await loadLessons();
  }
}
