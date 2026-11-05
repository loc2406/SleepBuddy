import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/report/presentation/widgets/setting/setting_row.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class DurationCard extends StatelessWidget {
  const DurationCard({super.key, required this.settings});
  final DurationSettings settings;
  @override
  Widget build(BuildContext c) => WellnessCard(
    padding: EdgeInsetsGeometry.symmetric(vertical: 0, horizontal: 16),
    child: Column(
      children: [
        SettingRow(
          title: 'Phiên học',
          icon: Icons.timer,
          value: '${settings.studyDuration.inMinutes} phút',
          actionKey: const ValueKey('study-duration'),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        Divider(height: 1, color: AppStyle.border(c)),
        SettingRow(
          title: 'Nghỉ ngắn',
          icon: Icons.bed,
          value: '${settings.shortBreak.inMinutes} phút',
          actionKey: const ValueKey('short-break'),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        Divider(height: 1, color: AppStyle.border(c)),
        SettingRow(
          title: 'Nghỉ dài',
          icon: Icons.nightlight,
          value: '${settings.longBreak.inMinutes} phút',
          actionKey: const ValueKey('long-break'),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ],
    ),
  );
}
