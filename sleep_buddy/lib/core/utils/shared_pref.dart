import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? _instance;

  // Theme
  static const String themeMode = 'theme_mode';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyFocusMinutes = 'focus_minutes';
  static const String keyBreakMinutes = 'break_minutes';

  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static Future<bool> getBool(String key) async {
    if (_instance == null) await init();
    return _instance?.getBool(key) ?? false;
  }

  static Future<bool> setBool({
    required String key,
    required bool value,
  }) async {
    if (_instance == null) await init();
    return await _instance?.setBool(key, value) ?? false;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    await setBool(key: keySoundEnabled, value: enabled);
  }

  static Future<bool> isSoundEnabled() async {
    return getBool(keySoundEnabled);
  }
}
