import 'package:flutter/material.dart';
import 'package:sitter_app/screens/signUp/signUp.dart';
import 'package:sitter_app/screens/signIn/body.dart';
import '../../materialColor.dart';
import '../../size_config.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var formFields = {};

  var errors = {};

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final node = FocusScope.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SignInBody(),
    );
  }
}
