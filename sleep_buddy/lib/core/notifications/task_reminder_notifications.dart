import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sleep_buddy/core/db/settings_dao.dart';
import 'package:sleep_buddy/core/db/sleep_dao.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
import 'package:sleep_buddy/features/study_plan/model/models.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void taskReminderBackgroundResponse(NotificationResponse response) {}

class TaskReminderNotifications {
  TaskReminderNotifications._();

  static final instance = TaskReminderNotifications._();

  static const _channelId = 'study_task_reminders';
  static const _categoryId = 'study_task_reminder';
  static const _startActionId = 'start_task';
  static const _laterActionId = 'later_task';
  static const _sleepReminderId = 0x7fffffff;
  static const _sleepReminderPayload = 'sleep_reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void> Function(int taskId)? onStartTask;
  Future<void> Function(int taskId)? onOpenFocusTask;
  VoidCallback? onOpenPlanner;
  VoidCallback? onOpenSleep;
  VoidCallback? onTaskStartRejected;
  bool _initialized = false;

  bool get _supportsLocalScheduling =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize({
    required Future<void> Function(int taskId) onStartTask,
    required Future<void> Function(int taskId) onOpenFocusTask,
    required VoidCallback onOpenPlanner,
    required VoidCallback onOpenSleep,
    required VoidCallback onTaskStartRejected,
  }) async {
    if (_initialized) return;
    this.onStartTask = onStartTask;
    this.onOpenFocusTask = onOpenFocusTask;
    this.onOpenPlanner = onOpenPlanner;
    this.onOpenSleep = onOpenSleep;
    this.onTaskStartRejected = onTaskStartRejected;
    if (!_supportsLocalScheduling) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: [
          DarwinNotificationCategory(
            _categoryId,
            actions: [
              DarwinNotificationAction.plain(
                _startActionId,
                'Bắt đầu',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(_laterActionId, 'Để sau'),
            ],
          ),
        ],
      ),
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleResponse,
      onDidReceiveBackgroundNotificationResponse:
          taskReminderBackgroundResponse,
    );
    _initialized = true;
  }

  Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await androidPlugin?.requestExactAlarmsPermission() ?? false;
  }

  Future<void> handleLaunchDetails() async {
    _ensureInitialized();
    if (!_supportsLocalScheduling) return;
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final response = launchDetails?.notificationResponse;
    if (launchDetails?.didNotificationLaunchApp == true && response != null) {
      await _processResponse(response);
    }
  }

  Future<void> syncScheduledReminders() async {
    _ensureInitialized();
    if (!_supportsLocalScheduling) return;
    final notificationsEnabled = await SettingsDao.getBool(
      'notifications_enabled',
      false,
    );
    if (!notificationsEnabled) {
      await _plugin.cancelAll();
      return;
    }

    final tasks = await StudyTaskDao.getPendingTaskReminders();
    final inProgressTasks = await StudyTaskDao.getInProgressTaskReminders();
    final sleepReminderSettings = await SleepDao.getReminderSettings();
    final now = DateTime.now();
    final futureTasks = tasks
        .where((task) => task.startsAt.isAfter(now))
        .toList();
    final futureInProgressTasks = inProgressTasks
        .where((task) => task.endsAt.isAfter(now))
        .toList();
    final nextSleepReminder = nextReminderDate(
      sleepReminderSettings.reminderTime,
      now,
    );
    final shouldScheduleSleepReminder =
        sleepReminderSettings.enabled && nextSleepReminder.isAfter(now);
    final futureTaskIds = {
      ...futureTasks.map((task) => task.id),
      ...futureInProgressTasks.map((task) => task.id),
      if (shouldScheduleSleepReminder) _sleepReminderId,
    };
    final pendingNotifications = await _plugin.pendingNotificationRequests();
    for (final notification in pendingNotifications) {
      if (!futureTaskIds.contains(notification.id)) {
        await _plugin.cancel(notification.id);
      }
    }
    for (final task in futureTasks) {
      await scheduleTask(
        id: task.id,
        title: task.title,
        startsAt: task.startsAt,
        priority: task.priority,
      );
    }
    for (final task in futureInProgressTasks) {
      await scheduleTaskEnd(
        id: task.id,
        title: task.title,
        endsAt: task.endsAt,
      );
    }
    if (shouldScheduleSleepReminder) {
      await scheduleSleepReminder(nextSleepReminder);
    }
  }

  Future<void> scheduleSleepReminder(DateTime remindAt) async {
    _ensureInitialized();
    if (!_supportsLocalScheduling || !remindAt.isAfter(DateTime.now())) return;
    final notificationsEnabled = await SettingsDao.getBool(
      'notifications_enabled',
      false,
    );
    if (!notificationsEnabled) return;

    await _plugin.zonedSchedule(
      _sleepReminderId,
      'Đã đến giờ chuẩn bị ngủ',
      'Hãy bắt đầu thư giãn để chuẩn bị cho giấc ngủ tối nay.',
      tz.TZDateTime.from(remindAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_bedtime_reminder',
          'Nhắc chuẩn bị ngủ',
          channelDescription: 'Nhắc người dùng chuẩn bị đi ngủ',
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          enableVibration: false,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentSound: false,
          interruptionLevel: InterruptionLevel.passive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _sleepReminderPayload,
    );
  }

  static DateTime nextReminderDate(TimeOfDay time, DateTime now) {
    var reminder = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!reminder.isAfter(now)) {
      reminder = reminder.add(const Duration(days: 1));
    }
    return reminder;
  }

  Future<void> scheduleTask({
    required int id,
    required String title,
    required DateTime startsAt,
    required LessonPriority priority,
  }) async {
    _ensureInitialized();
    if (!_supportsLocalScheduling) return;
    final notificationsEnabled = await SettingsDao.getBool(
      'notifications_enabled',
      false,
    );
    if (!notificationsEnabled || !startsAt.isAfter(DateTime.now())) return;

    final style = notificationStyleForPriority(priority);
    await _plugin.zonedSchedule(
      id,
      style.title,
      title,
      tz.TZDateTime.from(startsAt, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          style.channelId,
          style.channelName,
          channelDescription: style.channelDescription,
          importance: style.importance,
          priority: style.priority,
          playSound: style.playSound,
          enableVibration: style.enableVibration,
          silent: !style.playSound,
          icon: 'ic_notification',
          actions: [
            AndroidNotificationAction(
              _startActionId,
              'Bắt đầu',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(_laterActionId, 'Để sau'),
          ],
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: _categoryId,
          presentSound: style.playSound,
          interruptionLevel: style.interruptionLevel,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id.toString(),
    );
  }

  static ({
    String title,
    String channelId,
    String channelName,
    String channelDescription,
    Importance importance,
    Priority priority,
    bool playSound,
    bool enableVibration,
    InterruptionLevel interruptionLevel,
  })
  notificationStyleForPriority(LessonPriority priority) => switch (priority) {
    LessonPriority.high => (
      title: 'Nhiệm vụ ưu tiên cao đến giờ',
      channelId: '${_channelId}_high',
      channelName: 'Nhiệm vụ ưu tiên cao',
      channelDescription:
          'Thông báo nổi bật có âm thanh cho nhiệm vụ ưu tiên cao',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      interruptionLevel: InterruptionLevel.active,
    ),
    LessonPriority.medium => (
      title: 'Đã đến giờ học',
      channelId: '${_channelId}_medium',
      channelName: 'Nhiệm vụ ưu tiên trung bình',
      channelDescription: 'Thông báo có âm thanh cho nhiệm vụ học tập',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      interruptionLevel: InterruptionLevel.active,
    ),
    LessonPriority.low => (
      title: 'Đến giờ học',
      channelId: '${_channelId}_low',
      channelName: 'Nhiệm vụ ưu tiên thấp',
      channelDescription: 'Thông báo yên lặng cho nhiệm vụ ưu tiên thấp',
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      enableVibration: false,
      interruptionLevel: InterruptionLevel.passive,
    ),
  };

  Future<void> scheduleTaskEnd({
    required int id,
    required String title,
    required DateTime endsAt,
  }) async {
    _ensureInitialized();
    if (!_supportsLocalScheduling || !endsAt.isAfter(DateTime.now())) return;
    final notificationsEnabled = await SettingsDao.getBool(
      'notifications_enabled',
      false,
    );
    if (!notificationsEnabled) return;

    await _plugin.zonedSchedule(
      id,
      'Nhiệm vụ đã kết thúc',
      title,
      tz.TZDateTime.from(endsAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Nhắc nhở nhiệm vụ học tập',
          channelDescription: 'Thông báo khi nhiệm vụ học tập kết thúc',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'end:$id',
    );
  }

  Future<void> cancelTask(int id) async {
    _ensureInitialized();
    if (!_supportsLocalScheduling) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    _ensureInitialized();
    if (!_supportsLocalScheduling) return;
    await _plugin.cancelAll();
  }

  void _handleResponse(NotificationResponse response) {
    _processResponse(response).catchError((Object error, StackTrace stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'task reminder notifications',
          context: ErrorDescription('while handling a task reminder action'),
        ),
      );
    });
  }

  Future<void> _processResponse(NotificationResponse response) async {
    if (response.actionId == _laterActionId) return;
    final payload = response.payload;
    if (payload == null) {
      throw const FormatException('Task reminder is missing its task ID.');
    }
    if (payload == _sleepReminderPayload) {
      final openSleep = onOpenSleep;
      if (openSleep == null) {
        throw StateError('Sleep reminder handler has not been configured.');
      }
      openSleep();
      return;
    }
    final isEndNotification = payload.startsWith('end:');
    final idText = isEndNotification ? payload.substring(4) : payload;
    final taskId = int.tryParse(idText);
    if (taskId == null) {
      throw FormatException('Invalid task reminder ID: $idText');
    }

    if (isEndNotification) {
      final openFocusTask = onOpenFocusTask;
      if (openFocusTask == null) {
        throw StateError('Task end handler has not been configured.');
      }
      await openFocusTask(taskId);
      return;
    }

    if (response.actionId == _startActionId) {
      final started = await StudyTaskDao.startTaskFromReminder(taskId);
      if (!started) {
        await cancelTask(taskId);
        onTaskStartRejected?.call();
        return;
      }
      await cancelTask(taskId);
      final startTask = onStartTask;
      if (startTask == null) {
        throw StateError('Task start handler has not been configured.');
      }
      await startTask(taskId);
      return;
    }

    onOpenPlanner?.call();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('Task reminder notifications are not initialized.');
    }
  }
}
