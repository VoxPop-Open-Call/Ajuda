import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';
import 'firebase_notification.dart';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@drawable/ic_launcher_playstore');

  static final DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (
        int id,
        String? title,
        String? body,
        String? payload,
        ) =>
        didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title!,
            body: body!,
            payload: payload!,
          ),
        ),
  );

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS);

  initialize() async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
          selectedNotificationPayload = payload.toString();
          selectNotificationSubject.add(payload.toString());
        });
  }

  // initializeLocal() async {
  //   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
  //       onSelectNotification: (payload) async {
  //         selectedNotificationPayload = payload.toString();
  //         selectNotificationSubject.add(payload.toString());
  //       });
  //   // repeatNotification();
  // }

  Future<void> showNotification(
      String title, var type, String body, int value) async {
    DarwinNotificationDetails iosNotificationDetails =
    const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: const AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description'),
        iOS: iosNotificationDetails,
        macOS: iosNotificationDetails);

    print('type ${type.data}');
    print('notification catch');
    await flutterLocalNotificationsPlugin.show(
        value, title, body, platformChannelSpecifics,
        payload: jsonEncode(type.data));
  }

  void configureDidReceiveLocalNotificationSubject(context) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(receivedNotification.title),
          content: Text(receivedNotification.body),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                notificationClick("${receivedNotification.payload}");
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((message) async {
      print("Message ${message}");
      print("Message ${jsonDecode(message)}");
      await notificationClickLocal(jsonDecode(message));
    });
  }

  void requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

}