import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? _instance;

  // Theme
  static const String keyThemeMode = 'theme_mode';
  static const String keyStudyMinutes = 'study_minutes';
  static const String keyShortBreakMinutes = 'short_break_minutes';
  static const String keyLongBreakMinutes = 'long_break_minutes';
  static const String keyFinishSoundEnabled = 'finish_sound_enabled';

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static Future<bool?> getBool(String key) async {
    if (_instance == null) await init();
    return _instance?.getBool(key);
  }

  static Future<bool> setBool({required String key, bool? value}) async {
    if (_instance == null) await init();
    if (value == null) return await _instance?.remove(key) ?? false;
    return await _instance?.setBool(key, value!) ?? false;
  }

  static Future<int?> getInt(String key) async {
    if (_instance == null) await init();
    return _instance?.getInt(key);
  }

  static Future<bool> setInt({required String key, required int value}) async {
    if (_instance == null) await init();
    return await _instance?.setInt(key, value) ?? false;
  }

  static Future<int> getStudyMinutes() async {
    return await getInt(keyStudyMinutes) ?? 30;
  }

  static Future<int> getShortBreakMinutes() async {
    return await getInt(keyShortBreakMinutes) ?? 5;
  }

  static Future<int> getLongBreakMinutes() async {
    return await getInt(keyLongBreakMinutes) ?? 15;
  }

  static Future<bool> isFinishSoundEnabled() async {
    return await getBool(keyFinishSoundEnabled) ?? false;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    await setBool(key: keyFinishSoundEnabled, value: enabled);
  }

  static Future<ThemeMode> getThemeMode() async {
    final themeMode = await getBool(keyThemeMode);
    return switch (themeMode) {
      true => ThemeMode.light,
      false => ThemeMode.dark,
      null => ThemeMode.system,
    };
  }
}
