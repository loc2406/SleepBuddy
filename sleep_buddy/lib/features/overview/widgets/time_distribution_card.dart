import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

@immutable
class TimeDistributionEntry {
  const TimeDistributionEntry({
    required this.label,
    required this.duration,
    required this.color,
    this.gradientEnd,
  });

  final String label;
  final Duration duration;
  final Color color;
  final Color? gradientEnd;

  double get minutes =>
      duration.isNegative ? 0 : duration.inMilliseconds / 60000;
}

class TimeDistributionCard extends StatelessWidget {
  const TimeDistributionCard({
    super.key,
    required this.entries,
    required this.selectedPeriod,
    required this.periods,
    required this.onPeriodChanged,
    this.title = 'Biểu đồ phân bổ thời gian',
    this.totalLabel = 'Tổng cộng',
    this.durationFormatter,
    this.background = const AssetImage('assets/images/chart-background.png'),
    this.headingIcon = const AssetImage('assets/images/chart-heading.png'),
  });

  final List<TimeDistributionEntry> entries;
  final String selectedPeriod;
  final List<String> periods;
  final ValueChanged<String> onPeriodChanged;
  final String title;
  final String totalLabel;
  final String Function(Duration)? durationFormatter;
  final ImageProvider background;
  final ImageProvider headingIcon;

  static String _format(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) return '${minutes}m';
    return minutes % 60 == 0
        ? '${minutes ~/ 60}h'
        : '${minutes ~/ 60}h ${minutes % 60}m';
  }

  static List<int> percentages(List<TimeDistributionEntry> entries) {
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.minutes);
    if (total == 0) return List.filled(entries.length, 0);
    final exact = entries.map((entry) => entry.minutes / total * 100).toList();
    final result = exact.map((value) => value.floor()).toList();
    final order = List.generate(entries.length, (index) => index)
      ..sort((a, b) {
        final comparison = (exact[b] - result[b]).compareTo(
          exact[a] - result[a],
        );
        return comparison == 0 ? a.compareTo(b) : comparison;
      });
    final missing = 100 - result.fold<int>(0, (sum, value) => sum + value);
    for (var index = 0; index < missing; index++) {
      result[order[index]]++;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth ? constraints.maxWidth : 397.0;
      final s = (width / 794).clamp(0.36, 1.0);
      final stacked =
          width < 320 || MediaQuery.textScalerOf(context).scale(14) > 19;
      final totalMinutes = entries.fold<double>(
        0,
        (sum, entry) => sum + entry.minutes,
      );
      final total = Duration(milliseconds: (totalMinutes * 60000).round());
      final format = durationFormatter ?? _format;
      final percents = percentages(entries);
      final diameter = 236 * s;

      final chart = SizedBox.square(
        dimension: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                centerSpaceRadius: 73 * s,
                sectionsSpace: 4 * s,
                startDegreeOffset: -90,
                pieTouchData: PieTouchData(enabled: false),
                sections: totalMinutes == 0
                    ? [
                        PieChartSectionData(
                          value: 1,
                          radius: 44 * s,
                          color: AppStyle.track(context),
                          showTitle: false,
                        ),
                      ]
                    : [
                        for (final entry in entries)
                          if (entry.minutes > 0)
                            PieChartSectionData(
                              value: entry.minutes,
                              radius: 44 * s,
                              showTitle: false,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  entry.color,
                                  entry.gradientEnd ?? entry.color,
                                ],
                              ),
                            ),
                      ],
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            ),
            SizedBox(
              width: 135 * s,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      format(total),
                      style: TextStyle(
                        fontSize: 38 * s,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppStyle.ink(context),
                      ),
                    ),
                    SizedBox(height: 5 * s),
                    Text(
                      totalLabel,
                      style: TextStyle(
                        fontSize: 23 * s,
                        color: AppStyle.muted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      final legend = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) SizedBox(height: 25 * s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 24 * s,
                  height: 24 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        entries[i].color,
                        entries[i].gradientEnd ?? entries[i].color,
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 19 * s),
                Expanded(
                  child: Text(
                    entries[i].label,
                    style: TextStyle(
                      fontSize: 26 * s,
                      color: AppStyle.ink(context),
                    ),
                  ),
                ),
                SizedBox(width: 12 * s),
                Text(
                  '${percents[i]}%',
                  style: TextStyle(
                    fontSize: 26 * s,
                    fontWeight: FontWeight.w600,
                    color: AppStyle.ink(context),
                  ),
                ),
                SizedBox(width: 15 * s),
                Text(
                  '(${format(entries[i].duration.isNegative ? Duration.zero : entries[i].duration)})',
                  style: TextStyle(
                    fontSize: 25 * s,
                    color: AppStyle.muted(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      );

      final picker = Material(
        color: AppStyle.tinted(context),
        borderRadius: BorderRadius.circular(40),
        child: PopupMenuButton<String>(
          initialValue: selectedPeriod,
          onSelected: onPeriodChanged,
          enabled: periods.isNotEmpty,
          itemBuilder: (context) => periods
              .toSet()
              .map((p) => PopupMenuItem(value: p, child: Text(p)))
              .toList(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 21 * s, vertical: 12 * s),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedPeriod,
                  style: TextStyle(
                    fontSize: 24 * s,
                    fontWeight: FontWeight.w500,
                    color: AppStyle.ink(context),
                  ),
                ),
                SizedBox(width: 7 * s),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 29 * s,
                  color: AppStyle.ink(context),
                ),
              ],
            ),
          ),
        ),
      );

      final heading = Row(
        children: [
          Image(image: headingIcon, width: 44 * s, height: 44 * s),
          SizedBox(width: 17 * s),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 30 * s,
                fontWeight: FontWeight.w600,
                color: AppStyle.ink(context),
              ),
            ),
          ),
        ],
      );

      return SizedBox(
        width: width,
        child: Container(
          constraints: BoxConstraints(minHeight: 350 * s),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.fromLTRB(35 * s, 24 * s, 25 * s, 24 * s),
          decoration: BoxDecoration(
            color: AppStyle.surface(context),
            borderRadius: BorderRadius.circular(39 * s),
            border: Border.all(color: AppStyle.border(context)),
            image: AppStyle.dark(context)
                ? null
                : DecorationImage(image: background, fit: BoxFit.fill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: heading),
                  SizedBox(width: 12 * s),
                  picker,
                ],
              ),
              SizedBox(height: 12 * s),
              if (stacked) ...[
                chart,
                SizedBox(height: 22 * s),
                legend,
              ] else
                Row(
                  children: [
                    SizedBox(width: 36 * s),
                    chart,
                    SizedBox(width: 75 * s),
                    Expanded(child: legend),
                    SizedBox(width: 34 * s),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}
