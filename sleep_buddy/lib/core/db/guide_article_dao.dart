import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/features/analytics/presentation/models/models.dart';

class GuideArticleDao {
  static const String table = 'guide_articles';

  static Future<void> seedIfEmpty() async {
    final db = await AppDatabase.instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $table'),
    );

    if (count != null && count > 0) return;

    await db.transaction((transaction) async {
      final articles = [
        {
          'id': 'pomodoro',
          'category': 'study',
          'title': 'Pomodoro: học tập theo từng phiên ngắn',
          'read_time_label': '4 phút đọc',
          'image_path': 'assets/wellness/book-glow.png',
          'cover_image': 0,
          'display_order': 0,
        },
        {
          'id': 'eyes',
          'category': 'relax',
          'title': '5 bài tập thư giãn mắt đơn giản',
          'read_time_label': '2 phút đọc',
          'image_path': 'assets/wellness/relaxation-thumb.png',
          'cover_image': 1,
          'display_order': 1,
        },
        {
          'id': 'sleep',
          'category': 'sleep',
          'title': 'Thói quen buổi tối để ngủ dễ dàng hơn',
          'read_time_label': '3 phút đọc',
          'image_path': 'assets/wellness/moon-card.png',
          'cover_image': 0,
          'display_order': 2,
        },
        {
          'id': 'memory',
          'category': 'study',
          'title': 'Ôn tập ngắt quãng: ghi nhớ lâu hơn',
          'read_time_label': '5 phút đọc',
          'image_path': 'assets/wellness/book.png',
          'cover_image': 0,
          'display_order': 3,
        },
      ];

      for (final article in articles) {
        await transaction.insert(
          table,
          article,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  static Future<List<GuideArticle>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      table,
      orderBy: 'display_order ASC',
    );

    return rows.map(_fromRow).toList();
  }

  static Future<List<GuideArticle>> getByCategory(
    GuideCategory category,
  ) async {
    final db = await AppDatabase.instance.database;

    final rows = await db.query(
      table,
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'display_order ASC',
    );

    return rows.map(_fromRow).toList();
  }

  static Future<List<GuideArticle>> search({
    required String searchText,
    required GuideCategory category,
  }) async {
    final db = await AppDatabase.instance.database;
    final keyword = searchText.trim();

    final conditions = <String>[];
    final arguments = <Object?>[];

    if (keyword.isNotEmpty) {
      conditions.add('LOWER(title) LIKE ?');
      arguments.add('%${keyword.toLowerCase()}%');
    }

    if (category != GuideCategory.all) {
      conditions.add('category = ?');
      arguments.add(category.name);
    }

    final rows = await db.query(
      table,
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: arguments.isEmpty ? null : arguments,
      orderBy: 'display_order ASC',
    );

    return rows.map(_fromRow).toList();
  }

  static GuideArticle _fromRow(Map<String, Object?> row) {
    return GuideArticle(
      id: row['id'] as String,
      category: GuideCategory.values.byName(row['category'] as String),
      title: row['title'] as String,
      readTimeLabel: row['read_time_label'] as String,
      image: AssetImage(row['image_path'] as String),
      coverImage: row['cover_image'] == 1,
    );
  }
}