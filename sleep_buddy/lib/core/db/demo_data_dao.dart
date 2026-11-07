import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/core/db/seed_dao.dart';
import 'package:sleep_buddy/core/db/guide_article_dao.dart';

enum DemoDataMode { populated, empty }

class DemoDataDao {
  static Future<void> applyMode(DemoDataMode mode) async {
    if (mode == DemoDataMode.empty) {
      await clearDemoData();
      return;
    }
    await SeedDao.seedIfEmpty();
  }

  static Future<void> clearDemoData() async {
    final db = await AppDatabase.instance.database;

    await db.transaction((tx) async {
      await tx.delete('guide_bookmarks');
      await tx.delete('guide_progress');
      await tx.delete('guide_steps');
      await tx.delete('guide_articles');
      await tx.delete('focus_sessions');
      await tx.delete('study_tasks');
      await tx.delete('daily_goals');
      await tx.delete('activity_logs');
      await tx.delete('sleep_logs');
      await tx.delete('sleep_settings');
      await tx.delete('subjects');
      await tx.delete('profiles');
    });
  }

  static Future<void> restoreDemoData() async {
    await clearDemoData();
    await GuideArticleDao.seedIfEmpty();
    await SeedDao.seedIfEmpty();
  }

  static Future<Map<String, int>> getDataCounts() async {
    final db = await AppDatabase.instance.database;
    final tables = <String>[
      'profiles',
      'subjects',
      'study_tasks',
      'focus_sessions',
      'sleep_logs',
      'guide_articles',
      'daily_goals',
      'activity_logs',
    ];
    final counts = <String, int>{};

    for (final table in tables) {
      final rows = await db.rawQuery('SELECT COUNT(*) AS count FROM $table');
      counts[table] = (rows.first['count'] as num?)?.toInt() ?? 0;
    }
    return counts;
  }
}
