import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitter_app/materialColor.dart';
import 'package:sitter_app/models/user.dart';
import 'package:sitter_app/screens/homePage/homePageWrapper.dart';
import 'package:sitter_app/screens/pickSitterPage/pickSitter.dart';
import 'package:sitter_app/screens/sitterInbox/sitterInboxDetails/getSitterInboxDetails.dart';
import 'package:sitter_app/screens/sitterInbox/sitterInboxDetails/sitterInboxDetails.dart';
import 'package:sitter_app/screens/welcomePage/welcome.dart';
import 'package:sitter_app/services/local_notification_service.dart';
import 'package:http/http.dart' as http;
import '../globals.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}


class _WrapperState extends State<Wrapper> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  void versionCheck() async {
    var response = await http.get(
      Uri.http('www.$urlPath', '/versionCheck',),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    var jsonResponse = await jsonDecode(response.body);
    if(jsonResponse != versionNumber && jsonResponse != versionNumber - 1) {
      showUpdateDialog(
        context,

      );
    }
  }

  void initState() {
    super.initState();
    if(versionValid) {
      versionCheck();
    } else {
      // fix
      showUpdateDialog(
        context,
      );
    }
    LocalNotificationService.initialize(context);
    // app terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        if(message.data['type'] == 'newJob' && globalUser['userRole'] == 'sitter') {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  GetSitterInboxDetails(message.data['job'])),);
        }
        if(message.data['type'] == 'sitterCanceled' && globalUser['userRole'] == 'parent') {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) =>
                  PickSitterPage(message.data['job'])),);
        }
      }
    });
    //Foreground
    FirebaseMessaging.onMessage.listen((message) {
      if(message.data['type'] == 'newJob' && globalUser['userRole'] == 'sitter') {
        getInboxCount(context: context, user: auth.currentUser);
      }
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });
    // when apps open but in the background and message gets clicked
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if(message.data['type'] == 'newJob' && globalUser['userRole'] == 'sitter') {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) =>
                GetSitterInboxDetails(message.data['job'])),);
      }
      if(message.data['type'] == 'sitterCanceled' && globalUser['userRole'] == 'parent') {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) =>
                PickSitterPage(message.data['job'])),);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<FirebaseUser>(context);

    if (user == null) {
      return WelcomePage();
    } else {
      return HomePageWrapper();
    }
  }
}
