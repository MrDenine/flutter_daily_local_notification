import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // initialization
  Future<void> init() async {
    // initialize timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // initialize android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // initialize ios
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false);

    // initialize settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    // initialize
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // immediate notification
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) {
    return _notificationsPlugin.show(id, title, body, _notificationDetails());
  }

  // schedule notification
  Future<void> scheduleDailyNotification(
    DateTime selectedTime, {
    int id = 1,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (selectedTime.isBefore(DateTime.now())) {
      selectedTime = selectedTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(selectedTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
          id, title, body, scheduledTime, _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time);

      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // cancel notification
  Future<void> cancelNotification(int id, {String? tag}) async {
    await _notificationsPlugin.cancel(id, tag: tag);
  }

  // cancel all notification
  Future<void> cancelAllNotification() async {
    await _notificationsPlugin.cancelAll();
  }

  // notification detail
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
        android: AndroidNotificationDetails(
            'your_channel_id', 'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true),
        iOS: DarwinNotificationDetails());
  }
}
