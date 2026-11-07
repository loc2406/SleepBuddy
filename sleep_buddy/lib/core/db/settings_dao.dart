import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sqflite/sqflite.dart';

class SettingsDao {
  static Future<Map<String, String>> getAppSettings() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('app_settings');
    return {
      for (final row in rows) row['key'] as String: row['value'] as String,
    };
  }

  static Future<int> getInt(String key, int defaultValue) async {
    final settings = await getAppSettings();
    return int.tryParse(settings[key] ?? '') ?? defaultValue;
  }

  static Future<bool> getBool(String key, bool defaultValue) async {
    final settings = await getAppSettings();
    final value = settings[key];
    return value == null ? defaultValue : value.toLowerCase() == 'true';
  }

  static Future<void> setValue(String key, String value) async {
    final db = await AppDatabase.instance.database;
    await db.insert('app_settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> setInt(String key, int value) =>
      setValue(key, value.toString());

  static Future<void> setBool(String key, bool value) =>
      setValue(key, value.toString());
}
