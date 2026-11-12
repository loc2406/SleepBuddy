import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

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
          'tag': 'Học tập',
          'title': 'Pomodoro: học tập theo từng phiên ngắn',
          'subtitle':
              'Chia thời gian học thành các phiên ngắn để duy trì tập trung.',
          'read_time_label': '4 phút đọc',
          'image_path': 'assets/wellness/book-glow.png',
          'hero_image_path': 'assets/wellness/book-glow.png',
          'golden_rule_title': 'Quy tắc vàng',
          'golden_rule_description':
              'Học sâu trong 25 phút, nghỉ ngắn và lặp lại đều đặn.',
          'applied_count': 128,
          'cover_image': 0,
          'display_order': 0,
        },
        {
          'id': 'eyes',
          'category': 'relax',
          'tag': 'Giãn cơ',
          'title': '5 bài tập thư giãn mắt đơn giản',
          'subtitle':
              'Bảo vệ mắt khỏi mỏi khi học hoặc làm việc lâu trên màn hình.',
          'read_time_label': '2 phút đọc',
          'image_path': 'assets/wellness/relaxation-thumb.png',
          'hero_image_path': 'assets/wellness/relaxation-thumb.png',
          'golden_rule_title': 'Quy tắc vàng',
          'golden_rule_description':
              'Cứ 20 phút nhìn xa trong 20 giây để thư giãn cơ mắt.',
          'applied_count': 256,
          'cover_image': 1,
          'display_order': 1,
        },
        {
          'id': 'sleep',
          'category': 'sleep',
          'tag': 'Giấc ngủ',
          'title': 'Thói quen buổi tối để ngủ dễ dàng hơn',
          'subtitle':
              'Chuẩn bị cho cơ thể một chuỗi tín hiệu thư giãn trước giờ ngủ.',
          'read_time_label': '3 phút đọc',
          'image_path': 'assets/wellness/moon-card.png',
          'hero_image_path': 'assets/wellness/moon-card.png',
          'golden_rule_title': 'Quy tắc vàng',
          'golden_rule_description':
              'Điều chỉnh đèn, thiết bị và nhịp sinh học trước giờ ngủ.',
          'applied_count': 184,
          'cover_image': 0,
          'display_order': 2,
        },
        {
          'id': 'memory',
          'category': 'study',
          'tag': 'Học tập',
          'title': 'Ôn tập ngắt quãng: ghi nhớ lâu hơn',
          'subtitle':
              'Lên lịch ôn lại theo khoảng cách để củng cố trí nhớ dài hạn.',
          'read_time_label': '5 phút đọc',
          'image_path': 'assets/wellness/book.png',
          'hero_image_path': 'assets/wellness/book.png',
          'golden_rule_title': 'Quy tắc vàng',
          'golden_rule_description':
              'Ôn lại trước khi gần quên để tăng độ bền của ghi nhớ.',
          'applied_count': 96,
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
    final rows = await db.query(table, orderBy: 'display_order ASC');

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
