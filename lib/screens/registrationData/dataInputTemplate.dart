import 'package:flutter/material.dart';

import '../../materialColor.dart';

class DataInputTemplate extends StatelessWidget {
  final Widget userDataInputPage;

  DataInputTemplate(this.userDataInputPage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registration',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
      ),
      body: userDataInputPage,
    );
  }
}
