import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/wellness/domain/model/models.dart';
import 'package:sleep_buddy/features/wellness/presentation/widgets/style.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.iconName,
    this.colors = const [Color(0xFFF6FBFF), Color(0xFFE0EDFF)],
  });
  final String title, value, caption, iconName;
  final List<Color> colors;
  @override
  Widget build(BuildContext c) => WellnessCard(
    gradient: LinearGradient(colors: colors),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AssetIcon(iconName, size: 24),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 13, color: AppStyle.ink(c)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: TextStyle(
            fontSize: 23,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: AppStyle.ink(c),
          ),
        ),
        const SizedBox(height: 12),
        Text(caption, style: TextStyle(fontSize: 11, color: AppStyle.muted(c))),
      ],
    ),
  );
}

class StudyTimeChartCard extends StatelessWidget {
  const StudyTimeChartCard({
    super.key,
    required this.points,
    this.title = 'Nhịp học trong tuần',
    this.emptyLabel = 'Chưa có dữ liệu học tập.',
  });
  final List<StudyBar> points;
  final String title, emptyLabel;
  String _number(double n) => n == n.roundToDouble()
      ? n.toStringAsFixed(0)
      : n.toStringAsFixed(1).replaceAll('.', ',');
  @override
  Widget build(BuildContext c) => WellnessCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 5,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppStyle.ink(c),
              ),
            ),
            Text(
              'Giờ học',
              style: TextStyle(fontSize: 10.5, color: AppStyle.muted(c)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (points.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(emptyLabel, style: TextStyle(color: AppStyle.muted(c))),
          )
        else
          LayoutBuilder(
            builder: (c, box) {
              final scale = MediaQuery.textScalerOf(c).scale(11) / 11;
              final largest = points.fold<double>(
                0,
                (a, b) => math.max(a, b.safeHours),
              );
              final peak = math.max(1.0, largest);
              final step = peak > 4 ? (peak / 4).ceilToDouble() : 1.0;
              final top = (peak / step).ceil() * step + step * .6;
              double labelWidth = 40;
              for (final point in points) {
                final p = TextPainter(
                  text: TextSpan(
                    text: point.label,
                    style: const TextStyle(fontSize: 11),
                  ),
                  textDirection: Directionality.of(c),
                  textScaler: MediaQuery.textScalerOf(c),
                )..layout();
                labelWidth = math.max(labelWidth, p.width + 16);
                p.dispose();
              }
              final chartWidth = math.max(
                box.maxWidth,
                points.length * labelWidth + 44 * scale,
              );
              return Semantics(
                label: points
                    .map((p) => '${p.label}: ${_number(p.safeHours)} giờ')
                    .join(', '),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    height: 155 + 42 * scale,
                    child: ExcludeSemantics(
                      child: BarChart(
                        BarChartData(
                          maxY: top,
                          minY: 0,
                          alignment: BarChartAlignment.spaceAround,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: step,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: AppStyle.border(c),
                              strokeWidth: .6,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: step,
                                reservedSize: 42 * scale,
                                getTitlesWidget: (value, meta) => value > peak
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Text(
                                          '${_number(value)}h',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppStyle.muted(c),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28 * scale,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= points.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      points[i].label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppStyle.muted(c),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            enabled: false,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.transparent,
                              tooltipPadding: EdgeInsets.zero,
                              tooltipMargin: 5,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) =>
                                      BarTooltipItem(
                                        _number(rod.toY),
                                        const TextStyle(
                                          fontSize: 10,
                                          color: AppStyle.purple,
                                        ),
                                      ),
                            ),
                          ),
                          barGroups: [
                            for (var i = 0; i < points.length; i++)
                              BarChartGroupData(
                                x: i,
                                showingTooltipIndicators: const [0],
                                barRods: [
                                  BarChartRodData(
                                    toY: points[i].safeHours,
                                    width: 20,
                                    borderRadius: BorderRadius.circular(7),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFAC8BF7),
                                        Color(0xFF8057EF),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        duration: Duration.zero,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );
}

class SubjectTimeCard extends StatelessWidget {
  const SubjectTimeCard({
    super.key,
    required this.subjects,
    this.title = 'Thời gian theo môn học',
  });
  final List<SubjectDuration> subjects;
  final String title;
  @override
  Widget build(BuildContext c) {
    final maxSeconds = subjects.fold<int>(
      0,
      (v, s) => math.max(v, s.duration.inSeconds),
    );
    return WellnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppStyle.ink(c),
            ),
          ),
          const SizedBox(height: 14),
          if (subjects.isEmpty)
            Text(
              'Chưa có dữ liệu môn học.',
              style: TextStyle(color: AppStyle.muted(c)),
            ),
          for (var i = 0; i < subjects.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            LayoutBuilder(
              builder: (c, box) {
                final subject = subjects[i];
                final bar = GradientProgress(
                  value: safeFraction(subject.duration.inSeconds, maxSeconds),
                  color: subject.color,
                  label: subject.name,
                );
                final name = Text(
                  subject.name,
                  style: TextStyle(fontSize: 12, color: AppStyle.ink(c)),
                );
                final value = Text(
                  durationLabel(subject.duration),
                  style: TextStyle(fontSize: 12, color: AppStyle.muted(c)),
                );
                if (box.maxWidth < 290 ||
                    MediaQuery.textScalerOf(c).scale(12) > 18) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(spacing: 12, runSpacing: 4, children: [name, value]),
                      const SizedBox(height: 8),
                      bar,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(flex: 3, child: name),
                    const SizedBox(width: 10),
                    Expanded(flex: 5, child: bar),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: value,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class PlanCompletionCard extends StatelessWidget {
  const PlanCompletionCard({
    super.key,
    required this.completed,
    required this.total,
  });
  final int completed, total;
  @override
  Widget build(BuildContext c) {
    final progress = safeFraction(completed, total);
    return WellnessCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AssetIcon('target', size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoàn thành kế hoạch',
                      style: TextStyle(fontSize: 14, color: AppStyle.muted(c)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 16,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: AppStyle.ink(c),
                          ),
                        ),
                        Text(
                          '$completed / $total bài học',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppStyle.muted(c),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GradientProgress(value: progress),
          const SizedBox(height: 12),
          Text(
            total <= 0
                ? 'Chưa có bài học trong kỳ này.'
                : 'Còn ${math.max(0, total - completed)} bài học chưa hoàn thành.',
            style: TextStyle(fontSize: 11.5, color: AppStyle.muted(c)),
          ),
        ],
      ),
    );
  }
}
