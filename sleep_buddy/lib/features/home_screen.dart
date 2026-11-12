import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/db/guide_article_dao.dart';
import 'package:sleep_buddy/core/db/settings_dao.dart';
import 'package:sleep_buddy/core/db/sleep_dao.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/focus_rest/screens/focus_rest_screen.dart';
import 'package:sleep_buddy/features/focus_rest/screens/models.dart';
import 'package:sleep_buddy/features/overview/screens/overview_screen.dart';
import 'package:sleep_buddy/features/analytics/screens/analytics_screen.dart';
import 'package:sleep_buddy/features/study_plan/screens/study_planner_screen.dart';
import 'package:sleep_buddy/features/study_plan/model/models.dart';
import 'package:sleep_buddy/features/study_plan/cubit/study_planner_cubit.dart';
import 'package:sleep_buddy/features/wellness/screens/sleep_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialTab = 0, this.startedTaskId});

  final int initialTab;
  final int? startedTaskId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, 4);
    _loadDatabaseData();
    if (_currentIndex == 1) {
      context.read<StudyPlannerCubit>().loadLessons();
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab ||
        widget.startedTaskId != oldWidget.startedTaskId) {
      setState(() => _currentIndex = widget.initialTab.clamp(0, 4));
      _loadDatabaseData();
      context.read<StudyPlannerCubit>().loadLessons();
    }
  }

  Future<void> _loadDatabaseData() async {
    final now = DateTime.now();
    final selectedDate = DateTime(now.year, now.month, now.day);
    final lessons = await StudyTaskDao.getByDate(selectedDate);
    final startedTask = widget.startedTaskId == null
        ? null
        : await StudyTaskDao.getById(widget.startedTaskId!);
    final totalLessons = lessons.length;
    final completedLessons = lessons
        .where((lesson) => lesson.status == LessonStatus.completed)
        .length;
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
          onAddMissionPressed: () async {
            final created = await context.push<bool>('/study-plan/add');
            return created == true;
          },
        ),
        FocusRestScreen(
          subtitle: startedTask == null
              ? 'Học tập hiệu quả, nghỉ ngơi đúng cách!'
              : 'Đang học: ${startedTask.title}',
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
