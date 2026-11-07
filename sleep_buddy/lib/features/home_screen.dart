import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/db/guide_article_dao.dart';
import 'package:sleep_buddy/core/db/settings_dao.dart';
import 'package:sleep_buddy/core/db/sleep_dao.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/focus_rest_screen.dart';
import 'package:sleep_buddy/features/focus_rest/presentation/screens/models.dart';
import 'package:sleep_buddy/features/overview/presentation/screens/overview_screen.dart';
import 'package:sleep_buddy/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/study_planner_screen.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/screens/sleep_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  bool _isLoading = true;
  late DateTime selectedDate;
  late List<DateTime> days;
  late String dateLabel;
  late final List<StudyLesson> lessons;
  late final int totalLessons;
  late final int completedLessons;
  late final List<PlannerFilterItem> filters;

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
  }

  Future<void> _loadDatabaseData() async {
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    days = List.generate(7, (index) => weekStart.add(Duration(days: index)));
    dateLabel =
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';

    lessons = await StudyTaskDao.getByDate(selectedDate);
    totalLessons = lessons.length;
    completedLessons = lessons
        .where((lesson) => lesson.status == LessonStatus.completed)
        .length;
    filters = await StudyTaskDao.getFilterItems(selectedDate);
    final guides = await GuideArticleDao.getAll();
    final sleepData = await SleepDao.getLatest();
    final studyMinutes = await SettingsDao.getInt('study_duration_minutes', 30);
    final shortBreakMinutes = await SettingsDao.getInt(
      'short_break_minutes',
      5,
    );
    final recoveryGuide = guides.isEmpty
        ? const RecoveryGuide(
            id: 'eye_exercise',
            tag: 'Giãn cơ',
            title: '5 bài tập thư giãn mắt đơn giản',
            readTime: '2 phút đọc',
            thumbnail: AssetImage('assets/focus_rest/relaxation-thumb.png'),
          )
        : RecoveryGuide(
            id: guides.first.id,
            tag: guides.first.category.name == 'relax' ? 'Giãn cơ' : 'Học tập',
            title: guides.first.title,
            readTime: guides.first.readTimeLabel,
            thumbnail: guides.first.image,
          );

    if (!mounted) return;
    setState(() {
      _screens = [
        const OverviewScreen(),
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
          timeText: '${studyMinutes.toString().padLeft(2, '0')}:00',
          timerLabel: 'Thời gian học tập',
          timerProgress: 0.25,
          isPlaying: false,
          onPlayPause: () {},
          studyDurationText: '$studyMinutes phút',
          restDurationText: '$shortBreakMinutes phút',
          progressTitle: 'Tiến trình hôm nay',
          progressCountLabel: '$completedLessons/$totalLessons',
          progressTimeDetail: '$studyMinutes phút tập trung',
          overallProgress: totalLessons == 0
              ? 0
              : completedLessons / totalLessons,
          guides: [recoveryGuide],
        ),
        SleepScreen(data: sleepData, guides: guides),
        const AnalyticsScreen(),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppStyle.pageBackground(context),
          extendBody: true,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _screens[_currentIndex],
          bottomNavigationBar: _isLoading
              ? null
              : _buildScreenWithBottomNav(context),
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
              child: Icon(iconList[index], size: 24, color: Colors.white),
            )
          : Icon(
              iconList[index],
              size: 24,
              color: AppStyle.navUnselected(context),
            ),
    );
  }
}
