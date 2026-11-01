import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_cubit.dart';
import 'package:sleep_buddy/features/overview/presentation/cubit/overview_state.dart';
import 'package:sleep_buddy/features/overview/presentation/widgets/moon_sphere.dart';
import 'package:sleep_buddy/features/overview/presentation/widgets/plan_button.dart';
import 'package:sleep_buddy/features/overview/presentation/widgets/stat_card.dart';

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
    _cubit.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
          child: Icon(Icons.nightlight_round, color: ColorConstant.black),
        ),
        title: Text(
          'Sleep Buddy',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocBuilder<OverviewCubit, OverviewState>(
            builder: ((context, state) => Switch(
              value: state.isNightMode,
              onChanged: (value) async {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('isNightMode: $value')));
                await _cubit.changeTheme(value);
              },
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                if (state.isNightMode) {
                  return const Icon(
                    Icons.nightlight_round,
                    color: ColorConstant.white,
                  );
                }
                return const Icon(Icons.wb_sunny, color: ColorConstant.yellow);
              }),
            )),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final deviceType = Responsive.getDeviceType(width);

            final padding = Responsive.getScreenPadding(width);

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
                      // Hero section
                      _buildHeroSection(deviceType),

                      const SizedBox(height: 44),

                      // Statistics section
                      _buildStatisticsSection(width),
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

  Widget _buildHeroSection(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;

    final moonSize = switch (deviceType) {
      DeviceType.mobile => 140.0,
      DeviceType.tablet => 220.0,
      DeviceType.desktop => 300.0,
    };

    final titleSize = switch (deviceType) {
      DeviceType.mobile => 24.0,
      DeviceType.tablet => 48.0,
      DeviceType.desktop => 64.0,
    };

    final subTitleSize = switch (deviceType) {
      DeviceType.mobile => 16.0,
      DeviceType.tablet => 32.0,
      DeviceType.desktop => 48.0,
    };

    final heroContent = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 26),

        Text(
          'Chào bạn, hôm nay thế nào?',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: ColorConstant.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Chia nhỏ việc học, lắng nghe cơ thể '
          'và dành cho mình một giấc ngủ thật '
          'an lành. Mỗi bước nhỏ hôm nay đều '
          'đáng tự hào.',
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.5,
            fontSize: subTitleSize,
            color: ColorConstant.textSecondary,
          ),
        ),

        const SizedBox(height: 28),

        const PlanButton(),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: MoonSphere(size: moonSize),
          ),

          const SizedBox(height: 24),

          heroContent,
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: heroContent),

          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.topRight,
              child: Transform.translate(
                offset: Offset(0, deviceType == DeviceType.desktop ? -20 : 0),
                child: MoonSphere(size: moonSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(double width) {
    final columns = Responsive.getGridColumns(width);

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 20,
        mainAxisSpacing: 16,
        mainAxisExtent: 150,
      ),

      children: const [
        StatCard(
          title: 'Nhiệm vụ hoàn thành',
          subtitle: 'Mục tiêu học tập hôm nay',
          value: '0 / 0',
          valueColor: ColorConstant.textDark,
        ),

        StatCard(
          title: 'Giấc ngủ gần nhất',
          subtitle: 'Mục tiêu khuyến nghị: 8–10 giờ',
          value: '—',
          valueColor: ColorConstant.accentYellow,
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
