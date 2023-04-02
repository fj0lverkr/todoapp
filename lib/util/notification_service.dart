import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'constants.dart' as c;
import 'package:todoapp/model/item.dart';
import 'package:todoapp/model/database.dart' as db;

class NotificationService {
  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    //Initialization Settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    //Initializing settings for both platforms (Android & iOS)
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      if (notificationResponse.actionId == "set_done") {
        List<String> payloads = notificationResponse.payload!.split("|");
        TodoItem item = TodoItem.fromJson(payloads[0]);
        db.TodoDatabase(payloads[1]).toggleItemDone(item, true);
      }
    }
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

  Future<void> scheduleNotifications(TodoItem item, String uid,
      {id, title, body, time}) async {
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
                c.NOTIFICATION_CHANNEL_ID,
                c.NOTIFICATION_CHANNEL_NAME,
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker',
                visibility: NotificationVisibility.public,
                enableLights: true,
                actions: <AndroidNotificationAction>[
                  AndroidNotificationAction(
                    'mark_done',
                    'Mark done',
                  ),
                ],
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: "$jsonEncode(item)|$uid");
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
