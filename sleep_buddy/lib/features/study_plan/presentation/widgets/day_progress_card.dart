import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/study_plan/presentation/screens/planner_style.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class DayProgressCard extends StatelessWidget {
  const DayProgressCard({
    super.key,
    required this.totalLessons,
    required this.completedLessons,
    this.title = 'Tiến độ hôm nay',
    this.subtitle,
    this.image = const AssetImage('assets/images/target.png'),
  });
  final int totalLessons;
  final int completedLessons;
  final String title;
  final String? subtitle;
  final ImageProvider image;

  double get progress =>
      totalLessons <= 0 ? 0 : (completedLessons / totalLessons).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) => PlannerSurface(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.15,
                    color: PlannerStyle.secondary(context),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle ??
                      '$totalLessons bài học hôm nay • $completedLessons bài hoàn thành',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: PlannerStyle.secondary(context),
                  ),
                ),
              ],
            );
            final percent = Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 22,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: PlannerStyle.purple,
              ),
            );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                  image: image,
                  width: 32,
                  height: 32,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleBlock,
                            const SizedBox(height: 8),
                            percent,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: titleBlock),
                            const SizedBox(width: 12),
                            percent,
                          ],
                        ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 9),
        Semantics(
          label: title,
          value: '${(progress * 100).round()}%',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppStyle.track(context)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA086FC), Color(0xFF805CF0)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
