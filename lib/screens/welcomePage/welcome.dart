import 'package:flutter/material.dart';
import 'package:sitter_app/screens/signUp/signUp.dart';
import 'package:sitter_app/screens/signIn/signIn.dart';

import '../../materialColor.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.center,
            end: Alignment(
              0.0,
              0.9,
            ),
            colors: [Colors.black, Colors.transparent],
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
        },
        blendMode: BlendMode.dstIn,
        child: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/images/babyPic.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 100),
              child: Center(
                child: Text(
                  'HELPZTER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.w900,
                      color: materialColor(RosePink.primary),
                      fontFamily: 'Playball',
                      shadows: [
                        Shadow(
                            // bottomLeft
                            offset: Offset(-1.5, -1.5),
                            color: Colors.white),
                        Shadow(
                            // bottomRight
                            offset: Offset(1.5, -1.5),
                            color: Colors.white),
                        Shadow(
                            // topRight
                            offset: Offset(1.5, 1.5),
                            color: Colors.white),
                        Shadow(
                            // topLeft
                            offset: Offset(-1.5, 1.5),
                            color: Colors.white),
                      ]),
                ),
              ),
            ),
            Spacer(),
            Column(
              children: [
                Container(
                  height: 52.0,
                  margin:
                      EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 10),
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
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
                        constraints:
                            BoxConstraints(maxWidth: 280.0, minHeight: 52.0),
                        alignment: Alignment.center,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(fontSize: 18.5, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignInPage()));
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10, top: 5),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: materialColor(RosePink.primary)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    ]));
  }
}
