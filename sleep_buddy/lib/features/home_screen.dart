import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/db/guide_article_dao.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';
import 'package:sleep_buddy/features/focus_rest/screens/focus_rest_screen.dart';
import 'package:sleep_buddy/features/focus_rest/screens/models.dart';
import 'package:sleep_buddy/features/focus_rest/cubit/focus_rest_cubit.dart';
import 'package:sleep_buddy/features/focus_rest/cubit/focus_rest_state.dart';
import 'package:sleep_buddy/features/overview/screens/overview_screen.dart';
import 'package:sleep_buddy/features/analytics/screens/analytics_screen.dart';
import 'package:sleep_buddy/features/study_plan/screens/study_planner_screen.dart';
import 'package:sleep_buddy/features/study_plan/cubit/study_planner_cubit.dart';
import 'package:sleep_buddy/features/sleep/screens/sleep_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialTab = 0,
    this.startedTaskId,
    this.startRejected = false,
  });

  final int initialTab;
  final int? startedTaskId;
  final bool startRejected;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];
  bool _isLoading = true;
  late final StudyPlannerCubit _plannerCubit;
  late final FocusRestCubit _focusCubit;

  @override
  void initState() {
    super.initState();
    _plannerCubit = context.read<StudyPlannerCubit>();
    _focusCubit = context.read<FocusRestCubit>();
    _currentIndex = widget.initialTab.clamp(0, 4);
    _loadDatabaseData();
    if (_currentIndex == 1) {
      _plannerCubit.loadLessons();
    }
    if (_focusCubit.state.status == FocusRestStatus.completed) {
      _plannerCubit.loadLessons();
    }
    if (widget.startRejected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showStartRejectedMessage();
      });
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab ||
        widget.startedTaskId != oldWidget.startedTaskId) {
      setState(() => _currentIndex = widget.initialTab.clamp(0, 4));
      _loadDatabaseData();
      _plannerCubit.loadLessons();
    }
    if (widget.startRejected && !oldWidget.startRejected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showStartRejectedMessage();
      });
    }
  }

  Future<void> _loadDatabaseData() async {
    final guides = await GuideArticleDao.getAll();
    final List<RecoveryGuide> relaxGuide = guides.isEmpty
        ? []
        : guides
              .where((e) => e.category.name == 'relax')
              .map(
                (e) => RecoveryGuide(
                  id: e.id,
                  tag: "Thư giãn",
                  title: e.title,
                  readTime: e.readTimeLabel,
                  thumbnail: e.image,
                ),
              )
              .toList();

              final List<GuideArticle> sleepGuide = guides.isEmpty
        ? []
        : guides
              .where((e) => e.category.name == 'sleep')
              .toList();

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
          taskId: widget.startedTaskId,
          onOpenPlanner: () {
            setState(() => _currentIndex = 1);
            _plannerCubit.loadLessons();
          },
          onGuideTap: (guide) {
            final article = guides.firstWhere(
              (article) => article.id == guide.id,
            );
            _openGuide(article);
          },
          guides: relaxGuide,
        ),
        SleepScreen(guides: sleepGuide, onGuideOpen: _openGuide),
        const AnalyticsScreen(),
      ];
      _isLoading = false;
    });
  }

  void _openGuide(GuideArticle article) {
    context.push('/guide/${article.id}', extra: article);
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<FocusRestCubit, FocusRestState>(
        listenWhen: (previous, current) =>
            previous.status != FocusRestStatus.completed &&
            current.status == FocusRestStatus.completed,
        listener: (context, state) => _plannerCubit.loadLessons(),
        child: LayoutBuilder(
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
        ),
      );

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
        if (index == 1) {
          _plannerCubit.loadLessons();
        } else if (index == 2 &&
            _focusCubit.state.status == FocusRestStatus.idle) {
          _focusCubit.loadTaskSession(null);
        }
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

  void _showStartRejectedMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Khung giờ của nhiệm vụ đã kết thúc.')),
      );
  }
}
