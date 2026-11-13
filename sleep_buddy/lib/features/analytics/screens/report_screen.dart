import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sleep_buddy/features/analytics/widgets/report_cards.dart';
import 'package:sleep_buddy/features/sleep/widgets/app_shell.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({
    super.key,
    required this.data,
    this.onPeriodChanged,
    this.onSectionChanged,
    this.onNavigation,
    this.onNotification,
    this.maxContentWidth = 600,
  });
  final ReportData data;
  final ValueChanged<ReportPeriod>? onPeriodChanged;
  final ValueChanged<AnalyticsSection>? onSectionChanged;
  final ValueChanged<int>? onNavigation;
  final VoidCallback? onNotification;
  final double maxContentWidth;
  @override
  Widget build(BuildContext c) => AppShell(
    title: 'Thống kê & Cài đặt',
    subtitle: 'Nhìn lại tiến bộ, tìm nhịp học phù hợp.',
    section: AnalyticsSection.report,
    onSectionChanged: onSectionChanged,
    maxContentWidth: maxContentWidth,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppStyle.tinted(c).withValues(alpha: .55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: AppStyle.muted(c),
                ),
                const SizedBox(width: 6),
                Text(
                  data.rangeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.muted(c),
                    letterSpacing: .1,
                  ),
                ),
              ],
            ),
          ),
          _ReportPeriodPicker(period: data.period, onChanged: onPeriodChanged),
        ],
      ),
      LayoutBuilder(
        builder: (c, box) {
          final study = MetricCard(
            title: 'Tổng giờ học',
            value: durationLabel(data.studyTime),
            caption: data.metricCaption,
            iconName: 'graduation-cap',
          );
          final rest = MetricCard(
            title: 'Tổng giờ nghỉ',
            value: durationLabel(data.restTime),
            caption: data.metricCaption,
            iconName: 'bed',
            colors: const [Color(0xFFFCF9FF), Color(0xFFE9DEFF)],
          );
          if (box.maxWidth < 320 || MediaQuery.textScalerOf(c).scale(14) > 20) {
            return Column(children: [study, const SizedBox(height: 12), rest]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: study),
              const SizedBox(width: 12),
              Expanded(child: rest),
            ],
          );
        },
      ),
      StudyTimeChartCard(points: data.dailyBars, title: data.chartTitle),
      SubjectTimeCard(
        subjects: data.subjects,
        title: switch (data.period) {
          ReportPeriod.day => 'Thời gian theo môn học trong ngày',
          ReportPeriod.week => 'Thời gian theo môn học trong tuần',
          ReportPeriod.month => 'Thời gian theo môn học trong tháng',
        },
      ),
      PlanCompletionCard(
        completed: data.completedLessons,
        total: data.totalLessons,
      ),
    ],
  );
}

class _ReportPeriodPicker extends StatelessWidget {
  const _ReportPeriodPicker({required this.period, required this.onChanged});

  final ReportPeriod period;
  final ValueChanged<ReportPeriod>? onChanged;

  static String _label(ReportPeriod period) => switch (period) {
    ReportPeriod.day => 'Hôm nay',
    ReportPeriod.week => 'Tuần này',
    ReportPeriod.month => 'Tháng này',
  };

  @override
  Widget build(BuildContext context) {
    final borderColor = AppStyle.border(context);

    return Material(
      color: AppStyle.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor),
      ),
      child: PopupMenuButton<ReportPeriod>(
        key: const ValueKey('period-picker'),
        enabled: onChanged != null,
        initialValue: period,
        tooltip: 'Khoảng thống kê',
        color: AppStyle.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor),
        ),
        onSelected: onChanged,
        itemBuilder: (context) => ReportPeriod.values
            .map(
              (value) => PopupMenuItem<ReportPeriod>(
                key: ValueKey('period-${value.name}'),
                value: value,
                height: 42,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _label(value),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: value == period
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: value == period
                              ? AppStyle.purple
                              : AppStyle.ink(context),
                        ),
                      ),
                    ),
                    if (value == period)
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppStyle.purple,
                      ),
                  ],
                ),
              ),
            )
            .toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppStyle.purple,
              ),
              const SizedBox(width: 8),
              Text(
                _label(period),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppStyle.ink(context),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppStyle.muted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
