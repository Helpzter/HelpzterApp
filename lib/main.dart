import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sitter_app/models/user.dart';
import 'package:sitter_app/screens/wrapper.dart';
import 'package:sitter_app/services/auth.dart';
import 'package:sitter_app/services/local_notification_service.dart';
import 'globals.dart';
import 'materialColor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;


Future<void> backgroundHandler(RemoteMessage message) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  if(message.data['type'] == 'newJob') {
    getInboxCount(user: auth.currentUser);
    }
  }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user = auth.currentUser;
  if(user != null) {
    await checkUser(user: user, appOpened: true);
  }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Sitter App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          fontFamily: 'San Fransisco',
          primarySwatch: materialColor(RosePink.primary),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: materialColor(RosePink.primary)),
            titleTextStyle: TextStyle(color: materialColor(RosePink.primary), fontSize: 18),
            centerTitle: true,
            color: Colors.grey[50],
          ),

        ),
        home: Wrapper(),
      ),
    );
  }
}
