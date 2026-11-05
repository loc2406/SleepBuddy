import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/utils/shared_pref.dart';
import 'package:sleep_buddy/features/report/presentation/screens/library_screen.dart';
import 'package:sleep_buddy/features/report/presentation/screens/report_screen.dart';
import 'package:sleep_buddy/features/report/presentation/screens/settings_screen.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsSection selectedSection = AnalyticsSection.report;

  void changeSection(AnalyticsSection section) {
    setState(() => selectedSection = section);
  }

  @override
  Widget build(BuildContext context) {
    switch (selectedSection) {
      case AnalyticsSection.report:
        return ReportScreen(
          data: ReportData(
            period: ReportPeriod.week,
            rangeLabel: '26/10 – 01/11/2026',
            chartTitle: 'Nhịp học trong tuần',
            metricCaption: 'Trong tuần đã chọn',

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
          onPeriodChanged: (period) {
            // Cập nhật dữ liệu báo cáo ở đây.
          },
        );

      case AnalyticsSection.library:
        return LibraryScreen(
          articles: [
            GuideArticle(
              id: 'pomodoro',
              category: GuideCategory.study,
              title: 'Pomodoro: học tập theo từng phiên ngắn',
              readTimeLabel: '4 phút đọc',
              image: AssetImage('assets/wellness/book-glow.png'),
            ),
            GuideArticle(
              id: 'eyes',
              category: GuideCategory.relax,
              title: '5 bài tập thư giãn mắt đơn giản',
              readTimeLabel: '2 phút đọc',
              image: AssetImage('assets/wellness/relaxation-thumb.png'),
              coverImage: true,
            ),
            GuideArticle(
              id: 'sleep',
              category: GuideCategory.sleep,
              title: 'Thói quen buổi tối để ngủ dễ dàng hơn',
              readTimeLabel: '3 phút đọc',
              image: AssetImage('assets/wellness/moon-card.png'),
            ),
            GuideArticle(
              id: 'memory',
              category: GuideCategory.study,
              title: 'Ôn tập ngắt quãng: ghi nhớ lâu hơn',
              readTimeLabel: '5 phút đọc',
              image: AssetImage('assets/wellness/book.png'),
            ),
          ],
          category: GuideCategory.all,

          onSectionChanged: changeSection,
          onQueryChanged: (query) {
            // Tìm kiếm tài liệu ở đây.
          },
          onCategoryChanged: (category) {
            // Lọc tài liệu ở đây.
          },
          onArticleOpen: (article) {
            // Mở chi tiết tài liệu ở đây.
          },
        );

      case AnalyticsSection.settings:
        return SettingsScreen(
          // settings: WellnessSettings(
          //   studyDuration: Duration(minutes: 25),
          //   shortBreak: Duration(minutes: 5),
          //   longBreak: Duration(minutes: 15),
          //   notificationsEnabled: true,
          //   soundEnabled: true,
          //   themeMode: ThemeMode.light,
          // ),
          onSectionChanged: changeSection,
          onOpenLibrary: () {
            changeSection(AnalyticsSection.library);
          },
        );
    }
  }
}
