import 'package:sleep_buddy/core/db/app_db.dart';

class ProfileDao {
  static Future<String> getDisplayName() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'profiles',
      columns: ['display_name'],
      limit: 1,
    );
    return rows.isEmpty ? 'Người dùng' : rows.first['display_name'] as String;
  }
}
