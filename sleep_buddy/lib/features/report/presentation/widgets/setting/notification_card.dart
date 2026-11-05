import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/report/presentation/widgets/setting/setting_row.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notificationsEnabled,
    required this.soundEnabled,
    this.onNotificationsChanged,
    // this.onSoundChanged,
  });
  final bool notificationsEnabled, soundEnabled;
  // final ValueChanged<bool>? onSoundChanged;
  final void Function()? onNotificationsChanged;
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
        // Divider(height: 1, color: WellnessStyle.border(c)),
        // SettingRow(
        //   title: 'Chuông hết giờ',
        //   subtitle: 'Phát âm thanh khi kết thúc phiên',
        //   icon: Icons.timer,
        //   switchValue: soundEnabled,
        //   onSwitchChanged: null,
        //   actionKey: const ValueKey('sound-switch'),
        // ),
      ],
    ),
  );
}
