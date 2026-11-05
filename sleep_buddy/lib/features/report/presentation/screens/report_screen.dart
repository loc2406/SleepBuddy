import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/report/presentation/widgets/report_cards.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/app_shell.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/choice_strip.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

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
  Widget build(BuildContext c) => WellnessShell(
    title: 'Thống kê & Cài đặt',
    subtitle: 'Nhìn lại tiến bộ, tìm nhịp học phù hợp.',
    navigationIndex: 4,
    section: AnalyticsSection.report,
    onSectionChanged: onSectionChanged,
    onNavigation: onNavigation,
    onNotification: onNotification,
    maxContentWidth: maxContentWidth,
    children: [
      ChoiceStrip(
        values: ReportPeriod.values,
        selected: data.period,
        onChanged: onPeriodChanged,
        keyPrefix: 'period',
        gradientSelection: false,
        label: (v) => switch (v) {
          ReportPeriod.day => 'Ngày',
          ReportPeriod.week => 'Tuần',
          ReportPeriod.month => 'Tháng',
        },
      ),
      Text(
        data.rangeLabel,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5, color: AppStyle.muted(c)),
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
      SubjectTimeCard(subjects: data.subjects),
      PlanCompletionCard(
        completed: data.completedLessons,
        total: data.totalLessons,
      ),
    ],
  );
}
