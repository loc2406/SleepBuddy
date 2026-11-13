import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/analytics/widgets/setting/setting_row.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notificationsEnabled,
    required this.soundEnabled,
    this.onNotificationsChanged,
    this.onSoundChanged,
  });
  final bool notificationsEnabled, soundEnabled;
  final void Function()? onNotificationsChanged;
  final void Function()? onSoundChanged;
  @override
  Widget build(BuildContext c) => WellnessCard(
    padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 16),
    child: Column(
      children: [
        SettingRow(
          title: 'Cho phép thông báo',
          subtitle: 'Nhắc học, nghỉ và chuẩn bị ngủ',
          icon: Icons.notifications_active,
          switchValue: notificationsEnabled,
          onSwitchChanged: onNotificationsChanged,
          actionKey: const ValueKey('notifications-switch'),
        ),
      ],
    ),
  );
}
