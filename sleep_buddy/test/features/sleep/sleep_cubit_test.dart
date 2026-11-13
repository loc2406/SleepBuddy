import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleep_buddy/core/notifications/task_reminder_notifications.dart';
import 'package:sleep_buddy/features/sleep/cubit/sleep_cubit.dart';

void main() {
  test(
    'sleep interval rolls bedtime to the previous day when it crosses midnight',
    () {
      final interval = SleepCubit.sleepIntervalForWakeDate(
        wakeDate: DateTime(2026, 11, 13),
        bedTime: const TimeOfDay(hour: 22, minute: 45),
        wakeTime: const TimeOfDay(hour: 6, minute: 30),
      );

      expect(interval.bedTime, DateTime(2026, 11, 12, 22, 45));
      expect(interval.wakeTime, DateTime(2026, 11, 13, 6, 30));
      expect(
        interval.wakeTime.difference(interval.bedTime),
        const Duration(hours: 7, minutes: 45),
      );
    },
  );

  test('sleep interval stays on the wake date when bedtime is earlier', () {
    final interval = SleepCubit.sleepIntervalForWakeDate(
      wakeDate: DateTime(2026, 11, 13),
      bedTime: const TimeOfDay(hour: 1, minute: 15),
      wakeTime: const TimeOfDay(hour: 7, minute: 15),
    );

    expect(interval.bedTime, DateTime(2026, 11, 13, 1, 15));
  });

  test('sleep reminder uses today if still upcoming, otherwise tomorrow', () {
    final now = DateTime(2026, 11, 13, 21, 0);

    expect(
      TaskReminderNotifications.nextReminderDate(
        const TimeOfDay(hour: 22, minute: 15),
        now,
      ),
      DateTime(2026, 11, 13, 22, 15),
    );
    expect(
      TaskReminderNotifications.nextReminderDate(
        const TimeOfDay(hour: 20, minute: 0),
        now,
      ),
      DateTime(2026, 11, 14, 20, 0),
    );
  });
}
