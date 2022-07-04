import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sitter_app/screens/signIn/signIn.dart';
import 'package:sitter_app/services/auth.dart';

import '../../materialColor.dart';
import '../../size_config.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error;
  String email;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Text(
                    'FORGOT PASSWORD',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "Please enter your email and we will send \nyou a link to reset your password",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.2),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Your email is required';
                      } else if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: error,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(27)),
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(30)),
                  Container(
                    height: 52.0,
                    child: RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            Map response = await _auth.resetPasswordLink(email);
                            if(!response['success']) {
                              if(response['response'].code == 'user-not-found') {
                                setState(() {
                                  error = 'Could not find a user with that email';
                                });
                              }
                            } else {
                              setState(() {
                                error = null;
                              });
                              final snackBar = SnackBar(content: Text('Your password reset email has been sent'));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                          }
                        },
                        padding: EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(75.0)),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  materialColor(RosePink.primary),
                                  materialColor(RosePink.primary)[100]
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28.0)),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'CONTINUE',
                              style: TextStyle(
                                  fontSize: 18.5, color: Colors.white),
                            ),
                          ),
                        )),
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.1),
                  TextButton(
                    child: Text(
                      'Already have an account? Sign In',
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
