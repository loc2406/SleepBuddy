import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/cubit/minute_ticker_cubit.dart';
import 'package:sleep_buddy/core/db/dashboard_dao.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/overview/cubit/overview_state.dart';

class OverviewCubit extends Cubit<OverviewState> {
  OverviewCubit({required MinuteTickerCubit minuteTicker})
    : super(_initialState()) {
    _tickSubscription = minuteTicker.stream.listen(_updateClock);
  }

  late final StreamSubscription<DateTime> _tickSubscription;

  static OverviewState _initialState() {
    final now = DateTime.now();
    return OverviewState(
      currentTime: now,
      timeUntilEndOfDay: _timeUntilEndOfDay(now),
    );
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearLoadError: true));

    final now = DateTime.now();
    try {
      final durations = await DashboardDao.getStudyAndBreakDuration(now);
      final nextTask = await DashboardDao.getNextTask(now);
      final taskProgress = await StudyTaskDao.getTaskProgressByDate(now);
      final subjectMinutes = await DashboardDao.getStudyMinutesBySubject(
        now.subtract(const Duration(days: 1)),
        now,
      );
      if (isClosed) return;

      emit(
        OverviewState(
          isLoading: false,
          studyMinutes: durations['focus_minutes'] ?? 0,
          restMinutes: durations['break_minutes'] ?? 0,
          completedTasks: taskProgress.completed,
          totalTasks: taskProgress.total,
          nextTask: nextTask,
          subjectMinutes: subjectMinutes,
          currentTime: now,
          timeUntilEndOfDay: _timeUntilEndOfDay(now),
        ),
      );
    } on Exception catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(state.copyWith(isLoading: false, loadError: error));
    }
  }

  void _updateClock(DateTime now) {
    final dayChanged =
        now.year != state.currentTime.year ||
        now.month != state.currentTime.month ||
        now.day != state.currentTime.day;

    emit(
      state.copyWith(
        currentTime: now,
        timeUntilEndOfDay: _timeUntilEndOfDay(now),
      ),
    );
    if (dayChanged) unawaited(loadData());
  }

  static Duration _timeUntilEndOfDay(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1).difference(now);

  @override
  Future<void> close() async {
    await _tickSubscription.cancel();
    await super.close();
  }
}
