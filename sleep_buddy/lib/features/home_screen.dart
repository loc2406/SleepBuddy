import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/overview/presentation/screens/overview_screen.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/study_planner_screen.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/models.dart';

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
      PlaceholderPage(title: 'Giấc ngủ'),
      PlaceholderPage(title: 'Cá nhân'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = Responsive.getDeviceType(constraints.maxWidth);

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: deviceType == DeviceType.mobile
              ? _buildScreenWithBottomNav()
              : SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildScreenWithBottomNav() => BottomNavigationBar(
    currentIndex: _currentIndex,

    onTap: (index) {
      setState(() {
        _currentIndex = index;
      });
    },

    selectedItemColor: ColorConstant.primary,
    unselectedItemColor: ColorConstant.black,
    showUnselectedLabels: true,

    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tổng quan'),
      BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Kế hoạch'),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Báo cáo'),
      BottomNavigationBarItem(
        icon: Icon(Icons.local_library),
        label: 'Cá nhân',
      ),
    ],
  );
}
