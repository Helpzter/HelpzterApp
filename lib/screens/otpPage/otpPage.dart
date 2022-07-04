import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../globals.dart';
import '../../materialColor.dart';
import '../../size_config.dart';
import '../../globals.dart';

class OtpPage extends StatefulWidget {
  String phoneNumber;
  OtpPage(this.phoneNumber);
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  var focusNodes = [];
  var keyFocusNodes = [];
  var controllers = [TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()];
  var response = true;

  void sendOtpCode(controllers) async {
    var otpCode = '${controllers[0].text}${controllers[1].text}${controllers[2].text}${controllers[3]
        .text}';
    var responseUndecoded = await http.post(Uri.parse('www.$urlPath/signUp/otp'), body: {'otpCode': otpCode});
    setState(() {
      response =  jsonDecode(responseUndecoded.body);
    });
  }



  @override
  void initState() {
    keyFocusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode()];
    focusNodes = [FocusNode(), FocusNode(), FocusNode(), FocusNode()];
    super.initState();
  }

  @override
  void dispose() {
    keyFocusNodes.forEach((node) => node.dispose());
    focusNodes.forEach((node) => node.dispose());
    controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }


  void changeField(String value, nodeIndex) {
    var finalValue;



    switch(value.length) {
      case 0:
        if(nodeIndex != 0) {
          focusNodes[nodeIndex - 1].requestFocus();
        }
        break;
      case 1:
        if(nodeIndex == 3) {
          focusNodes[3].unfocus();
        } else {
          focusNodes[nodeIndex + 1].requestFocus();
        }
        break;
      default:
        finalValue = value.substring(0, 1);
        focusNodes[nodeIndex + 1].requestFocus();
        changeField(value.substring(1), nodeIndex + 1);

      break;
    }

    setState(() {
      controllers[nodeIndex].text = finalValue ?? value;
    });
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,

        title: Text(
          "OTP Verification",
          style: TextStyle(
            color: materialColor(RosePink.primary),
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            size: 25,
            color: materialColor(RosePink.primary),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(
          left: 30,
          right: 30,
        ),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      SizedBox(height: SizeConfig.screenHeight * 0.05),
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'OTP Verification',
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(25),
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        'We sent your code to ${widget.phoneNumber}',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 60,
                            child: RawKeyboardListener(
                              focusNode: keyFocusNodes[0],
                              onKey: (key) {
                                if(controllers[0].text == '') {
                                  changeField(controllers[0].text, 0);
                                }
                              },
                              child: TextFormField(
                                controller: controllers[0],
                                focusNode: focusNodes[0],
                                autofocus: true,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 24),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  enabledBorder: !response ? UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ) : null,
                                  counterText: "",
                                ),
                                onChanged: (value) {
                                  changeField(value, 0);
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: RawKeyboardListener(
                              focusNode: keyFocusNodes[1],
                              onKey: (key) {
                                if(controllers[1].text == '') {
                                  changeField(controllers[1].text, 1);
                                }
                              },
                            child: TextFormField(
                              controller: controllers[1],
                              focusNode: focusNodes[1],
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: !response ? UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ) : null,
                                counterText: "",
                              ),
                              onChanged: (value) {
                                changeField(value, 1);
                                //number2 = value;
                              },
                            ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: RawKeyboardListener(
                              focusNode: keyFocusNodes[2],
                              onKey: (key) {
                                if(controllers[2].text == '') {
                                  changeField(controllers[2].text, 2);
                                }
                              },
                            child: TextFormField(
                              controller: controllers[2],
                              focusNode: focusNodes[2],
                              maxLength: 2,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: !response ? UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ) : null,
                                counterText: "",
                              ),
                              onChanged: (value) {
                                changeField(value, 2);
                              },
                            ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: RawKeyboardListener(
                              focusNode: keyFocusNodes[3],
                              onKey: (key) {
                                if(controllers[3].text == '') {
                                  changeField(controllers[3].text, 3);
                                }
                              },
                            child: TextFormField(
                              controller: controllers[3],
                              focusNode: focusNodes[3],
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                enabledBorder: !response ? UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ) : null,
                                counterText: "",
                              ),
                              onChanged: (value) {
                                changeField(value, 3);
                                if(controllers.every((controller) => controller.text != '')) {
                                    sendOtpCode(controllers);
                                }
                              },
                            ),
                          ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.15),
                      Container(
                        height: 52.0,
                        child: RaisedButton(
                            onPressed: controllers.every((controller) => controller.text != '' ) ? () async {
                                sendOtpCode(controllers);
                            } : null,
                            padding: EdgeInsets.all(0.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(75.0)),
                            child: controllers.every((controller) => controller.text != '')
                                ? Ink(
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
                            ) : Container(
                              alignment: Alignment.center,
                              child: Text(
                                'CONTINUE',
                                style: TextStyle(
                                    fontSize: 18.5, color: Colors.white),
                              ),
                            ),
                        ),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.1),
                      GestureDetector(
                        onTap: () {
                          // OTP code resend
                        },
                        child: Text(
                          "Resend OTP Code",
                          style:
                              TextStyle(decoration: TextDecoration.underline),
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
