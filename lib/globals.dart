import 'dart:async';
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

var urlPath = 'helpzter.com';
Map globalUser;
String fileName = "UserInfo.json";
bool versionValid = true;
final unreadCount = new ValueNotifier(0);
final userInfo = new ValueNotifier({});
final versionNumber = 1;
final globalServiceFee = 7.9;
final globalSquareCharge = 0.30;
const timeout = 7;

String yearsOfExperience(date) {
  var currentYear = DateTime.now().year;
  var startingYear = DateTime.parse(date).toLocal().year;
  var experience = currentYear - startingYear;
  return experience.toString();
}

String phoneNumberFormatter(String number) {
  var formattedNumber = '(';
  for (int i = 0; i < number.length; i++) {
    if (i == 3) {
      formattedNumber = formattedNumber + ') ';
    } else if (i == 6) {
      formattedNumber = formattedNumber + ' ';
    }
    formattedNumber = formattedNumber + number[i];
  }
  return formattedNumber;
}

String timeFormatter(String date) {
  return formatDate(DateTime.parse(date).toLocal(), [h, ':', nn, " ", am])
      .toString();
}

Future checkUser({context, User user, bool appOpened}) async {
  //TODO: Step 1 - Declare a file name that has .json extension and get the Directory
  var storageDir = await getApplicationDocumentsDirectory();

  //TODO: Step 2 - Check of the Json file exists so that we can decide whether to make an API call or not
  var savedFile = File(storageDir.path + "/" + fileName);
  if (await savedFile.exists()) {
    //TOD0: Reading from the json File
    var data = savedFile.readAsStringSync();
    var jsonData = jsonDecode(data);
    globalUser = jsonData;
    userInfo.value = globalUser['user'];
    if (appOpened &&
        globalUser['userRole'] != 'both' &&
        globalUser['userRole'] != 'none') {
      getUserInfoApi(context: context, user: user);
    }
    return jsonData;
  }
  //TODO: If the Json file does not exist, then make the API Call

  else {
    return await getUserApi(context, user);
  }
}

Future getUserApi(context, User user) async {
  try {
    var storageDir = await getApplicationDocumentsDirectory();
    var fcmToken = await FirebaseMessaging.instance.getToken();
    var response = await http.post(
      Uri.parse('http://www.$urlPath/signIn'),
      body: jsonEncode({'uid': user.uid, 'fcmToken': fcmToken}),
      headers: {
        'VersionNumber': jsonEncode(versionNumber),
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: timeout));
    var jsonResponse = await jsonDecode(response.body);
    if (response.statusCode == 200) {
      File file = new File(storageDir.path + "/" + fileName);
      if (!file.existsSync()) {
        //TODO: Save the json response in the file in storage
        await file.create(recursive: true);
      }
      file.writeAsString(response.body, flush: true, mode: FileMode.write);
      globalUser = jsonResponse;
      userInfo.value = globalUser['user'];
      return jsonResponse;
    } else if (response.statusCode == 500) {
      if (jsonResponse == 'need-update') {
        if (versionValid) {
          versionValid = false;
          if (context != null) {
            showUpdateDialog(
              context,

            );
          }
        }
        throw Exception(jsonResponse);
      }
    }
  } catch (e) {
    throw Exception(e);
  }
}

Future getUserInfoApi({context, User user}) async {
  var token = await user.getIdToken();
  try {
    var storageDir = await getApplicationDocumentsDirectory();
    var response = await http.get(
      Uri.http(
          'www.$urlPath', '/signIn/userInfo', {'userRole': globalUser['userRole']}),
      headers: {
        'VersionNumber': jsonEncode(versionNumber),
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: token,
      },
    );
    var jsonResponse = await jsonDecode(response.body);
    if (response.statusCode == 200) {
      globalUser['user'] = jsonResponse;
      File file = new File(storageDir.path + "/" + fileName);
      if (!file.existsSync()) {
        //TODO: Save the json response in the file in storage
        await file.create(recursive: true);
      }
      file.writeAsString(jsonEncode(globalUser),
          flush: true, mode: FileMode.write);
      userInfo.value = jsonResponse;
      return jsonResponse;
    } else if (response.statusCode == 500) {
      if (jsonResponse == 'need-update') {
        if (versionValid) {
          versionValid = false;
          if (context != null) {
            showUpdateDialog(
              context,

            );
          }
        }
        throw Exception(jsonResponse);
      }
    }
  } catch (e) {
    print(e);
  }
}

Future switchAccount(context, roleChange) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  var token = await auth.currentUser.getIdToken();
  var fcmToken = await FirebaseMessaging.instance.getToken();
  if (globalUser != null && globalUser['both']) {
    try {
      var response = await http.post(
        Uri.http('www.$urlPath', '/signIn/switchAccounts'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
        body: jsonEncode({'userRole': roleChange, 'fcmToken': fcmToken}),
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        userInfo.value = jsonResponse;
        globalUser['user'] = jsonResponse;
        globalUser['userRole'] = roleChange;
        var storageDir = await getApplicationDocumentsDirectory();
        File file = new File(storageDir.path + "/" + fileName);
        if (!file.existsSync()) {
          //TODO: Save the json response in the file in storage
          await file.create(recursive: true);
        }
        file.writeAsString(jsonEncode(globalUser),
            flush: true, mode: FileMode.write);
      } else if (response.statusCode == 500) {
        if (jsonResponse == 'need-update') {
          if (versionValid) {
            versionValid = false;
            showUpdateDialog(
              context,

            );
          }
          throw Exception(jsonResponse);
        }
      }
    } catch(error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again'),
        ),
      );
      print(error);
    }

  } else {
    if(globalUser != null) {
      if (globalUser['userRole'] != 'none') {
        globalUser['both'] = true;
      }
    } else {
      globalUser = {};
    }

    globalUser['userRole'] = roleChange;
    var storageDir = await getApplicationDocumentsDirectory();
    File file = new File(storageDir.path + "/" + fileName);
    if (!file.existsSync()) {
      //TODO: Save the json response in the file in storage
      await file.create(recursive: true);
    }
    file.writeAsString(jsonEncode(globalUser),
        flush: true, mode: FileMode.write);
  }
  return;
}

void getInboxCount({context, user}) async {
  var token = await user.getIdToken();
  try {
    var response = await http.get(
      Uri.parse('http://sitter.$urlPath/inbox/unreadCount'),
      headers: {
        'VersionNumber': jsonEncode(versionNumber),
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: token,
      },
    );
    var jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      unreadCount.value = jsonResponse;
    } else if (response.statusCode == 500) {
      if (jsonResponse == 'need-update') {
        if (versionValid) {
          versionValid = false;
          if (context) {
            showUpdateDialog(
              context,

            );
          }
        }
      }
    } else {
      print(response.body);
    }
  } catch (error) {
    print(error);
  }
}

showUpdateDialog(context) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String title = "App Update Available";
      String btnLabel = "Update Now";
      return Platform.isIOS
          ? WillPopScope(
              onWillPop: () async => false,
              child: new CupertinoAlertDialog(
                title: Text(title),
                content: Text("Please update the app in the Play Store to continue",),
              ),
            )
          : WillPopScope(
              onWillPop: () async => false,
              child: new AlertDialog(
                title: Text(
                  title,
                  style: TextStyle(fontSize: 22),
                ),
                content: Text("Please update the app in the Play Store to continue",),

              ),
            );
    },
  );
}
