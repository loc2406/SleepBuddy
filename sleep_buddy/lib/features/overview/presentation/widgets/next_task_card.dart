import 'package:flutter/material.dart';

class NextTaskCard extends StatelessWidget {
  const NextTaskCard({
    super.key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.priorityLabel,
    required this.onViewSchedule,
    this.heading = 'Công việc tiếp theo',
    this.priorityPrefix = 'Ưu tiên:',
    this.buttonLabel = 'Xem lịch',
    this.priorityColor = const Color(0xFFD81722),
    this.priorityBackground = const Color(0xFFFFE4E8),
    this.timeFormatter,
    this.icon = const AssetImage('assets/images/book.png'),
    this.background = const AssetImage('assets/images/task-background.png'),
  });

  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String priorityLabel;
  final VoidCallback onViewSchedule;
  final String heading;
  final String priorityPrefix;
  final String buttonLabel;
  final Color priorityColor;
  final Color priorityBackground;
  final String Function(TimeOfDay)? timeFormatter;
  final ImageProvider icon;
  final ImageProvider background;

  static String _format(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth ? constraints.maxWidth : 397.0;
      final s = (width / 794).clamp(0.36, 1.0);
      final stacked = width < 320 || MediaQuery.textScalerOf(context).scale(14) > 19;
      final format = timeFormatter ?? _format;

      final button = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7851F4), Color(0xFF9067FF), Color(0xFF7845EE)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: onViewSchedule,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 12 * s),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buttonLabel,
                    style: TextStyle(
                      fontSize: 24 * s,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 5 * s),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 30 * s,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final task = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(image: icon, width: 83 * s, height: 88 * s, fit: BoxFit.contain),
          SizedBox(width: 23 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 31 * s,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF130B36),
                  ),
                ),
                SizedBox(height: 10 * s),
                Wrap(
                  spacing: 10 * s,
                  runSpacing: 6 * s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 25 * s,
                          color: const Color(0xFF8071AC),
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          '${format(startTime)} – ${format(endTime)}',
                          style: TextStyle(
                            fontSize: 25 * s,
                            color: const Color(0xFF655A90),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 23 * s,
                        color: const Color(0xFF8274A9),
                      ),
                    ),
                    Text(
                      priorityPrefix,
                      style: TextStyle(
                        fontSize: 24 * s,
                        color: const Color(0xFF655A90),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: priorityBackground,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * s,
                          vertical: 5 * s,
                        ),
                        child: Text(
                          priorityLabel,
                          style: TextStyle(
                            fontSize: 23 * s,
                            height: 1.15,
                            color: priorityColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [Color(0xFFE6DFFF), Color(0xFFDDD4FF)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * s,
                vertical: 9 * s,
              ),
              child: Text(
                heading,
                style: TextStyle(
                  fontSize: 25 * s,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4020B0),
                ),
              ),
            ),
          ),
          SizedBox(height: 18 * s),
          task,
        ],
      );

      return SizedBox(
        width: width,
        child: Container(
          constraints: BoxConstraints(minHeight: 200 * s),
          padding: EdgeInsets.fromLTRB(34 * s, 24 * s, 25 * s, 25 * s),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(39 * s),
            color: const Color(0xFFFEFDFF),
            image: DecorationImage(image: background, fit: BoxFit.fill),
          ),
          child: stacked
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    content,
                    SizedBox(height: 14 * s),
                    Align(alignment: Alignment.centerRight, child: button),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: content),
                    SizedBox(width: 18 * s),
                    button,
                  ],
                ),
        ),
      );
    },
  );
}