import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'constants.dart' as c;

class NotificationService {
  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    //Initialization Settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    //Initializing settings for both platforms (Android & iOS)
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<dynamic> onSelectNotification(String? payload) async {
    //Navigate to wherever you want
  }

  requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showNotifications({id, title, body, payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            c.NOTIFICATION_CHANNEL_ID, c.NOTIFICATION_CHANNEL_NAME,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  Future<void> scheduleNotifications({id, title, body, time}) async {
    try {
      bool skip = false;
      int idAsInt = getNotificationIdForItem(id);
      List<PendingNotificationRequest> pending =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      for (var p in pending) {
        if (p.id == idAsInt) {
          if (p.title == title && p.body == body) {
            skip = true;
          } else {
            await flutterLocalNotificationsPlugin.cancel(p.id);
          }
        }
      }
      if (!skip) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
            idAsInt,
            title,
            body,
            tz.TZDateTime.from(time, tz.local),
            const NotificationDetails(
                android: AndroidNotificationDetails(
                    c.NOTIFICATION_CHANNEL_ID, c.NOTIFICATION_CHANNEL_NAME)),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> clearScheduledNotifications() async {
    List<PendingNotificationRequest> pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var p in pending) {
      await flutterLocalNotificationsPlugin.cancel(p.id);
    }
  }

  Future<void> clearScheduledNotificationForItem(String itemId) async {
    int id = getNotificationIdForItem(itemId);
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  int getNotificationIdForItem(String itemId) {
    String idAsString = "";
    List<int> bytes = utf8.encode(itemId);
    for (int i in bytes) {
      idAsString += i.toString();
    }
    return int.tryParse(idAsString.substring(0, 9))!;
  }
}
