import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sleep_buddy/core/db/settings_dao.dart';
import 'package:sleep_buddy/core/db/study_task_dao.dart';
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

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void> Function(int taskId)? onStartTask;
  Future<void> Function(int taskId)? onOpenFocusTask;
  VoidCallback? onOpenPlanner;
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
    required VoidCallback onTaskStartRejected,
  }) async {
    if (_initialized) return;
    this.onStartTask = onStartTask;
    this.onOpenFocusTask = onOpenFocusTask;
    this.onOpenPlanner = onOpenPlanner;
    this.onTaskStartRejected = onTaskStartRejected;
    if (!_supportsLocalScheduling) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
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
    final now = DateTime.now();
    final futureTasks = tasks
        .where((task) => task.startsAt.isAfter(now))
        .toList();
    final futureInProgressTasks = inProgressTasks
        .where((task) => task.endsAt.isAfter(now))
        .toList();
    final futureTaskIds = {
      ...futureTasks.map((task) => task.id),
      ...futureInProgressTasks.map((task) => task.id),
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
      );
    }
    for (final task in futureInProgressTasks) {
      await scheduleTaskEnd(
        id: task.id,
        title: task.title,
        endsAt: task.endsAt,
      );
    }
  }

  Future<void> scheduleTask({
    required int id,
    required String title,
    required DateTime startsAt,
  }) async {
    _ensureInitialized();
    if (!_supportsLocalScheduling) return;
    final notificationsEnabled = await SettingsDao.getBool(
      'notifications_enabled',
      false,
    );
    if (!notificationsEnabled || !startsAt.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      'Đã đến giờ học',
      title,
      tz.TZDateTime.from(startsAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Nhắc nhở nhiệm vụ học tập',
          channelDescription: 'Thông báo khi nhiệm vụ học tập đến giờ bắt đầu',
          importance: Importance.high,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction(
              _startActionId,
              'Bắt đầu',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(_laterActionId, 'Để sau'),
          ],
        ),
        iOS: DarwinNotificationDetails(categoryIdentifier: _categoryId),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: id.toString(),
    );
  }

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
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
