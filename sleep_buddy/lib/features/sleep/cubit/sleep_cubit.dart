import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/db/sleep_dao.dart';
import 'package:sleep_buddy/core/notifications/task_reminder_notifications.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sleep_buddy/features/sleep/cubit/sleep_state.dart';

class SleepCubit extends Cubit<SleepState> {
  SleepCubit() : super(const SleepState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final data = await SleepDao.getLatest();
      if (isClosed) return;
      emit(state.copyWith(data: data, isLoading: false));
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải dữ liệu giấc ngủ: $error',
        ),
      );
    }
  }

  Future<bool> saveSleepRecord({
    required DateTime wakeDate,
    required TimeOfDay bedTime,
    required TimeOfDay wakeTime,
    required String notes,
  }) async {
    final data = state.data;
    if (data == null) return false;

    final interval = sleepIntervalForWakeDate(
      wakeDate: wakeDate,
      bedTime: bedTime,
      wakeTime: wakeTime,
    );
    final bedAt = interval.bedTime;
    final wakeAt = interval.wakeTime;

    if (!wakeAt.isBefore(DateTime.now())) {
      _emitError('Giờ thức dậy không thể nằm trong tương lai.');
      return false;
    }
    if (wakeAt.difference(bedAt) >= const Duration(days: 1)) {
      _emitError('Khoảng thời gian ngủ phải ngắn hơn 24 giờ.');
      return false;
    }

    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await SleepDao.saveSleepRecord(
        bedTime: bedAt,
        wakeTime: wakeAt,
        mood: data.mood,
        notes: notes,
        previousWakeTime: data.wakeTime,
      );
      final updatedData = await SleepDao.getLatest();
      if (isClosed) return false;
      emit(state.copyWith(data: updatedData, isSaving: false));
      return true;
    } on Object catch (error, stackTrace) {
      if (isClosed) return false;
      addError(error, stackTrace);
      emit(
        state.copyWith(
          isSaving: false,
          error: 'Không thể lưu nhật ký giấc ngủ: $error',
        ),
      );
      return false;
    }
  }

  Future<void> updateMood(SleepMood mood) async {
    final data = state.data;
    final wakeTime = data?.wakeTime;
    if (data == null || wakeTime == null || mood == data.mood) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await SleepDao.updateMood(wakeTime, mood);
      final updatedData = await SleepDao.getLatest();
      if (isClosed) return;
      emit(state.copyWith(data: updatedData, isSaving: false));
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        state.copyWith(
          isSaving: false,
          error: 'Không thể lưu cảm nhận về giấc ngủ: $error',
        ),
      );
    }
  }

  Future<void> updateTargetBedtime(TimeOfDay bedtime) async {
    final data = state.data;
    if (data == null) return;
    await _saveSettings(
      targetBedtime: bedtime,
      reminderTime: data.reminderTime,
      reminderEnabled: data.reminderEnabled,
    );
  }

  Future<void> updateReminderTime(TimeOfDay reminderTime) async {
    final data = state.data;
    if (data == null) return;
    await _saveSettings(
      targetBedtime: data.targetBedtime,
      reminderTime: reminderTime,
      reminderEnabled: data.reminderEnabled,
    );
  }

  Future<void> updateReminderEnabled(bool enabled) async {
    final data = state.data;
    if (data == null) return;
    await _saveSettings(
      targetBedtime: data.targetBedtime,
      reminderTime: data.reminderTime,
      reminderEnabled: enabled,
    );
  }

  void clearError() {
    if (state.error != null) emit(state.copyWith(clearError: true));
  }

  Future<void> _saveSettings({
    required TimeOfDay targetBedtime,
    required TimeOfDay reminderTime,
    required bool reminderEnabled,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final targetSleepMinutes = await SleepDao.getTargetSleepMinutes();
      await SleepDao.saveSettings(
        targetBedtime: targetBedtime,
        reminderTime: reminderTime,
        reminderEnabled: reminderEnabled,
        targetSleepMinutes: targetSleepMinutes,
      );
      final updatedData = await SleepDao.getLatest();
      if (isClosed) return;
      emit(state.copyWith(data: updatedData, isSaving: false));

      try {
        await TaskReminderNotifications.instance.syncScheduledReminders();
      } on Object catch (error, stackTrace) {
        if (isClosed) return;
        addError(error, stackTrace);
        emit(
          state.copyWith(
            error: 'Cài đặt đã lưu nhưng không thể cập nhật lịch nhắc: $error',
          ),
        );
      }
    } on Object catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(
        state.copyWith(
          isSaving: false,
          error: 'Không thể lưu cài đặt giấc ngủ: $error',
        ),
      );
    }
  }

  void _emitError(String message) {
    emit(state.copyWith(error: message));
  }

  static ({DateTime bedTime, DateTime wakeTime}) sleepIntervalForWakeDate({
    required DateTime wakeDate,
    required TimeOfDay bedTime,
    required TimeOfDay wakeTime,
  }) {
    final date = DateTime(wakeDate.year, wakeDate.month, wakeDate.day);
    final wakeAt = DateTime(
      date.year,
      date.month,
      date.day,
      wakeTime.hour,
      wakeTime.minute,
    );
    var bedAt = DateTime(
      date.year,
      date.month,
      date.day,
      bedTime.hour,
      bedTime.minute,
    );
    if (!bedAt.isBefore(wakeAt)) {
      bedAt = bedAt.subtract(const Duration(days: 1));
    }
    return (bedTime: bedAt, wakeTime: wakeAt);
  }
}
