import 'package:flutter/material.dart';
import 'package:sitter_app/screens/registrationData/sitterDataInput.dart';
import 'package:sitter_app/screens/welcomePage/welcome.dart';
import 'package:sitter_app/services/auth.dart';

import '../../materialColor.dart';
import 'parentDataInput.dart';

class DataInputPage extends StatefulWidget {
  @override
  _DataInputPageState createState() => _DataInputPageState();
}

class _DataInputPageState extends State<DataInputPage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.logout_rounded,
            ),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => WelcomePage()), (route) => false);
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'PARENT',
                  style: TextStyle(color: materialColor(RosePink.primary)),
                ),
              ),
              Tab(
                child: Text(
                  'SITTER',
                  style: TextStyle(color: materialColor(RosePink.primary)),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ParentDataInput(),
            SitterDataInput(),
          ],
        ),
      ),
    );
  }
}
