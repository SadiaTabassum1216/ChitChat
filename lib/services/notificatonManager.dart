import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationManager {
  static Future initialize() async {
    final List<int> vibrationPattern = [500];

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'login_notification_channel',
          channelName: 'login notification channel',
          channelDescription:
              'When a user is login then this will be the channel.',
          defaultColor: Colors.green,
          playSound: true,
          channelShowBadge: true,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
        ),
        NotificationChannel(
          channelKey: 'logout_notification_channel',
          channelName: 'logout notification channel',
          channelDescription:
              'When a user is logged out then this will be the channel.',
          defaultColor: Colors.green,
          playSound: true,
          channelShowBadge: true,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'message channel',
          channelName: 'message channel',
          channelDescription:
              'When a new message appears, it will push notification for that.',
          defaultColor: Colors.green,
          playSound: true,
          channelShowBadge: true,
          ledColor: Colors.white,
          onlyAlertOnce: false,
          enableVibration: true,
          importance: NotificationImportance.High,
        ),
      ],
    );

    print('Channel created');

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future createNotification(
      {required int id,
      required String title,
      required String body,
      required bool locked,
      required String channel_name}) async {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: id,
      channelKey: channel_name,
      title: title,
      body: body,
      actionType: ActionType.Default,
      backgroundColor: Color(0x008000),
      displayOnForeground: true,
      displayOnBackground: true,
      locked: locked,
    ));

    print("Notification pushed.");
  }
}
