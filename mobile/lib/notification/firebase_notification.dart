import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajuda/notification/push_notification_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../data/local/shared_pref_helper.dart';

class FirebaseNotifications extends ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String newUUID() => Uuid().v4();

  void firebaseInitialization() {
    _firebaseMessaging.getToken().then((token) {
      setToken(token);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      notificationClick(message);
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('OnMessage ${message.data}');
      notificationDialogManage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp');
      notificationClick(message);
    });
  }

  Future setToken(token) async {
    print(token);
    print('token');
    if (token == null) {
    } else {
      SharedPrefHelper.fcmToken = token.toString();
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('fcm_token', token.toString());

    }
  }

  Future<void> notificationDialogManage(RemoteMessage message) async {
    print('message get or not yet');
    var title = message.notification!.title;
    var body = message.notification!.body;
    print('message ${message}');
    print('message ${message.data['action_type']}');
    // String type = "${message.data["type"]},${message.data["reference_id"]}";
    if (Platform.isAndroid) {
      if (message.data['action_type'] == 'message') {
        LocalNotification().showNotification(title!, message, body!, 0);
      } else if (message.data['action_type'] == 'comment') {
        LocalNotification().showNotification(title!, message, body!, 0);
      } else if (message.data['action_type'] == 'unReveal') {
        LocalNotification().showNotification(title!, message, body!, 0);
      } else if (message.data['action_type'] == 'normal') {
        LocalNotification().showNotification(title!, message, body!, 0);
      } else if (message.data['action_type'] == 'Reveal') {
      } else if (message.data['action_type'] == 'block') {
      } else if (message.data['action_type'] == 'callReceiver') {
        var _currentUuid = Uuid().v4();
        var jason = jsonDecode(message.data['callerDetails']);
      } else if (message.data['action_type'] == 'callDecline') {
      } else {
        LocalNotification().showNotification(title!, message, body!, 0);
      }
    }

    if (Platform.isIOS) {
      print('notification get');
      // LocalNotification().showNotification(title!, message, body!, 0);

      if (message.data['action_type'] == 'callReceiver') {
      } else if (message.data['action_type'] == 'Reveal') {
      } else {}
    }
  }
}

Future<void> notificationClickIos(var payload) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  switch (payload.data['action_type']) {
    case "friend":
      break;
    case "message":
      break;
    case "comment":
      break;
    case "Reveal":
      break;
    case "normal":
      break;
    default:
      break;
  }
}

Future<void> notificationClick(var payload) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  print('screen');
  if (payload != null) {
    print(pref.getString('screen'));
    switch (payload!.data['action_type']) {
      case "friend":
        break;
      case "message":
        break;
      case "comment":
        break;
      case "Reveal":
        break;
      case "normal":
        break;
      default:
        break;
    }
  }
}

Future<void> notificationClickLocal(var payload) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  // String? _refrenceId;
  print('payload');
  print(payload);
  switch (payload['action_type']) {
    case "friend":
      break;
    case "message":
      break;
    case "comment":
      break;
    case "Reveal":
      break;
    case "normal":
      break;
    default:
      break;
  }
}