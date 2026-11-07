import 'package:flutter/material.dart';

enum FocusMode { study, relax }

@immutable
class RecoveryGuide {
  const RecoveryGuide({
    required this.id,
    required this.tag,
    required this.title,
    required this.readTime,
    required this.thumbnail,
  });

  final String id;
  final String tag;
  final String title;
  final String readTime;
  final ImageProvider thumbnail;
}

@immutable
class FocusNavItem {
  const FocusNavItem({required this.label, required this.image});

  final String label;
  final ImageProvider image;
}

const defaultNavigationItems = [
  FocusNavItem(
    label: 'Trang chủ',
    image: AssetImage('assets/focus_rest/home-nav.png'),
  ),
  FocusNavItem(
    label: 'Lịch trình',
    image: AssetImage('assets/focus_rest/calendar-nav.png'),
  ),
  FocusNavItem(
    label: 'Tập trung',
    image: AssetImage('assets/focus_rest/timer-nav.png'),
  ),
  FocusNavItem(
    label: 'Nghỉ ngơi',
    image: AssetImage('assets/focus_rest/moon-nav.png'),
  ),
  FocusNavItem(
    label: 'Thống kê',
    image: AssetImage('assets/focus_rest/chart-nav.png'),
  ),
];
