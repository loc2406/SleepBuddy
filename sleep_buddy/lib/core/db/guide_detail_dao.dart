import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/db/app_db.dart';
import 'package:sleep_buddy/features/analytics/model/guide_detail_model.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

class GuideDetailDao {
  static Future<GuideDetailData?> getByArticle(GuideArticle article) async {
    final db = await AppDatabase.instance.database;
    final articleRows = await db.query(
      'guide_articles',
      where: 'id = ?',
      whereArgs: [article.id],
      limit: 1,
    );
    if (articleRows.isEmpty) return null;

    final row = articleRows.first;
    final stepRows = await db.query(
      'guide_steps',
      where: 'article_id = ?',
      whereArgs: [article.id],
      orderBy: 'step_number ASC',
    );
    final progressRows = await db.query(
      'guide_progress',
      where: 'article_id = ?',
      whereArgs: [article.id],
      limit: 1,
    );
    final appliedCount = progressRows.isEmpty
        ? row['applied_count'] as int? ?? 0
        : progressRows.first['applied_count'] as int? ??
              row['applied_count'] as int? ??
              0;

    return GuideDetailData(
      id: article.id,
      tag: row['tag'] as String,
      title: row['title'] as String,
      subtitle: row['subtitle'] as String? ?? '',
      readTimeLabel: row['read_time_label'] as String,
      appliedCountLabel: appliedCount.toString(),
      heroImage: AssetImage(row['hero_image_path'] as String),
      goldenRuleTitle: row['golden_rule_title'] as String,
      goldenRuleDescription: row['golden_rule_description'] as String,
      steps: stepRows
          .map(
            (step) => GuideStep(
              number: step['step_number'] as int,
              title: step['title'] as String,
              description: step['description'] as String,
            ),
          )
          .toList(),
    );
  }
}
