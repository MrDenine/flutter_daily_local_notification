import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    tz.setLocalLocation(tz.getLocation("Asia/Bangkok"));

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(requestSoundPermission: false, requestBadgePermission: false, requestAlertPermission: false);
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyNotification(DateTime selectedTime) async {
    if (selectedTime.isBefore(DateTime.now())) {
      selectedTime = selectedTime.add(const Duration(days: 1));
    }
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(selectedTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(0, "notification title", "notification body", scheduledTime, _notificationDetails(), androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, matchDateTimeComponents: DateTimeComponents.time);

      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  NotificationDetails _notificationDetails() {
    return NotificationDetails(android: AndroidNotificationDetails('your_channel_id', 'your_channel_name', importance: Importance.max, priority: Priority.high, showWhen: false), iOS: DarwinNotificationDetails());
  }
}
