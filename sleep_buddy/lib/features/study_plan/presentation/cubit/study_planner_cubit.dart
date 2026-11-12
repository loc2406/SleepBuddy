import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/cubit/minute_ticker_cubit.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/study_plan/presentation/cubit/study_planner_state.dart';
import 'package:sleep_buddy/features/study_plan/presentation/model/models.dart';

class StudyPlannerCubit extends Cubit<StudyPlannerState> {
  StudyPlannerCubit({required MinuteTickerCubit minuteTicker})
    : super(_initialState()) {
    _tickSubscription = minuteTicker.stream.listen(_handleMinuteTick);
    unawaited(loadLessons());
  }

  late final StreamSubscription<DateTime> _tickSubscription;
  int _loadGeneration = 0;
  bool _isCheckingExpiredTasks = false;

  static StudyPlannerState _initialState() {
    final now = DateTime.now();
    return StudyPlannerState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  Future<void> loadLessons() async {
    await _loadLessons(completeExpiredTasks: true);
  }

  Future<void> _loadLessons({required bool completeExpiredTasks}) async {
    final generation = ++_loadGeneration;
    final selectedDate = state.selectedDate;
    emit(state.copyWith(isLoading: true, clearLoadError: true));

    try {
      if (completeExpiredTasks) {
        await StudyTaskDao.completeExpiredInProgressTasks(DateTime.now());
      }
      final lessons = await StudyTaskDao.getByDate(selectedDate);
      if (isClosed || generation != _loadGeneration) return;
      emit(state.copyWith(lessons: lessons, isLoading: false));
    } on Exception catch (error) {
      if (isClosed || generation != _loadGeneration) return;
      emit(state.copyWith(loadError: error, isLoading: false));
    }
  }

  void _handleMinuteTick(DateTime now) {
    unawaited(_completeExpiredTasks(now));
  }

  Future<void> _completeExpiredTasks(DateTime now) async {
    if (_isCheckingExpiredTasks || isClosed) return;
    _isCheckingExpiredTasks = true;

    try {
      final updatedCount = await StudyTaskDao.completeExpiredInProgressTasks(
        now,
      );
      if (updatedCount > 0 && !isClosed) {
        await _loadLessons(completeExpiredTasks: false);
      }
    } on Exception catch (error) {
      if (isClosed) return;
      emit(state.copyWith(loadError: error, isLoading: false));
    } finally {
      _isCheckingExpiredTasks = false;
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

  @override
  Future<void> close() async {
    await _tickSubscription.cancel();
    await super.close();
  }
}
