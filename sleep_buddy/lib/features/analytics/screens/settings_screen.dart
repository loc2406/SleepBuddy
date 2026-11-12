import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/features/analytics/cubit/setting_state.dart';
import 'package:sleep_buddy/features/analytics/cubit/settting_cubit.dart';
import 'package:sleep_buddy/features/analytics/widgets/analytics_shell.dart';
import 'package:sleep_buddy/features/analytics/widgets/setting/duration_card.dart';
import 'package:sleep_buddy/features/analytics/widgets/setting/notification_card.dart';
import 'package:sleep_buddy/features/analytics/widgets/setting/theme_mode_card.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.onOpenLibrary,
    this.onSectionChanged,
    this.maxContentWidth = 600,
  });
  final ValueChanged<AnalyticsSection>? onSectionChanged;
  final double maxContentWidth;
  final void Function()? onOpenLibrary;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SettingCubit>().syncNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext c) => AnalyticsShell(
    title: 'Thống kê & Cài đặt',
    subtitle: 'Thiết lập nhịp học phù hợp với bạn.',
    section: AnalyticsSection.settings,
    onSectionChanged: widget.onSectionChanged,
    maxContentWidth: widget.maxContentWidth,
    children: [
      const SectionHeading('Thời lượng mặc định'),
      BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) => DurationCard(
          settings: DurationSettings(
            studyDuration: Duration(minutes: state.studyMinutes),
            shortBreak: Duration(minutes: state.shortBreakMinutes),
            longBreak: Duration(minutes: state.longBreakMinutes),
          ),
        ),
      ),
      const SizedBox(height: 4),
      const SectionHeading('Thông báo & Âm thanh'),
      BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) => NotificationCard(
          notificationsEnabled: state.notificationEnabled,
          soundEnabled: state.finishSoundEnabled,
          onNotificationsChanged: () async =>
              await context.read<SettingCubit>().changeNotification(),
          onSoundChanged: () async =>
              await context.read<SettingCubit>().changeFinishSound(),
        ),
      ),
      const SizedBox(height: 4),
      const SectionHeading('Giao diện'),
      BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) => ThemeModeCard(
          selected: state.themeMode,
          onChanged: (mode) async =>
              await context.read<SettingCubit>().changeThemeMode(mode),
        ),
      ),

      Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('open-library'),
          onTap: widget.onOpenLibrary,
          borderRadius: BorderRadius.circular(20),
          child: WellnessCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFF2EDFF), Color(0xFFEAE2FF)],
            ),
            child: Row(
              children: [
                const AssetIcon('book', size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cẩm nang học tập & Sức khỏe',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppStyle.ink(c),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tra cứu các phương pháp học và nghỉ ngơi.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppStyle.muted(c),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppStyle.purple),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: kBottomNavigationBarHeight),
    ],
  );
}
