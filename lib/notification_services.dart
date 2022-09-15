import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'page_navigation.dart';

/// NotifyHelper for handling notifications.
/// NotifyHelper requires a [context] to navigate after tapping on a
/// notification.
class NotifyHelper {
  NotifyHelper({required this.context});

  /// Current context.
  var context;

  /// Initialize plugin.
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); //

  // Initialising notifications.
  initializeNotification() async {
    tz.initializeTimeZones();
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    // Initialize android settings.
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("studytracker_logo");

    // Initialize ios settings.
    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  /// Request permission for IOS
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Schedule a notification, part1.
  scheduledNotification(int id, DateTime deadline, Duration reminder,
      String title, String body, String payload, BuildContext context) {
    DateTime _now = tz.TZDateTime.now(tz.local);
    DateTime _reminderDateTime = deadline.subtract(reminder);
    Duration _finalDuration = _reminderDateTime.difference(_now);

    _scheduledNotificationPart2(
        id: id,
        title: title,
        body: body,
        duration: _finalDuration,
        context: context);
  }

  /// Schedule a notification, part2.
  _scheduledNotificationPart2(
      {required int id,
      required String title,
      required String body,
      required Duration duration,
      required BuildContext context}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(duration),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                // Channel id & name for grouping notifications.
                // Channel 0 -> grouping reminder notifications.
                '0',
                'reminder',
                )),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  /// Delete a notification with a specific id.
  Future<void> deleteNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all current notifications.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future selectNotification(String? payload) async {
    Navigation.selectedNavBarIndex.value = 1;
    Navigation.pageController.jumpToPage(1);
  }
}
