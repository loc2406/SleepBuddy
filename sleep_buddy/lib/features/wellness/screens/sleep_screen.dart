import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/analytics/widgets/guide_card.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sleep_buddy/features/wellness/widgets/app_shell.dart';
import 'package:sleep_buddy/features/wellness/widgets/sleep_cards.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen(
      {super.key,
      required this.data,
      required this.guides,
      this.onEditRecord,
      this.onBedtimeTap,
      this.onReminderChanged,
      this.onMoodChanged,
      this.onGuideOpen,
      this.onMoreGuides,
      this.onNavigation,
      this.onNotification,
      this.maxContentWidth = 600});
  final SleepData data;
  final List<GuideArticle> guides;
  final VoidCallback? onEditRecord, onBedtimeTap, onMoreGuides, onNotification;
  final ValueChanged<bool>? onReminderChanged;
  final ValueChanged<SleepMood>? onMoodChanged;
  final ValueChanged<GuideArticle>? onGuideOpen;
  final ValueChanged<int>? onNavigation;
  final double maxContentWidth;
  @override
  Widget build(BuildContext c) => WellnessShell(
          title: 'Giấc ngủ & Sức khỏe',
          subtitle: 'Ngủ đủ giấc, học tập trọn vẹn hơn.',
          navigationIndex: 3,
          onNavigation: onNavigation,
          onNotification: onNotification,
          maxContentWidth: maxContentWidth,
          children: [
            SleepSummaryCard(data: data),
            SleepRecordCard(
                bedTime: data.bedTime,
                wakeTime: data.wakeTime,
                onEdit: onEditRecord),
            SleepPlanCard(
                bedtime: data.targetBedtime,
                reminderTime: data.reminderTime,
                reminderEnabled: data.reminderEnabled,
                onBedtimeTap: onBedtimeTap,
                onReminderChanged: onReminderChanged),
            SleepMoodCard(selected: data.mood, onChanged: onMoodChanged),
            AdviceCard(
                title: 'Gợi ý cho hôm nay', message: data.recommendation),
            SectionHeading('Cẩm nang giấc ngủ', onMore: onMoreGuides),
            for (final article in guides)
              GuideCard(article: article, onOpen: onGuideOpen),
          ]);
}
