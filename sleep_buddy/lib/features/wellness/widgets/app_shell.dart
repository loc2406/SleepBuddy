import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/analytics/model/models.dart';

import 'choice_strip.dart';
import '../../../core/config/app_style.dart';

class WellnessShell extends StatelessWidget {
  const WellnessShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.navigationIndex,
    this.onNavigation,
    this.onNotification,
    this.section,
    this.onSectionChanged,
    this.maxContentWidth = 600,
  });
  final String title, subtitle;
  final List<Widget> children;
  final int navigationIndex;
  final ValueChanged<int>? onNavigation;
  final VoidCallback? onNotification;
  final AnalyticsSection? section;
  final ValueChanged<AnalyticsSection>? onSectionChanged;
  final double maxContentWidth;
  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: AppStyle.dark(c)
        ? const Color(0xFF1C1729)
        : const Color(0xFFEFEDFF),
    body: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppStyle.dark(c)
              ? [const Color(0xFF1C1729), const Color(0xFF221B30)]
              : [const Color(0xFFEFEDFF), const Color(0xFFFCFBFF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          key: PageStorageKey(
            'wellness-content-$navigationIndex-${section?.name}',
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 21,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: AppStyle.ink(c),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.35,
                                color: AppStyle.muted(c),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (section != null) ...[
                    ChoiceStrip(
                      values: AnalyticsSection.values,
                      selected: section!,
                      keyPrefix: 'section',
                      label: (v) => switch (v) {
                        AnalyticsSection.report => 'Báo cáo',
                        AnalyticsSection.library => 'Cẩm nang',
                        AnalyticsSection.settings => 'Cài đặt',
                      },
                      onChanged: onSectionChanged,
                    ),
                    const SizedBox(height: 14),
                  ],
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class WellnessNavigation extends StatelessWidget {
  const WellnessNavigation({
    super.key,
    required this.selectedIndex,
    this.onSelected,
    this.maxWidth = 600,
  });
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final double maxWidth;
  @override
  Widget build(BuildContext c) {
    const labels = [
      'Trang chủ',
      'Lịch trình',
      'Tập trung',
      'Nghỉ ngơi',
      'Thống kê',
    ];
    const icons = [
      'home-nav',
      'calendar-nav',
      'timer-nav',
      'moon-nav',
      'chart-nav',
    ];
    final showLabels = MediaQuery.sizeOf(c).height >= 400;
    return ColoredBox(
      color: AppStyle.surface(c),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: LayoutBuilder(
              builder: (c, box) {
                final scale = MediaQuery.textScalerOf(c).scale(11) / 11;
                final w = math.max(
                  box.maxWidth / 5,
                  showLabels ? math.max(64.0, 64 * scale) : 48.0,
                );
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < 5; i++)
                        SizedBox(
                          width: w,
                          child: Semantics(
                            selected: i == selectedIndex,
                            child: Tooltip(
                              message: labels[i],
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  key: ValueKey('nav-$i'),
                                  onTap: onSelected == null
                                      ? null
                                      : () => onSelected!(i),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      2,
                                      10,
                                      2,
                                      7,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/wellness/${icons[i]}.png',
                                          width: 25,
                                          height: 25,
                                          color: i == selectedIndex
                                              ? AppStyle.purple
                                              : const Color(0xFF8C81B1),
                                          colorBlendMode: BlendMode.srcIn,
                                          excludeFromSemantics: true,
                                        ),
                                        if (showLabels) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            labels[i],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              height: 1.2,
                                              fontWeight: i == selectedIndex
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              color: i == selectedIndex
                                                  ? AppStyle.purple
                                                  : AppStyle.muted(c),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 5),
                                        Container(
                                          height: 3,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            color: i == selectedIndex
                                                ? AppStyle.purple
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
