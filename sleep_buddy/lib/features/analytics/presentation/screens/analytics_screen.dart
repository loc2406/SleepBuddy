import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/analytics/presentation/models/models.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/library_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/report_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/settings_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsSection selectedSection = AnalyticsSection.report;
  ReportPeriod selectedReportPeriod = ReportPeriod.week;

  void changeSection(AnalyticsSection section) {
    setState(() => selectedSection = section);
  }

  void changeReportPeriod(ReportPeriod period) {
    setState(() => selectedReportPeriod = period);
  }

  String get reportRangeLabel {
    final today = DateTime.now();
    final day = today.day.toString().padLeft(2, '0');
    final month = today.month.toString().padLeft(2, '0');

    switch (selectedReportPeriod) {
      case ReportPeriod.day:
        return '$day/$month/${today.year}';
      case ReportPeriod.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final startDay = weekStart.day.toString().padLeft(2, '0');
        final startMonth = weekStart.month.toString().padLeft(2, '0');
        final endDay = weekEnd.day.toString().padLeft(2, '0');
        final endMonth = weekEnd.month.toString().padLeft(2, '0');
        return '$startDay/$startMonth – $endDay/$endMonth/${weekEnd.year}';
      case ReportPeriod.month:
        return 'Tháng $month/${today.year}';
    }
  }

  String get reportChartTitle => switch (selectedReportPeriod) {
    ReportPeriod.day => 'Nhịp học trong ngày',
    ReportPeriod.week => 'Nhịp học trong tuần',
    ReportPeriod.month => 'Nhịp học trong tháng',
  };

  String get reportMetricCaption => switch (selectedReportPeriod) {
    ReportPeriod.day => 'Trong ngày đã chọn',
    ReportPeriod.week => 'Trong tuần đã chọn',
    ReportPeriod.month => 'Trong tháng đã chọn',
  };

  @override
  Widget build(BuildContext context) {
    switch (selectedSection) {
      case AnalyticsSection.report:
        return ReportScreen(
          data: ReportData(
            period: selectedReportPeriod,
            rangeLabel: reportRangeLabel,
            chartTitle: reportChartTitle,
            metricCaption: reportMetricCaption,

            studyTime: Duration(hours: 18, minutes: 30),
            restTime: Duration(hours: 7, minutes: 30),

            // 18 / 24 = 75%.
            completedLessons: 18,
            totalLessons: 24,

            // Tổng các cột = 18h30.
            dailyBars: [
              StudyBar(label: 'T2', hours: 2),
              StudyBar(label: 'T3', hours: 3),
              StudyBar(label: 'T4', hours: 2.5),
              StudyBar(label: 'T5', hours: 4),
              StudyBar(label: 'T6', hours: 3),
              StudyBar(label: 'T7', hours: 1.5),
              StudyBar(label: 'CN', hours: 2.5),
            ],

            // Tổng thời gian các môn = 18h30.
            subjects: [
              SubjectDuration(
                name: 'Toán học',
                duration: Duration(hours: 6),
                color: Color(0xFF9470F4),
              ),
              SubjectDuration(
                name: 'Tiếng Anh',
                duration: Duration(hours: 5),
                color: Color(0xFF82A7F4),
              ),
              SubjectDuration(
                name: 'Vật lý',
                duration: Duration(hours: 4),
                color: Color(0xFF84CC9C),
              ),
              SubjectDuration(
                name: 'Hóa học',
                duration: Duration(hours: 3, minutes: 30),
                color: Color(0xFFFFBE68),
              ),
            ],
          ),
          onSectionChanged: changeSection,
          onPeriodChanged: changeReportPeriod,
        );

      case AnalyticsSection.library:
        return LibraryScreen(onSectionChanged: changeSection);

      case AnalyticsSection.settings:
        return SettingsScreen(
          onSectionChanged: changeSection,
          onOpenLibrary: () {
            changeSection(AnalyticsSection.library);
          },
        );
    }
  }
}
