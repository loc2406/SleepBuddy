import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/choice_strip.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/setting_row.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

class DurationSettingsCard extends StatelessWidget {
  const DurationSettingsCard(
      {super.key,
      required this.settings,
      this.onStudyTap,
      this.onShortBreakTap,
      this.onLongBreakTap});
  final WellnessSettings settings;
  final VoidCallback? onStudyTap, onShortBreakTap, onLongBreakTap;
  @override
  Widget build(BuildContext c) => WellnessCard(
          child: Column(children: [
        SettingRow(
            title: 'Phiên học',
            iconName: 'timer-nav',
            value: '${settings.studyDuration.inMinutes} phút',
            onTap: onStudyTap,
            actionKey: const ValueKey('study-duration')),
        Divider(height: 1, color: WellnessStyle.border(c)),
        SettingRow(
            title: 'Nghỉ ngắn',
            iconName: 'bed',
            value: '${settings.shortBreak.inMinutes} phút',
            onTap: onShortBreakTap,
            actionKey: const ValueKey('short-break')),
        Divider(height: 1, color: WellnessStyle.border(c)),
        SettingRow(
            title: 'Nghỉ dài',
            iconName: 'moon-nav',
            value: '${settings.longBreak.inMinutes} phút',
            onTap: onLongBreakTap,
            actionKey: const ValueKey('long-break')),
      ]));
}

class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard(
      {super.key,
      required this.notificationsEnabled,
      required this.soundEnabled,
      this.onNotificationsChanged,
      this.onSoundChanged});
  final bool notificationsEnabled, soundEnabled;
  final ValueChanged<bool>? onNotificationsChanged, onSoundChanged;
  @override
  Widget build(BuildContext c) => WellnessCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SettingRow(
            title: 'Cho phép thông báo',
            subtitle: 'Nhắc học, nghỉ và chuẩn bị ngủ',
            iconName: 'notification',
            switchValue: notificationsEnabled,
            onSwitchChanged: onNotificationsChanged,
            actionKey: const ValueKey('notifications-switch')),
        Divider(height: 1, color: WellnessStyle.border(c)),
        SettingRow(
            title: 'Chuông hết giờ',
            subtitle: 'Phát âm thanh khi kết thúc phiên',
            iconName: 'timer-nav',
            switchValue: soundEnabled,
            onSwitchChanged: onSoundChanged,
            actionKey: const ValueKey('sound-switch')),
        const SizedBox(height: 8),
        Text('Bạn có thể đổi quyền trong cài đặt thiết bị.',
            style: TextStyle(
                fontSize: 10.5, height: 1.4, color: WellnessStyle.muted(c))),
      ]));
}

class AppearanceSettingsCard extends StatelessWidget {
  const AppearanceSettingsCard(
      {super.key, required this.selected, this.onChanged});
  final ThemeMode selected;
  final ValueChanged<ThemeMode>? onChanged;
  @override
  Widget build(BuildContext c) => WellnessCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Chế độ hiển thị',
            style: TextStyle(fontSize: 14, color: WellnessStyle.ink(c))),
        const SizedBox(height: 12),
        ChoiceStrip(
            values: const [ThemeMode.light, ThemeMode.dark, ThemeMode.system],
            selected: selected,
            onChanged: onChanged,
            keyPrefix: 'theme',
            label: (v) => switch (v) {
                  ThemeMode.light => 'Sáng',
                  ThemeMode.dark => 'Tối',
                  ThemeMode.system => 'Hệ thống'
                }),
      ]));
}
