import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sitter_app/globals.dart';
import 'package:sitter_app/materialColor.dart';
import 'package:sitter_app/screens/homePage/sitterHome/sitterHome.dart';
import 'package:sitter_app/screens/welcomePage/welcome.dart';
import 'package:sitter_app/services/auth.dart';

class PendingApprovalPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.logout_rounded,
          ),
          onPressed: () async {
            await _auth.signOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => WelcomePage()),
                (route) => false);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          var user = await getUserInfoApi(context: context, user: auth.currentUser);
          if (user != null && user['verified']) {
            Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (_) => SitterHomePage()),
              (route) => false);
          }
        },
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 35, left: 35, right: 35, top: 15),
                    child: Column(
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: RosePink.primary,
                          size: 225,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            'Thank you so much for applying \n Your application is pending review. \nWe will contact you once a decision has been made.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.grey),
                          ),
                        ),
                        Text(
                          'Swipe down to reload',
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ListView(),
          ],
        ),
      ),
    );
  }
}
