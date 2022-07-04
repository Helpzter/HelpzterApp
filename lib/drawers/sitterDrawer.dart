import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/materialColor.dart';
import 'package:sitter_app/screens/balancePage/balancePage.dart';
import 'package:sitter_app/screens/contactInfoDialog.dart';
import 'package:sitter_app/screens/homePage/parentHome/parentHome.dart';
import 'package:sitter_app/screens/homePage/sitterHome/sitterHome.dart';
import 'package:sitter_app/screens/parentProfile/parentProfile.dart';
import 'package:sitter_app/screens/registrationData/dataInputTemplate.dart';
import 'package:sitter_app/screens/registrationData/parentDataInput.dart';
import 'package:sitter_app/screens/registrationData/sitterDataInput.dart';
import 'package:sitter_app/screens/serverUnreachableError/serverUnreachablePage.dart';
import 'package:sitter_app/screens/sitterInbox/sitterInboxPage.dart';
import 'package:sitter_app/screens/sitterProfile/sitterProfile.dart';
import 'package:sitter_app/screens/welcomePage/welcome.dart';
import 'package:sitter_app/services/auth.dart';

import '../globals.dart';
import 'package:http/http.dart' as http;

class SitterDrawer extends StatefulWidget {
  final int selected;

  SitterDrawer(this.selected);

  @override
  _SitterDrawerState createState() => _SitterDrawerState();
}

class _SitterDrawerState extends State<SitterDrawer> {
  final AuthService _auth = AuthService();
  int _selectedDestination;
  DateTime currentBackPressTime;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;

  Future getInboxCount() async {
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
        return jsonResponse;
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
      } else {
        print(response.body);
      }
    } catch (error) {
        print(error);
    }
  }

  @override
  void initState() {
    _selectedDestination = widget.selected;
    user = auth.currentUser;
    super.initState();
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  child: ValueListenableBuilder<Map>(
                    valueListenable: userInfo,
                    builder: (context, value, child) {
                      return CircleAvatar(
                        backgroundImage: value['photoUrl'] != null
                            ? NetworkImage(value['photoUrl'])
                            : AssetImage(
                                'assets/images/profilePlaceholder.png'),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder<Map>(
                  valueListenable: userInfo,
                  builder: (context, value, child) {
                    return Text(
                      value['name'],
                      style: textTheme.headline6,
                    );
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    user.email,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
              leading: Icon(Icons.home_rounded),
              title: Text('Home'),
              selected: _selectedDestination == 0,
              onTap: () {
                if (_selectedDestination != 0) {
                  selectDestination(0);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SitterHomePage()));
                }
              }),
          ListTile(
              leading: Icon(Icons.email_rounded),
              trailing: ValueListenableBuilder<int>(
                  valueListenable: unreadCount,
                  builder: (context, value, child) {
                    if (value != 0) {
                      return Badge(
                        toAnimate: false,
                        shape: BadgeShape.square,
                        badgeColor: materialColor(RosePink.primary),
                        borderRadius: BorderRadius.circular(18),
                        padding:
                            EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        badgeContent: Text(' $value New',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      );
                    } else {
                      return SizedBox();
                    }
                  }),
              title: Text('Job Openings'),
              selected: _selectedDestination == 1,
              onTap: () {
                if (_selectedDestination != 1) {
                  selectDestination(1);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SitterInboxPage()));
                }
              }),
          ListTile(
              leading: Icon(Icons.account_balance_rounded),
              title: Text('Balance'),
              selected: _selectedDestination == 2,
              onTap: () {
                if (_selectedDestination != 2) {
                  selectDestination(2);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BalancePage()));
                }
              }),
          ListTile(
              leading: Icon(Icons.person_rounded),
              title: Text('Profile'),
              selected: _selectedDestination == 3,
              onTap: () {
                if (_selectedDestination != 3) {
                  selectDestination(3);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SitterProfile()));
                }
              }),
          Divider(
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Account',
            ),
          ),
          globalUser != null && globalUser['both']
              ? ListTile(
                  leading: Icon(Icons.change_circle_outlined),
                  title: Text('Switch To Parent'),
                  selected: _selectedDestination == 4,
                  onTap: () async {
                    if (_selectedDestination != 4) {
                      selectDestination(4);
                      await switchAccount(context, 'parent');
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => ParentHomePage()),
                              (route) => false);
                    }
                  })
              : ListTile(
                  leading: Icon(Icons.person_add_rounded),
                  title: Text('Become A Parent'),
                  selected: _selectedDestination == 4,
                  onTap: () {
                    if (_selectedDestination != 4) {
                      selectDestination(4);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  DataInputTemplate(ParentDataInput())));
                    }
                  }),
          ListTile(
            leading: Icon(Icons.contact_page_rounded),
            title: Text('Contact Info'),
            selected: _selectedDestination == 5,
            onTap: () async {
              selectDestination(5);
              Navigator.pop(context);
              showContactInfoDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Sign Out'),
            selected: _selectedDestination == 6,
            onTap: () async {
              selectDestination(6);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => WelcomePage()),
                      (route) => false);
              await _auth.signOut();
            },
          ),
        ],
      ),
    );
  }
}
