import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_buddy/core/notifications/task_reminder_notifications.dart';
import 'package:sleep_buddy/features/study_plan/model/models.dart';

void main() {
  test('high priority reminders are prominent and alert audibly', () {
    final style = TaskReminderNotifications.notificationStyleForPriority(
      LessonPriority.high,
    );

    expect(style.importance, Importance.max);
    expect(style.playSound, isTrue);
    expect(style.enableVibration, isTrue);
    expect(style.interruptionLevel, InterruptionLevel.active);
  });

  test('low priority reminders are quiet while medium remains standard', () {
    final medium = TaskReminderNotifications.notificationStyleForPriority(
      LessonPriority.medium,
    );
    final low = TaskReminderNotifications.notificationStyleForPriority(
      LessonPriority.low,
    );

    expect(medium.importance, Importance.high);
    expect(medium.playSound, isTrue);
    expect(low.importance, Importance.low);
    expect(low.playSound, isFalse);
    expect(low.enableVibration, isFalse);
    expect(low.interruptionLevel, InterruptionLevel.passive);
  });
}
