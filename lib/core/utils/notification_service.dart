import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static const _taskChannel = AndroidNotificationDetails(
    'taskflow_tasks',
    'Tâches TaskFlow',
    channelDescription: 'Notifications pour les tâches',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: _taskChannel),
    );
  }

  static Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    final reminderTime = dueDate.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      'Tâche bientôt due',
      taskTitle,
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(android: _taskChannel),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
