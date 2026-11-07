import 'package:flutter/material.dart';

class SettingState {
  final int studyMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final bool notificationEnabled;
  final bool finishSoundEnabled;
  final ThemeMode themeMode;

  const SettingState({
    this.studyMinutes = 0,
    this.shortBreakMinutes = 0,
    this.longBreakMinutes = 0,
    this.notificationEnabled = false,
    this.finishSoundEnabled = false,
    this.themeMode = ThemeMode.light
  });

  SettingState copyWith({
    int? studyMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    bool? notificationEnabled,
    bool? finishSoundEnabled,
    ThemeMode? themeMode
  }) => SettingState(
    studyMinutes: studyMinutes ?? this.studyMinutes,
    shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
    longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
    notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    finishSoundEnabled: finishSoundEnabled ?? this.finishSoundEnabled,
    themeMode: themeMode?? this.themeMode
  );
}
