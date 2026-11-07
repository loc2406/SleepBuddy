import 'package:flutter/material.dart';
import 'package:sleep_buddy/core/config/app_style.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.completed,
    required this.goal,
    this.title = 'Tiến độ mục tiêu ngày',
    this.remainingLabel = 'Còn lại',
    this.durationFormatter,
    this.icon = const AssetImage('assets/images/target.png'),
    this.background = const AssetImage('assets/images/goal-background.png'),
  });

  final Duration completed;
  final Duration goal;
  final String title;
  final String remainingLabel;
  final String Function(Duration)? durationFormatter;
  final ImageProvider icon;
  final ImageProvider background;

  double get progress => goal.inMilliseconds <= 0
      ? 0
      : (completed.inMilliseconds / goal.inMilliseconds).clamp(0.0, 1.0);

  Duration get remaining {
    final safeGoal = goal.isNegative ? Duration.zero : goal;
    final safeCompleted = completed.isNegative ? Duration.zero : completed;
    return safeGoal > safeCompleted ? safeGoal - safeCompleted : Duration.zero;
  }

  static String _format(Duration value) {
    final minutes = value.inMinutes;
    if (minutes < 60) return '${minutes}m';
    return minutes % 60 == 0
        ? '${minutes ~/ 60}h'
        : '${minutes ~/ 60}h ${minutes % 60}m';
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth ? constraints.maxWidth : 397.0;
      final s = (width / 794).clamp(0.36, 1.0);
      final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
      final radius = BorderRadius.circular(39 * s);
      final percent = '${(progress * 100).round()}%';

      final remainingWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            remainingLabel,
            style: TextStyle(fontSize: 23 * s, color: AppStyle.muted(context)),
          ),
          SizedBox(height: 7 * s),
          Text(
            (durationFormatter ?? _format)(remaining),
            style: TextStyle(
              fontSize: 28 * s,
              fontWeight: FontWeight.w600,
              color: AppStyle.ink(context),
            ),
          ),
        ],
      );

      final progressWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            percent,
            style: TextStyle(
              fontSize: 46 * s,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: AppStyle.ink(context),
            ),
          ),
          SizedBox(height: 12 * s),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 19 * s,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppStyle.track(context)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9981F6), Color(0xFF805CF0)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

      return SizedBox(
        width: width,
        child: Container(
          constraints: BoxConstraints(minHeight: 200 * s),
          padding: EdgeInsets.fromLTRB(31 * s, 26 * s, 35 * s, 30 * s),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppStyle.surface(context),
            borderRadius: radius,
            border: Border.all(color: AppStyle.border(context)),
            image: AppStyle.dark(context)
                ? null
                : DecorationImage(image: background, fit: BoxFit.fill),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                image: icon,
                width: 77 * s,
                height: 77 * s,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28 * s,
                        fontWeight: FontWeight.w500,
                        color: AppStyle.muted(context),
                      ),
                    ),
                    SizedBox(height: 16 * s),
                    if (largeText) ...[
                      progressWidget,
                      SizedBox(height: 16 * s),
                      remainingWidget,
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: progressWidget),
                          Container(
                            width: 2 * s,
                            height: 76 * s,
                            margin: EdgeInsets.symmetric(horizontal: 31 * s),
                            color: AppStyle.border(context),
                          ),
                          remainingWidget,
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
