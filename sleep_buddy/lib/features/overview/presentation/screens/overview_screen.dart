import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/constants/asset_constants.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_cubit.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_state.dart';
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
  late final OverviewCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OverviewCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.gradientBackgroundStart,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, Thành Lộc!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstant.black,
              ),
            ),
            Text(
              'Học tập hiệu quả, nghỉ ngơi trọn vẹn nhé!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: ColorConstant.black,
              ),
            ),
          ],
        ),
        // actions: [
        //   BlocBuilder<OverviewCubit, OverviewState>(
        //     builder: ((context, state) => Switch(
        //       value: state.isNightMode,
        //       onChanged: (value) async => await _cubit.changeTheme(value),
        //       thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
        //         if (state.isNightMode) {
        //           return const Icon(
        //             Icons.nightlight_round,
        //             color: ColorConstant.white,
        //           );
        //         }
        //         return const Icon(Icons.wb_sunny, color: ColorConstant.yellow);
        //       }),
        //       inactiveThumbColor: ColorConstant.white,
        //       inactiveTrackColor: ColorConstant.primary,
        //     )),
        //   ),
        // ],
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final padding = Responsive.getScreenPadding(
              width,
              kBottomNavigationBarHeight + MediaQuery.paddingOf(context).bottom,
            );

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Responsive.maxContentWidth,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 660),
                  padding: padding,

                  decoration: BoxDecoration(
                    border: Border.all(color: ColorConstant.borderPrimary),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorConstant.gradientBackgroundStart,
                        ColorConstant.gradientBackgroundMiddle,
                        ColorConstant.gradientBackgroundEnd,
                      ],
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Image.asset(
                            AssetConstants.catCloudBg,
                            width: double.infinity,
                          ),
                          Positioned(
                            top: 83,
                            left: 20,
                            child: Text(
                              'Thứ 2, 02/11/2026',
                              style: TextStyle(
                                color: ColorConstant.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildHeaderCard(width),
                      const SizedBox(height: 16),
                      DailyGoalCard(
                        completed: const Duration(
                          hours: 3,
                          minutes: 45,
                        ), // Đã làm: 3h 45m
                        goal: const Duration(hours: 5),
                      ),
                      const SizedBox(height: 16),
                      NextTaskCard(
                        title: 'Ôn tập Toán - Chương 3',
                        startTime: const TimeOfDay(hour: 10, minute: 0),
                        endTime: const TimeOfDay(hour: 11, minute: 30),
                        priorityLabel: 'Cao',
                        priorityColor: const Color(0xFFD81722), // Chữ đỏ đậm
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
                        entries: const [
                          TimeDistributionEntry(
                            label: 'Học tập',
                            duration: Duration(hours: 3, minutes: 40),
                            color: Color(0xFF9377F6),
                            gradientEnd: Color(0xFFA58BEF),
                          ),
                          TimeDistributionEntry(
                            label: 'Nghỉ ngơi',
                            duration: Duration(hours: 2, minutes: 30),
                            color: Color(0xFF6BC88C),
                            gradientEnd: Color(0xFFA1D7A1),
                          ),
                          TimeDistributionEntry(
                            label: 'Khác',
                            duration: Duration(hours: 1, minutes: 50),
                            color: Color(0xFFFFB452),
                            gradientEnd: Color(0xFFFFCF76),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),

      children: [
        StatCard(
          icTitle: Image.asset(AssetConstants.graduation, width: 24),
          title: 'Học tập hôm nay',
          subtitle: '+30 phút so với hôm qua',
          value: '2h 30m',
          valueTextColor: ColorConstant.textDark,
          cardBgAsset: AssetConstants.cardStudyBg,
        ),

        StatCard(
          icTitle: Image.asset(AssetConstants.bed, width: 24),
          title: 'Nghỉ ngơi hôm nay',
          subtitle: '+15 phút so với hôm qua',
          value: '3h 0m',
          valueTextColor: ColorConstant.textDark,
          cardBgAsset: AssetConstants.cardRestBg,
        ),
      ],
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.background,
      body: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColorConstant.textPrimary,
          ),
        ),
      ),
    );
  }
}
