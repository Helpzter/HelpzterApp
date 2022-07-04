import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sitter_app/screens/pickSitterPage/pickSitter.dart';
import 'package:sitter_app/screens/sitterInbox/sitterInboxDetails/getSitterInboxDetails.dart';
import 'package:sitter_app/screens/sitterInbox/sitterInboxDetails/sitterInboxDetails.dart';
import 'package:http/http.dart' as http;

import '../globals.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
User user = auth.currentUser;


class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: IOSInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,)
    );

    _notificationsPlugin.initialize(initializationSettings,onSelectNotification: (messageData) async{
      var jsonData = jsonDecode(messageData);
      if(jsonData != null) {
        if(jsonData['type'] == 'newJob' && globalUser['userRole'] == 'sitter') {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  GetSitterInboxDetails(jsonData['job'])),);
        }
        if(jsonData['type'] == 'sitterCanceled' && globalUser['userRole'] == 'parent') {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  PickSitterPage(jsonData['job'])),);
        }
      }
    });
  }

  static void display(RemoteMessage message) async {

    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/1000;

      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "popup",
            "popup channel",
            importance: Importance.max,
            priority: Priority.high,
          )
      );


      await _notificationsPlugin.show(
        id,
        message.notification.title,
        message.notification.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}