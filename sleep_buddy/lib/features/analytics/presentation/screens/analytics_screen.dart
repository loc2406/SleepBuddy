import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/analytics/presentation/models/models.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/library_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/report_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/settings_screen.dart';
import 'package:sleep_buddy/core/db/report_dao.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsSection selectedSection = AnalyticsSection.report;
  ReportPeriod selectedReportPeriod = ReportPeriod.week;
  ReportData? reportData;
  bool isLoadingReport = true;
  String? reportError;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void changeSection(AnalyticsSection section) {
    setState(() => selectedSection = section);
  }

  void changeReportPeriod(ReportPeriod period) {
    setState(() {
      selectedReportPeriod = period;
      isLoadingReport = true;
      reportError = null;
    });
    _loadReport();
  }

  Future<void> _loadReport() async {
    final period = selectedReportPeriod;
    try {
      final data = await ReportDao.getReport(period, DateTime.now());
      if (!mounted || selectedReportPeriod != period) return;
      setState(() {
        reportData = data;
        isLoadingReport = false;
        reportError = null;
      });
    } catch (_) {
      if (!mounted || selectedReportPeriod != period) return;
      setState(() {
        reportData = null;
        isLoadingReport = false;
        reportError = 'Không thể tải dữ liệu báo cáo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (selectedSection) {
      case AnalyticsSection.report:
        if (isLoadingReport || reportData == null) {
          return Scaffold(
            body: Center(
              child: isLoadingReport
                  ? const CircularProgressIndicator()
                  : Text(
                      reportError ?? 'Không có dữ liệu báo cáo.',
                      textAlign: TextAlign.center,
                    ),
            ),
          );
        }
        return ReportScreen(
          data: reportData!,
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
