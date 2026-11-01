import 'package:flutter/material.dart';
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
