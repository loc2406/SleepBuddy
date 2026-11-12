import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/constants/asset_constants.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/core/config/app_style.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/overview/cubit/overview_cubit.dart';
import 'package:sleep_buddy/features/overview/cubit/overview_state.dart';
import 'package:sleep_buddy/features/overview/widgets/daily_gold_card.dart';
import 'package:sleep_buddy/features/overview/widgets/next_task_card.dart';
import 'package:sleep_buddy/features/overview/widgets/stat_card.dart';
import 'package:sleep_buddy/features/overview/widgets/time_distribution_card.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late final OverviewCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OverviewCubit>();
    _cubit.loadData();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<OverviewCubit, OverviewState>(
    builder: (context, state) => Scaffold(
      backgroundColor: AppStyle.pageBackground(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào!',
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
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.loadError != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Không thể tải dữ liệu: ${state.loadError}'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _cubit.loadData,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
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
                                  '\n\n${_formatVietnameseDate(state.currentTime)}',
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
                            _buildHeaderCard(width, state),
                            const SizedBox(height: 16),
                            DailyGoalCard(
                              completedTasks: state.completedTasks,
                              totalTasks: state.totalTasks,
                              remainingDuration: state.timeUntilEndOfDay,
                            ),
                            const SizedBox(height: 16),
                            state.nextTask == null
                                ? const SizedBox.shrink()
                                : NextTaskCard(
                                    title: state.nextTask!['title'] as String,
                                    startTime: _timeOfDay(
                                      state.nextTask!['scheduled_start']
                                          as String,
                                    ),
                                    endTime: _timeOfDay(
                                      state.nextTask!['scheduled_end']
                                          as String,
                                    ),
                                    priorityLabel: _priorityLabel(
                                      state.nextTask!['priority'] as String,
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
                                  duration: Duration(
                                    minutes: state.studyMinutes,
                                  ),
                                  color: const Color(0xFF9377F6),
                                  gradientEnd: const Color(0xFFA58BEF),
                                ),
                                TimeDistributionEntry(
                                  label: 'Nghỉ ngơi',
                                  duration: Duration(
                                    minutes: state.restMinutes,
                                  ),
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
    ),
  );

  Widget _buildHeaderCard(double width, OverviewState state) {
    final studyCard = StatCard(
      icTitle: Image.asset(AssetConstants.graduation, width: 24),
      title: 'Học tập hôm nay',
      subtitle: state.subjectMinutes.isEmpty
          ? 'Chưa ghi nhận phiên học'
          : '${state.subjectMinutes.length} môn đã ghi nhận',
      value: _durationLabel(Duration(minutes: state.studyMinutes)),
      valueTextColor: ColorConstant.textDark,
      cardBgAsset: AppStyle.dark(context)
          ? AssetConstants.cardStudyBgDark
          : AssetConstants.cardStudyBg,
    );
    final restCard = StatCard(
      icTitle: Image.asset(AssetConstants.bed, width: 24),
      title: 'Nghỉ ngơi hôm nay',
      subtitle: state.restMinutes == 0
          ? 'Chưa ghi nhận nghỉ ngơi'
          : '${state.restMinutes} phút đã ghi nhận',
      value: _durationLabel(Duration(minutes: state.restMinutes)),
      valueTextColor: ColorConstant.textDark,
      cardBgAsset: AppStyle.dark(context)
          ? AssetConstants.cardRestBgDark
          : AssetConstants.cardRestBg,
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
