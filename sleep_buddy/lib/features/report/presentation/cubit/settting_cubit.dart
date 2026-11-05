import 'package:flutter/src/foundation/basic_types.dart';
import 'package:flutter/src/material/app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleep_buddy/core/utils/shared_pref.dart';
import 'package:sleep_buddy/features/report/presentation/cubit/setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingState()) {
    getInitData();
  }

  Future<void> getInitData() async {
    final studyMinutes = await SharedPref.getStudyMinutes();
    final shortBreakMinutes = await SharedPref.getShortBreakMinutes();
    final longBreakMinutes = await SharedPref.getLongBreakMinutes();
    final isFinishSoundEnabled = await SharedPref.isFinishSoundEnabled();
    final themeMode = await SharedPref.getThemeMode();

    emit(
      state.copyWith(
        studyMinutes: studyMinutes,
        shortBreakMinutes: shortBreakMinutes,
        longBreakMinutes: longBreakMinutes,
        notificationEnabled: false,
        finishSoundEnabled: isFinishSoundEnabled,
        themeMode: themeMode,
      ),
    );
  }

  Future<void> changeNotification() async {
    final isEnabled = state.notificationEnabled;

    if (isEnabled) {
      emit(state.copyWith(notificationEnabled: false));
      return;
    } else {
      var status = await Permission.notification.status;

      if (status.isDenied) {
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        emit(state.copyWith(notificationEnabled: true));
        return;
      }

      if (status.isPermanentlyDenied) {
        emit(state.copyWith(notificationEnabled: false));
        await openAppSettings();
        return;
      }

      emit(state.copyWith(notificationEnabled: false));
    }
  }

  Future<void> syncNotificationPermission() async {
    final status = await Permission.notification.status;

    emit(state.copyWith(notificationEnabled: status.isGranted));
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
