import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/focus_rest_screen.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/models.dart';
import 'package:sleep_buddy/features/overview/presentation/screens/overview_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/study_planner_screen.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/models.dart';
import 'package:sleep_buddy/features/analytics/presentation/models/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/screens/sleep_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  final DateTime selectedDate = DateTime(2026, 11, 3);
  late final List<DateTime> days;
  late final String dateLabel;
  late final List<StudyLesson> lessons;
  late final int totalLessons;
  late final int completedLessons;
  late final List<PlannerFilterItem> filters;

  @override
  void initState() {
    super.initState();
    days = List.generate(7, (index) => DateTime(2026, 11, 2 + index));
    dateLabel = 'Thứ Ba, 3 tháng 11';
    lessons = const [
      StudyLesson(
        id: 'lesson-1',
        subject: 'Toán học',
        title: 'Hàm số và đồ thị',
        description: 'Ôn tập hàm bậc hai và cách vẽ đồ thị',
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 9, minute: 30),
        priority: LessonPriority.high,
        status: LessonStatus.completed,
      ),
      StudyLesson(
        id: 'lesson-2',
        subject: 'Tiếng Anh',
        title: 'Luyện nghe IELTS',
        description: 'Luyện Section 3 và ghi chú từ khóa',
        startTime: TimeOfDay(hour: 10, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 0),
        priority: LessonPriority.medium,
        status: LessonStatus.inProgress,
      ),
      StudyLesson(
        id: 'lesson-3',
        subject: 'Vật lý',
        title: 'Điện xoay chiều',
        description: 'Làm bài tập về mạch RLC',
        startTime: TimeOfDay(hour: 14, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 30),
        priority: LessonPriority.high,
        status: LessonStatus.notStarted,
      ),
      StudyLesson(
        id: 'lesson-4',
        subject: 'Lịch sử',
        title: 'Chiến tranh thế giới thứ hai',
        description: 'Tóm tắt diễn biến và đọc tài liệu tham khảo',
        startTime: TimeOfDay(hour: 16, minute: 0),
        endTime: TimeOfDay(hour: 17, minute: 0),
        priority: LessonPriority.low,
        status: LessonStatus.completed,
      ),
    ];
    totalLessons = lessons.length;
    completedLessons = lessons
        .where((lesson) => lesson.status == LessonStatus.completed)
        .length;
    filters = const [
      PlannerFilterItem(value: LessonFilter.all, label: 'Tất cả', count: 4),
      PlannerFilterItem(
        value: LessonFilter.notStarted,
        label: 'Chưa học',
        count: 1,
      ),
      PlannerFilterItem(
        value: LessonFilter.inProgress,
        label: 'Đang học',
        count: 1,
      ),
      PlannerFilterItem(
        value: LessonFilter.completed,
        label: 'Hoàn thành',
        count: 2,
      ),
    ];
    _screens = [
      OverviewScreen(),
      StudyPlannerScreen(
        days: days,
        selectedDate: selectedDate,
        dateLabel: dateLabel,
        lessons: lessons,
        totalLessons: totalLessons,
        completedLessons: completedLessons,
        filters: filters,
      ),
      FocusRestScreen(
        timeText: '00:00',
        timerLabel: 'Thời gian học tập',
        timerProgress: 0.25,
        isPlaying: false,
        onPlayPause: () {},
        studyDurationText: 'Phiên học',
        restDurationText: 'Nghỉ ngơi',
        progressTitle: 'Tiến trình hôm nay',
        progressCountLabel: '2/4',
        progressTimeDetail: '50 phút tập trung',
        overallProgress: 0.5,
        guides: [
          RecoveryGuide(
            id: 'eye_exercise',
            tag: 'Giãn cơ',
            title: '5 bài tập thư giãn mắt đơn giản',
            readTime: '2 phút đọc',
            thumbnail: AssetImage('assets/focus_rest/relaxation-thumb.png'),
          ),
        ],
      ),
      SleepScreen(
        data: SleepData(
          periodLabel: 'Đêm qua · 02 – 03/11',
          bedTime: DateTime(2026, 11, 2, 23, 0),
          wakeTime: DateTime(2026, 11, 3, 6, 45),

          // 7h45 / 8h ≈ 97%, còn thiếu 15 phút.
          recordedDuration: const Duration(hours: 7, minutes: 45),
          targetDuration: const Duration(hours: 8),

          targetBedtime: const TimeOfDay(hour: 22, minute: 45),
          reminderTime: const TimeOfDay(hour: 22, minute: 15),
          reminderEnabled: true,
          mood: SleepMood.normal,
          recommendation: 'Bắt đầu nhẹ nhàng và nghỉ đều giữa các phiên.',
        ),
        guides: [
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
      ),
      AnalyticsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          extendBody: true,
          body: _screens[_currentIndex],
          bottomNavigationBar: _buildScreenWithBottomNav(context),
        );
      },
    );
  }

  Widget _buildScreenWithBottomNav(BuildContext context) {
    List<IconData> iconList = [
      Icons.home,
      Icons.checklist,
      Icons.timer,
      Icons.bed,
      Icons.settings,
    ];
    return AnimatedBottomNavigationBar.builder(
      activeIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      leftCornerRadius: 32,
      rightCornerRadius: 32,
      gapLocation: GapLocation.none,
      elevation: 8,
      backgroundColor: AppStyle.navBackground(context),
      borderColor: AppStyle.navBorder(context),
      shadow: AppStyle.navShadow(context),
      borderWidth: 1,
      itemCount: iconList.length,
      tabBuilder: (index, isActive) => isActive
          ? Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: AppStyle.purple,
              ),
              child: Icon(
                iconList[index],
                size: 24,
                color: Colors.white,
              ),
            )
          : Icon(
              iconList[index],
              size: 24,
              color: AppStyle.navUnselected(context),
            ),
    );
  }
}
