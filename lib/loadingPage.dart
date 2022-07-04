import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'materialColor.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: SpinKitSpinningLines(
            color: RosePink.primary,
            size: 75,
          ),
        ),
      ),
    );
  }
}
