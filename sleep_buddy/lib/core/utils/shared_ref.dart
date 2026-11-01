import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? _instance;

  // Theme
  static const String themeMode = 'theme_mode';

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
}
