import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sitter_app/loadingPage.dart';
import 'package:sitter_app/screens/homePage/parentHome/parentHome.dart';
import 'package:sitter_app/screens/homePage/bothRedirect.dart';
import 'package:sitter_app/screens/homePage/sitterHome/sitterHome.dart';
import 'package:sitter_app/screens/pendingApprovalPage/pendingApprovalPage.dart';
import 'package:sitter_app/screens/registrationData/dataInputPage.dart';
import 'package:sitter_app/screens/welcomePage/welcome.dart';

import '../../globals.dart';

import '../serverUnreachableError/serverUnreachablePage.dart';


class HomePageWrapper extends StatefulWidget {
  @override
  _HomePageWrapperState createState() => _HomePageWrapperState();
}

class _HomePageWrapperState extends State<HomePageWrapper> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;


  Widget homePage(userInfo) {
    String userRole = userInfo['userRole'];
    switch (userRole) {
      case 'both':
        {
          return BothRedirectPage();
        }
        break;
      case 'sitter':
        {
          if(userInfo['user'] != null && userInfo['user']['verified']) {
            getInboxCount(context: context, user: user);
            return SitterHomePage();
          }

          return PendingApprovalPage();
        }
        break;
      case 'parent':
        {
          return ParentHomePage();
        }
        break;
      case 'none':
        {
          return DataInputPage();
        }
      default:
        {
          return WelcomePage();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    user = auth.currentUser;
    return globalUser != null
        ? homePage(globalUser)
        : FutureBuilder(
            future: checkUser(user: user, appOpened: false),
            builder: (context, snapshot) {
              if(snapshot.hasError) {
                 return ServerUnreachableErrorPage(returnToWrapper: true);
              } else if (!snapshot.hasData) {
                // Future hasn't finished yet, return a placeholder
                return LoadingPage();
              }
              return homePage(snapshot.data);
            },
          );
  }
}
