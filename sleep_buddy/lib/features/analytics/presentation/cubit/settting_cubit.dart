import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleep_buddy/core/utils/shared_pref.dart';
import 'package:sleep_buddy/core/db/settings_dao.dart';
import 'package:sleep_buddy/core/notifications/task_reminder_notifications.dart';
import 'package:sleep_buddy/features/analytics/presentation/cubit/setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingState()) {
    getInitData();
  }

  Future<void> getInitData() async {
    final studyMinutes = await SettingsDao.getInt('study_duration_minutes', 30);
    final shortBreakMinutes = await SettingsDao.getInt(
      'short_break_minutes',
      5,
    );
    final longBreakMinutes = await SettingsDao.getInt('long_break_minutes', 15);
    final isFinishSoundEnabled = await SettingsDao.getBool(
      'finish_sound_enabled',
      false,
    );
    final isNotificationEnabled = await SettingsDao.getBool(
      'notifications_enabled',
      false,
    );
    final themeMode = await SharedPref.getThemeMode();

    emit(
      state.copyWith(
        studyMinutes: studyMinutes,
        shortBreakMinutes: shortBreakMinutes,
        longBreakMinutes: longBreakMinutes,
        notificationEnabled: isNotificationEnabled,
        finishSoundEnabled: isFinishSoundEnabled,
        themeMode: themeMode,
      ),
    );
  }

  Future<void> changeNotification() async {
    final isEnabled = state.notificationEnabled;

    if (isEnabled) {
      emit(state.copyWith(notificationEnabled: false));
      await SettingsDao.setBool('notifications_enabled', false);
      await TaskReminderNotifications.instance.cancelAll();
      return;
    } else {
      var status = await Permission.notification.status;

      if (status.isDenied) {
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        emit(state.copyWith(notificationEnabled: true));
        await SettingsDao.setBool('notifications_enabled', true);
        await TaskReminderNotifications.instance.syncScheduledReminders();
        return;
      }

      if (status.isPermanentlyDenied) {
        emit(state.copyWith(notificationEnabled: false));
        await SettingsDao.setBool('notifications_enabled', false);
        await openAppSettings();
        return;
      }

      emit(state.copyWith(notificationEnabled: false));
      await SettingsDao.setBool('notifications_enabled', false);
    }
  }

  Future<void> syncNotificationPermission() async {
    final status = await Permission.notification.status;
    emit(state.copyWith(notificationEnabled: status.isGranted));
    await SettingsDao.setBool('notifications_enabled', status.isGranted);
    await TaskReminderNotifications.instance.syncScheduledReminders();
  }

  Future<void> changeFinishSound() async {
    final enabled = !state.finishSoundEnabled;
    await SettingsDao.setBool('finish_sound_enabled', enabled);
    emit(state.copyWith(finishSoundEnabled: enabled));
  }

  Future<void> changeThemeMode(ThemeMode newMode) async {
    final saveMode = switch (newMode) {
      ThemeMode.light => true,
      ThemeMode.dark => false,
      ThemeMode.system => null,
    };
    final isSaved = await SharedPref.setBool(
      key: SharedPref.keyThemeMode,
      value: saveMode,
    );
    if (isSaved) {
      emit(state.copyWith(themeMode: newMode));
    }
  }
}
