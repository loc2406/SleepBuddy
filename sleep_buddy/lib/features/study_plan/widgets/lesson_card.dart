import 'package:flutter/material.dart';
import 'package:sleep_buddy/features/study_plan/model/models.dart';
import 'package:sleep_buddy/features/study_plan/screens/planner_style.dart';

/// No status mutation or navigation happens inside this card.
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.onAction,
    this.statusLabel,
    this.priorityLabel,
    this.timeFormatter,
  });
  final StudyLesson lesson;
  final ValueChanged<StudyLesson>? onAction;
  final String? statusLabel;
  final String? priorityLabel;
  final String Function(TimeOfDay)? timeFormatter;

  static String formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final done = lesson.status == LessonStatus.completed;
    final active = lesson.status == LessonStatus.inProgress;
    final status =
        statusLabel ??
        switch (lesson.status) {
          LessonStatus.notStarted => 'Chưa học',
          LessonStatus.inProgress => 'Đang học',
          LessonStatus.completed => 'Đã học',
        };
    final (priorityText, bg, fg) = switch (lesson.priority) {
      LessonPriority.high => (
        'Cao',
        const Color(0xFFFFE4E8),
        const Color(0xFFD81722),
      ),
      LessonPriority.medium => (
        'Trung bình',
        const Color(0xFFFFF1DB),
        const Color(0xFFB97616),
      ),
      LessonPriority.low => (
        'Thấp',
        const Color(0xFFE8F8EE),
        const Color(0xFF319862),
      ),
    };
    final formatter = timeFormatter ?? formatTime;
    final statusText = Text(
      status,
      style: TextStyle(
        fontSize: 10.5,
        height: 1.2,
        color: done
            ? PlannerStyle.success
            : active
            ? const Color(0xFF7352C6)
            : PlannerStyle.secondary(context),
      ),
    );

    final action = done
        ? Semantics(
            label: status,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6BC88C),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        : IconButton(
            key: ValueKey('lesson-action-${lesson.id}'),
            tooltip: active ? 'Tiếp tục học' : 'Xem bài học',
            onPressed: onAction == null ? null : () => onAction!(lesson),
            icon: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? null : const Color(0xFFF1EDFF),
                gradient: active ? PlannerStyle.primaryGradient : null,
              ),
              child: Icon(
                active ? Icons.play_arrow_rounded : Icons.chevron_right_rounded,
                size: 23,
                color: active ? Colors.white : PlannerStyle.purple,
              ),
            ),
          );

    return PlannerSurface(
      highlighted: active,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow =
              constraints.maxWidth < 250 ||
              MediaQuery.textScalerOf(context).scale(14) > 22;
          final subject = PlannerBadge(label: lesson.subject);
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: done
                      ? PlannerStyle.secondary(context)
                      : PlannerStyle.ink(context),
                ),
              ),
              if (lesson.description.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: done
                        ? PlannerStyle.secondary(context)
                        : PlannerStyle.secondary(context),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              // Separate wrap children instead of a rigid time/priority Row.
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: Color(0xFF8071AC),
                            ),
                          ),
                        ),
                        TextSpan(
                          text:
                              '${formatter(lesson.startTime)} – ${formatter(lesson.endTime)}',
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: PlannerStyle.secondary(context),
                    ),
                  ),
                  PlannerBadge(
                    label: priorityLabel ?? priorityText,
                    background: bg,
                    foreground: fg,
                    fontSize: 11,
                  ),
                ],
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (narrow)
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [subject, statusText],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: subject,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: statusText,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 7),
              if (narrow) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image(
                      image: lesson.image,
                      width: 36,
                      height: 38,
                      excludeFromSemantics: true,
                    ),
                    action,
                  ],
                ),
                const SizedBox(height: 6),
                details,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: done ? .75 : 1,
                      child: Image(
                        image: lesson.image,
                        width: 36,
                        height: 38,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: details),
                    action,
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
