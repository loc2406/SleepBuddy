import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/constants/asset_constants.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/core/db/dashboard_dao.dart';
import 'package:sleep_buddy/core/db/profile_dao.dart';
import 'package:sleep_buddy/features/overview/presentation/widgets/daily_gold_card.dart';
import 'package:sleep_buddy/features/overview/presentation/widgets/next_task_card.dart';
import 'package:sleep_buddy/features/overview/presentation/widgets/stat_card.dart';
import 'package:sleep_buddy/features/overview/presentation/widgets/time_distribution_card.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _isLoading = true;
  String _displayName = 'Người dùng';
  int _studyMinutes = 0;
  int _restMinutes = 0;
  Map<String, dynamic>? _nextTask;
  Map<String, int> _subjectMinutes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final displayName = await ProfileDao.getDisplayName();
    final durations = await DashboardDao.getStudyAndBreakDuration(now);
    final nextTask = await DashboardDao.getNextTask(now);
    final subjectMinutes = await DashboardDao.getStudyMinutesBySubject(
      now.subtract(const Duration(days: 1)),
      now,
    );
    if (!mounted) return;
    setState(() {
      _displayName = displayName;
      _studyMinutes = durations['focus_minutes'] ?? 0;
      _restMinutes = durations['break_minutes'] ?? 0;
      _nextTask = nextTask;
      _subjectMinutes = subjectMinutes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.pageBackground(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, $_displayName!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppStyle.ink(context),
              ),
            ),
            Text(
              'Học tập hiệu quả, nghỉ ngơi trọn vẹn nhé!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppStyle.ink(context),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final padding = Responsive.getScreenPadding(width);

                  return Container(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    padding: padding,
                    decoration: BoxDecoration(
                      gradient: AppStyle.pageGradient(context),
                    ),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: Responsive.maxContentWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 794 / 230,
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      AppStyle.dark(context)
                                          ? AssetConstants.catCloudBgDark
                                          : AssetConstants.catCloudBg,
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Text(
                                  '\n\n${_formatVietnameseDate(DateTime.now())}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppStyle.ink(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildHeaderCard(width),
                            const SizedBox(height: 16),
                            DailyGoalCard(
                              completed: Duration(minutes: _studyMinutes),
                              goal: const Duration(hours: 5),
                            ),
                            const SizedBox(height: 16),
                            _nextTask == null
                                ? const SizedBox.shrink()
                                : NextTaskCard(
                                    title: _nextTask!['title'] as String,
                                    startTime: _timeOfDay(
                                      _nextTask!['scheduled_start'] as String,
                                    ),
                                    endTime: _timeOfDay(
                                      _nextTask!['scheduled_end'] as String,
                                    ),
                                    priorityLabel: _priorityLabel(
                                      _nextTask!['priority'] as String,
                                    ),
                                    priorityColor: const Color(
                                      0xFFD81722,
                                    ), // Chữ đỏ đậm
                                    priorityBackground: const Color(
                                      0xFFFFE4E8,
                                    ), // Nền đỏ hồng nhạt
                                    onViewSchedule: () {},
                                  ),
                            const SizedBox(height: 16),
                            TimeDistributionCard(
                              selectedPeriod: 'Hôm nay',
                              periods: const ['Hôm nay', 'Hôm qua', 'Tuần này'],
                              onPeriodChanged: (newPeriod) {},
                              entries: [
                                TimeDistributionEntry(
                                  label: 'Học tập',
                                  duration: Duration(minutes: _studyMinutes),
                                  color: const Color(0xFF9377F6),
                                  gradientEnd: const Color(0xFFA58BEF),
                                ),
                                TimeDistributionEntry(
                                  label: 'Nghỉ ngơi',
                                  duration: Duration(minutes: _restMinutes),
                                  color: const Color(0xFF6BC88C),
                                  gradientEnd: const Color(0xFFA1D7A1),
                                ),
                              ],
                            ),
                            const SizedBox(height: kBottomNavigationBarHeight),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeaderCard(double width) {
    final studyCard = StatCard(
      icTitle: Image.asset(AssetConstants.graduation, width: 24),
      title: 'Học tập hôm nay',
      subtitle: _subjectMinutes.isEmpty
          ? 'Chưa ghi nhận phiên học'
          : '${_subjectMinutes.length} môn đã ghi nhận',
      value: _durationLabel(Duration(minutes: _studyMinutes)),
      valueTextColor: ColorConstant.textDark,
      cardBgAsset: AppStyle.dark(context)
          ? AssetConstants.cardStudyBgDark
          : AssetConstants.cardStudyBg,
    );
    final restCard = StatCard(
      icTitle: Image.asset(AssetConstants.bed, width: 24),
      title: 'Nghỉ ngơi hôm nay',
      subtitle: _restMinutes == 0
          ? 'Chưa ghi nhận nghỉ ngơi'
          : '$_restMinutes phút đã ghi nhận',
      value: _durationLabel(Duration(minutes: _restMinutes)),
      valueTextColor: ColorConstant.textDark,
      cardBgAsset: AppStyle.dark(context)
          ? AssetConstants.cardRestBgDark
          : AssetConstants.cardStudyBg,
    );

    return Row(
      children: [
        Expanded(child: studyCard),
        const SizedBox(width: 20),
        Expanded(child: restCard),
      ],
    );
  }

  static TimeOfDay _timeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _priorityLabel(String priority) => switch (priority) {
    'high' => 'Cao',
    'medium' => 'Trung bình',
    'low' => 'Thấp',
    _ => priority,
  };

  static String _durationLabel(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return remaining == 0 ? '${hours}h' : '${hours}h ${remaining}m';
  }

  static String _formatVietnameseDate(DateTime date) {
    const weekdays = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật',
    ];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
