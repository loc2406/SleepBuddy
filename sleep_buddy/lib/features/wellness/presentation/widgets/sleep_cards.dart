import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/report/presentation/widgets/setting/setting_row.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/choice_strip.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

class SleepSummaryCard extends StatelessWidget {
  const SleepSummaryCard({
    super.key,
    required this.data,
    this.illustration = const AssetImage('assets/wellness/cat-clouds.png'),
  });
  final SleepData data;
  final ImageProvider illustration;
  @override
  Widget build(BuildContext c) {
    final fraction = safeFraction(
      data.recordedDuration.inSeconds,
      data.targetDuration.inSeconds,
    );
    final missing = data.targetDuration > data.recordedDuration
        ? data.targetDuration - data.recordedDuration
        : Duration.zero;
    return WellnessCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFE2DCFF), Color(0xFFF4EFFF)],
      ),
      child: LayoutBuilder(
        builder: (c, box) {
          final narrow =
              box.maxWidth < 280 || MediaQuery.textScalerOf(c).scale(14) > 20;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelBadge(data.periodLabel),
              const SizedBox(height: 10),
              Text(
                durationLabel(data.recordedDuration),
                style: TextStyle(
                  fontSize: 34,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppStyle.ink(c),
                ),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow) ...[
                Image(
                  image: illustration,
                  width: 110,
                  height: 72,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 8),
                copy,
              ] else
                Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 8),
                    Image(
                      image: illustration,
                      width: 120,
                      height: 84,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Text(
                'Mục tiêu ${durationLabel(data.targetDuration)} • ${missing == Duration.zero ? 'Đạt mục tiêu' : 'Còn thiếu ${durationLabel(missing)}'}',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: AppStyle.muted(c),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GradientProgress(
                      value: fraction,
                      label: 'Mục tiêu giấc ngủ',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(fraction * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppStyle.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                'Thời lượng tính từ giờ ngủ và thức dậy',
                style: TextStyle(fontSize: 10.5, color: AppStyle.muted(c)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SleepRecordCard extends StatelessWidget {
  const SleepRecordCard({
    super.key,
    required this.bedTime,
    required this.wakeTime,
    this.onEdit,
  });
  final DateTime bedTime, wakeTime;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext c) {
    Widget info(String label, String asset, DateTime value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AssetIcon(asset, size: 19),
            Text(
              label,
              style: TextStyle(fontSize: 12.5, color: AppStyle.muted(c)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          timeLabel(TimeOfDay.fromDateTime(value)),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppStyle.ink(c),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          dateLabel(value),
          style: TextStyle(fontSize: 11, color: AppStyle.muted(c)),
        ),
      ],
    );
    return WellnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (c, box) {
              final left = info('Đi ngủ', 'bed', bedTime),
                  right = info('Thức dậy', 'timer-nav', wakeTime);
              if (box.maxWidth < 240 ||
                  MediaQuery.textScalerOf(c).scale(14) > 23)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 18), right],
                );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  Container(
                    width: 1,
                    height: 68,
                    color: AppStyle.border(c),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(child: right),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const ValueKey('edit-sleep'),
              onPressed: onEdit,
              child: const Text(
                'Chỉnh sửa',
                style: TextStyle(fontSize: 11, color: AppStyle.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SleepPlanCard extends StatelessWidget {
  const SleepPlanCard({
    super.key,
    required this.bedtime,
    required this.reminderTime,
    required this.reminderEnabled,
    this.onBedtimeTap,
    this.onReminderChanged,
  });
  final TimeOfDay bedtime, reminderTime;
  final bool reminderEnabled;
  final VoidCallback? onBedtimeTap;
  final ValueChanged<bool>? onReminderChanged;
  @override
  Widget build(BuildContext c) => WellnessCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const AssetIcon('moon-card', size: 20),
            Text(
              'Kế hoạch tối nay',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppStyle.ink(c),
              ),
            ),
          ],
        ),
        SettingRow(
          title: 'Giờ ngủ mục tiêu',
          value: timeLabel(bedtime),
          onTap: onBedtimeTap,
          actionKey: const ValueKey('target-bedtime'),
        ),
        Divider(height: 1, color: AppStyle.border(c)),
        SettingRow(
          title: 'Nhắc chuẩn bị ngủ',
          subtitle: '${timeLabel(reminderTime)} · Trước giờ ngủ',
          switchValue: reminderEnabled,
          onSwitchChanged: null,
          actionKey: const ValueKey('sleep-reminder'),
        ),
      ],
    ),
  );
}

class SleepMoodCard extends StatelessWidget {
  const SleepMoodCard({super.key, required this.selected, this.onChanged});
  final SleepMood selected;
  final ValueChanged<SleepMood>? onChanged;
  @override
  Widget build(BuildContext c) => WellnessCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sáng nay bạn cảm thấy thế nào?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppStyle.ink(c),
          ),
        ),
        const SizedBox(height: 12),
        ChoiceStrip(
          values: SleepMood.values,
          selected: selected,
          onChanged: onChanged,
          keyPrefix: 'mood',
          gradientSelection: false,
          label: (v) => switch (v) {
            SleepMood.refreshed => 'Tỉnh táo',
            SleepMood.normal => 'Bình thường',
            SleepMood.tired => 'Mệt mỏi',
          },
        ),
      ],
    ),
  );
}
