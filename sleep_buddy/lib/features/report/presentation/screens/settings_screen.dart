import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/report/domain/model/settings_cards.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/app_shell.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen(
      {super.key,
      required this.settings,
      this.onStudyTap,
      this.onShortBreakTap,
      this.onLongBreakTap,
      this.onNotificationsChanged,
      this.onSoundChanged,
      this.onThemeChanged,
      this.onOpenLibrary,
      this.onSectionChanged,
      this.onNotification,
      this.maxContentWidth = 600,
      this.saveStatusLabel = 'Các thay đổi được lưu tự động'});
  final WellnessSettings settings;
  final VoidCallback? onStudyTap,
      onShortBreakTap,
      onLongBreakTap,
      onOpenLibrary,
      onNotification;
  final ValueChanged<bool>? onNotificationsChanged, onSoundChanged;
  final ValueChanged<ThemeMode>? onThemeChanged;
  final ValueChanged<AnalyticsSection>? onSectionChanged;
  final double maxContentWidth;
  final String saveStatusLabel;
  @override
  Widget build(BuildContext c) => WellnessShell(
          title: 'Thống kê & Cài đặt',
          subtitle: 'Thiết lập nhịp học phù hợp với bạn.',
          navigationIndex: 4,
          section: AnalyticsSection.settings,
          onSectionChanged: onSectionChanged,
          onNotification: onNotification,
          maxContentWidth: maxContentWidth,
          children: [
            const SectionHeading('Thời lượng mặc định'),
            DurationSettingsCard(
                settings: settings,
                onStudyTap: onStudyTap,
                onShortBreakTap: onShortBreakTap,
                onLongBreakTap: onLongBreakTap),
            const SizedBox(height: 4),
            const SectionHeading('Thông báo & Âm thanh'),
            NotificationSettingsCard(
                notificationsEnabled: settings.notificationsEnabled,
                soundEnabled: settings.soundEnabled,
                onNotificationsChanged: onNotificationsChanged,
                onSoundChanged: onSoundChanged),
            const SizedBox(height: 4),
            const SectionHeading('Giao diện'),
            AppearanceSettingsCard(
                selected: settings.themeMode, onChanged: onThemeChanged),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(saveStatusLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11.5, color: WellnessStyle.muted(c)))),
            Material(
                color: Colors.transparent,
                child: InkWell(
                    key: const ValueKey('open-library'),
                    onTap: onOpenLibrary,
                    borderRadius: BorderRadius.circular(20),
                    child: WellnessCard(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFF2EDFF), Color(0xFFEAE2FF)]),
                        child: Row(children: [
                          const AssetIcon('book', size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Cẩm nang học tập & Sức khỏe',
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: WellnessStyle.ink(c))),
                                const SizedBox(height: 5),
                                Text(
                                    'Tra cứu các phương pháp học và nghỉ ngơi.',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: WellnessStyle.muted(c))),
                              ])),
                          const Icon(Icons.chevron_right_rounded,
                              color: WellnessStyle.purple),
                        ])))),
          ]);
}
