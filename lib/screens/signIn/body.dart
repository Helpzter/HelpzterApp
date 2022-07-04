import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sitter_app/screens/ForgotPasswordPage/forgotPassword.dart';
import 'package:sitter_app/screens/homePage/homePageWrapper.dart';
import 'package:sitter_app/screens/registrationData/dataInputPage.dart';
import 'package:sitter_app/screens/signUp/signUp.dart';
import 'package:sitter_app/services/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../materialColor.dart';
import '../../pdfViewer.dart';
import '../../size_config.dart';

class SignInBody extends StatefulWidget {
  @override
  _SignInBodyState createState() => _SignInBodyState();
}

class _SignInBodyState extends State<SignInBody> {
  var formFields = {};
  var errors = {};
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final node = FocusScope.of(context);
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(
              top: 10,
              bottom: 30,
              left: 30,
              right: 30,
            ),
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.03),
                Container(
                  margin: EdgeInsets.only(bottom: 55, top: 20),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        fontSize: 65,
                        fontWeight: FontWeight.w900,
                        color: materialColor(RosePink.primary),
                        fontFamily: 'Playball'),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.03),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => node.nextFocus(),
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
                            formFields['email'] = value;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: errors['email'],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(27)),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          onEditingComplete: () => node.unfocus(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Your password is required';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.visiblePassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          obscureText: true,
                          onChanged: (value) {
                            formFields['password'] = value;
                          },
                          decoration: InputDecoration(
                            errorText: errors['password'],
                            labelText: 'Password',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(27)),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15, bottom: 10),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: materialColor(RosePink.primary)),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 52.0,
                        child: RaisedButton(
                            onPressed: () async {
                              if (formKey.currentState.validate()) {
                                errors = {};
                                dynamic result =
                                    await _auth.signInWithEmailAndPassword(
                                        formFields['email'],
                                        formFields['password']);
                                if (result['success']) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomePageWrapper()),
                                      (route) => false);
                                } else {
                                  if (result['response'].code ==
                                      'user-not-found') {
                                    setState(() {
                                      errors['email'] =
                                          'No user found for that email.';
                                    });
                                  } else if (result['response'].code ==
                                      'wrong-password') {
                                    setState(() {
                                      errors['password'] =
                                          'Wrong password provided for that user.';
                                    });
                                  } else {
                                    final snackBar = SnackBar(
                                      content: Text(result['response'].message),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    print(result['response'].message);
                                  }
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
                                  'SIGN IN',
                                  style: TextStyle(
                                      fontSize: 18.5, color: Colors.white),
                                ),
                              ),
                            )),
                      ),
                      TextButton(
                        child: Text(
                          'Don\'t have an account yet? Sign Up',
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.06),
                if(!Platform.isIOS)
                ElevatedButton.icon(
                    onPressed: () async {
                      dynamic result = await _auth.signInWithGoogle();
                      if (result != null) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => HomePageWrapper()),
                                (route) => false);
                      }
                    },
                    icon: SvgPicture.asset("assets/icons/google-icon.svg"),
                    label: Text('Sign In', style: TextStyle(color: Colors.grey, fontFamily: 'Roboto'),),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white), overlayColor:  MaterialStateProperty.all(Colors.grey[100])),
                ),
                SizedBox(height: getProportionateScreenHeight(25)),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.caption,
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              'By continuing your confirming that you agree \nwith our '),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PDFScreen(
                                          asset:
                                              'assets/pdfs/Final Terms And Conditions.pdf',
                                          filename:
                                              'Final Terms And Conditions.pdf',
                                        )),
                              ),
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
