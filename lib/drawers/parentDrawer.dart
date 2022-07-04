import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/globals.dart';
import 'package:sitter_app/screens/homePage/parentHome/parentHome.dart';
import 'package:sitter_app/screens/homePage/sitterHome/sitterHome.dart';
import 'package:sitter_app/screens/parentBookings/parentsBookingsPage.dart';
import 'package:sitter_app/screens/parentProfile/parentProfile.dart';
import 'package:sitter_app/screens/pendingApprovalPage/pendingApprovalPage.dart';
import 'package:sitter_app/screens/pickSitterPage/pickSitter.dart';
import 'package:sitter_app/screens/registrationData/dataInputTemplate.dart';
import 'package:sitter_app/screens/registrationData/sitterDataInput.dart';
import 'package:sitter_app/screens/welcomePage/welcome.dart';
import 'package:sitter_app/services/auth.dart';

import '../screens/contactInfoDialog.dart';

class ParentDrawer extends StatefulWidget {
  final int selected;

  ParentDrawer(this.selected);

  @override
  _ParentDrawerState createState() => _ParentDrawerState();
}

class _ParentDrawerState extends State<ParentDrawer> {
  final AuthService _auth = AuthService();
  int _selectedDestination;
  DateTime currentBackPressTime;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;

  @override
  void initState() {
    user = auth.currentUser;
    _selectedDestination = widget.selected;
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
                  child:  ValueListenableBuilder<Map>(
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
                    }),

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
                      MaterialPageRoute(builder: (_) => ParentHomePage()));
                }
              }),
          ListTile(
              leading: Icon(Icons.person_rounded),
              title: Text('Profile'),
              selected: _selectedDestination == 1,
              onTap: () {
                if (_selectedDestination != 1) {
                  selectDestination(1);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ParentProfile()));
                }
              }),
          ListTile(
              leading: Icon(Icons.calendar_today_rounded),
              title: Text('Bookings'),
              selected: _selectedDestination == 2,
              onTap: () {
                if (_selectedDestination != 2) {
                  selectDestination(2);
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ParentsBookingPage()));
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
                  title: Text('Switch To Sitter'),
                  selected: _selectedDestination == 3,
                  onTap: () async {
                    if (_selectedDestination != 3) {
                      selectDestination(3);
                      try{
                        await switchAccount(context,'sitter');
                        Navigator.pop(context);
                        if(globalUser['user']['verified']) {
                          getInboxCount(context: context, user: auth.currentUser);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => SitterHomePage()),
                                  (route) => false);
                        } else {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => PendingApprovalPage()),
                                  (route) => false);
                        }
                      } catch(e) {

                      }
                    }
                  })
              : ListTile(
                  leading: Icon(Icons.person_add_rounded),
                  title: Text('Become A Sitter'),
                  selected: _selectedDestination == 3,
                  onTap: () {
                    if (_selectedDestination != 3) {
                      selectDestination(3);
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => DataInputTemplate(SitterDataInput())));
                    }
                  }),
          ListTile(
            leading: Icon(Icons.contact_page_rounded),
            title: Text('Contact Info'),
            selected: _selectedDestination == 4,
            onTap: () async {
              selectDestination(4);
              Navigator.pop(context);
              showContactInfoDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Sign Out'),
            selected: _selectedDestination == 5,
            onTap: () async {
              selectDestination(5);
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
