import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/materialColor.dart';
import 'package:sitter_app/screens/homePage/parentHome/parentHome.dart';
import 'package:sitter_app/screens/homePage/sitterHome/sitterHome.dart';
import 'package:sitter_app/screens/pendingApprovalPage/pendingApprovalPage.dart';
import 'package:sitter_app/screens/welcomePage/welcome.dart';
import 'package:sitter_app/services/auth.dart';

import '../../globals.dart';

class BothRedirectPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [materialColor(RosePink.primary), materialColor(RosePink.primary)[200]])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,leading: IconButton(
          icon: Icon(
            Icons.logout_rounded,
          ),
          color: Colors.white,
          onPressed: () async {
            await _auth.signOut();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => WelcomePage()), (route) => false);
          },
        ),),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_rounded,  color: materialColor(RosePink.primary), size: 170,),
                      ListTile(
                        contentPadding: EdgeInsets.only(),
                        title: Text('Continue as', textAlign: TextAlign.center, style: TextStyle(fontSize: 35, color: materialColor(RosePink.primary), fontFamily: 'Playball'),),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25, bottom: 7),
                        height: 52.0,
                        child: RaisedButton(
                          onPressed: () async {
                            await switchAccount(context,'sitter');
                            if(globalUser['user']['verified']) {
                              getInboxCount(context: context, user: auth.currentUser);
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => SitterHomePage()),
                                      (route) => false);
                            } else {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => PendingApprovalPage()),
                                      (route) => false);
                            }

                          },
                          padding: EdgeInsets.all(0.0),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(75.0)),
                          child: Ink(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    materialColor(RosePink.primary),
                                    materialColor(
                                        RosePink.primary)[100]
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius:
                                BorderRadius.circular(28.0)),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                'SITTER',
                                style: TextStyle(
                                    fontSize: 18.5,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(color: Colors.grey[50],),
                      Container(
                        margin: EdgeInsets.only(top: 7, bottom: 20),
                        height: 52.0,
                        child: RaisedButton(
                          onPressed: () async {
                            await switchAccount(context,'parent');
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => ParentHomePage()),
                                    (route) => false);
                          },
                          padding: EdgeInsets.all(0.0),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(75.0)),
                          child: Ink(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    materialColor(RosePink.primary),
                                    materialColor(
                                        RosePink.primary)[100]
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius:
                                BorderRadius.circular(28.0)),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                'PARENT',
                                style: TextStyle(
                                    fontSize: 18.5,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
