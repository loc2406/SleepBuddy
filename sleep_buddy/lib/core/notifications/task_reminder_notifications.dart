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
  VoidCallback? onOpenPlanner;
  bool _initialized = false;

  bool get _supportsLocalScheduling =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize({
    required Future<void> Function(int taskId) onStartTask,
    required VoidCallback onOpenPlanner,
  }) async {
    if (_initialized) return;
    this.onStartTask = onStartTask;
    this.onOpenPlanner = onOpenPlanner;
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
    final now = DateTime.now();
    final futureTasks = tasks
        .where((task) => task.startsAt.isAfter(now))
        .toList();
    final futureTaskIds = futureTasks.map((task) => task.id).toSet();
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
    final taskId = int.tryParse(payload);
    if (taskId == null) {
      throw FormatException('Invalid task reminder ID: $payload');
    }

    if (response.actionId == _startActionId) {
      final started = await StudyTaskDao.startTaskFromReminder(taskId);
      await cancelTask(taskId);
      if (!started) {
        onOpenPlanner?.call();
        return;
      }
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
