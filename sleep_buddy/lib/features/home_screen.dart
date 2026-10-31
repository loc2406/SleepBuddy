import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_bar/liquid_glass_bottom_bar.dart';
import 'package:sleep_buddy/core/constants/color_constant.dart';
import 'package:sleep_buddy/core/utils/responsive.dart';
import 'package:sleep_buddy/features/overview/presentation/screens/overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens = [
      OverviewScreen(),
      PlaceholderPage(title: 'Công việc'),
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
          extendBody: true, // cho phép giao diện nằm sau glass
        body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: deviceType == DeviceType.mobile
              ? _buildScreenWithBottomNav()
              : SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildScreenWithBottomNav() => LiquidGlassBottomBar(
    currentIndex: _currentIndex,

    onTap: (index) {
      setState(() {
        _currentIndex = index;
      });
    },

    activeColor: ColorConstant.primary,
      barBlurSigma: 10,

    items: [
      LiquidGlassBottomBarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_outlined,
        label: 'Tổng quan',
      ),
      LiquidGlassBottomBarItem(
        icon: Icons.task_alt_outlined,
        activeIcon: Icons.task_alt_outlined,
        label: 'Công việc',
      ),
      LiquidGlassBottomBarItem(
        icon: Icons.bedtime_outlined,
        activeIcon: Icons.bedtime_outlined,
        label: 'Giấc ngủ',
      ),
      LiquidGlassBottomBarItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_outline_rounded,
        label: 'Cá nhân',
      ),
    ],
  );
}
