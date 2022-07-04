import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/screens/homePage/homePageWrapper.dart';
import 'package:sitter_app/services/storage.dart';

import '../../globals.dart';
import '../../materialColor.dart';

class ParentDataInput extends StatefulWidget {
  @override
  _ParentDataInputState createState() => _ParentDataInputState();
}

class _ParentDataInputState extends State<ParentDataInput> {
  ScrollController scrollController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  Map formFields = {'schedule': 'Daily'};
  var radioValues = ['Daily', 'Occasionally', 'Rarely'];
  String _selected = 'Daily';
  var errors = {};
  File image;

  Future<void> _picChooserDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
          title: const Text('Profile Picture'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300], width: 1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 28,
                        splashRadius: 28,
                        onPressed: () async {
                          Navigator.of(context).pop();
                          XFile xFileImage = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          setState(() {
                            image = File(xFileImage.path);
                          });
                        },
                        icon: Icon(
                          Icons.camera_alt_rounded,
                          color: materialColor(RosePink.primary),
                        ),
                      ),
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300], width: 1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 28,
                        splashRadius: 28,
                        onPressed: () async {
                          Navigator.of(context).pop();
                          XFile xFileImage = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          setState(() {
                            image = File(xFileImage.path);
                          });
                        },
                        icon: Icon(
                          Icons.image_rounded,
                          color: materialColor(RosePink.primary),
                        ),
                      ),
                    ),
                    Text(
                      'Gallery',
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                ),
                if(image != null)
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300], width: 1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 28,
                          splashRadius: 28,
                          onPressed: () {
                            setState(() {
                              image = null;
                            });
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.delete_rounded,
                            color: materialColor(RosePink.primary),
                          ),
                        ),
                      ),
                      Text(
                        'Remove',
                        style: TextStyle(fontSize: 13),
                      )
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    user = auth.currentUser;
    formFields['uid'] = user.uid;
    print(formFields);
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose(); // dispose the controller
    super.dispose();
  }
  void scrollToTop() {
    //if (scrollController.hasClients) {
    scrollController.animateTo(0,
        duration: Duration(milliseconds: 400), curve: Curves.linear);
    //}
  }

  void sendData() async {
    try {
      var response = await http.post(
        Uri.parse('http://www.$urlPath/signUp'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(formFields),
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        globalUser['user'] = jsonResponse;
        var storageDir = await getApplicationDocumentsDirectory();
        File file = new File(storageDir.path + "/" + fileName);
        if (!file.existsSync()) {
          //TODO: Save the json response in the file in storage
          await file.create(recursive: true);
        }
        file.writeAsString(jsonEncode(globalUser), flush: true, mode: FileMode.write);
        userInfo.value = jsonResponse;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePageWrapper()),
                (route) => false);
      } else if (jsonResponse.containsKey('uid')) {
        final snackBar = SnackBar(
          content: Text(jsonResponse['uid']),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if(response.statusCode == 500) {
        if(jsonResponse == 'need-update') {
          if (versionValid) {
            versionValid = false;
            showUpdateDialog(
              context,

            );
          }
        }
        } else {
        print(response.body);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again'),
        ),
      );
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return ListView(
      controller: scrollController,
      children: [
        Container(
          margin: EdgeInsets.only(
            top: 10,
            bottom: 50,
            left: 30,
            right: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  margin: EdgeInsets.only(bottom: 20, top: 20),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'PARENT REGISTRATION',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        'Please fill in all the details below',
                        textAlign: TextAlign.center,
                      )
                    ],
                  )),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        CircleAvatar(
                            backgroundImage: image == null
                                ? AssetImage(
                                'assets/images/profilePlaceholder.png')
                                : Image.file(
                              image,
                            ).image),
                        Positioned(
                          bottom: 0,
                          right: -25,
                          child: RawMaterialButton(
                            onPressed: () {
                              _picChooserDialog();
                            },
                            elevation: 2.0,
                            fillColor: Color(0xFFF5F6F9),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: materialColor(RosePink.primary),
                            ),
                            padding: EdgeInsets.all(12.0),
                            shape: CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 15, bottom: 10),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Your name is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          formFields['name'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Your address is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.streetAddress,
                        onChanged: (value) {
                          formFields['address'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'The amount of kids you have is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          formFields['kids'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Number of kids',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '(###) ### ####',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Your phone number is required';
                          } else if (value.replaceAll(RegExp('[^0-9]'), '').length < 10) {
                            return 'Please enter a valid Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          formFields['phoneNumber'] = value.replaceAll(RegExp('[^0-9]'), '');
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Emergency Contact\'s name is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          formFields['emergencyName'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Emergency Contact\'s Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '(###) ### ####',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () => node.unfocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Emergency Contact\'s phone number is required';
                          } else if (value.replaceAll(RegExp('[^0-9]'), '').length < 10) {
                            return 'Please enter a valid Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          formFields['emergencyNumber'] =
                              value.replaceAll(RegExp('[^0-9]'), '');
                        },
                        decoration: InputDecoration(
                          labelText: 'Emergency Contact\'s Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 7, bottom: 10),
                            child: Text(
                              'How often do you use a babysitter',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Column(
                            children: radioValues.map<Widget>((radioValue) {
                              return ListTile(
                                title: Text(radioValue),
                                leading: Radio(
                                  value: radioValue,
                                  groupValue: _selected,
                                  onChanged: (value) {
                                    formFields['schedule'] = value;
                                    setState(() {
                                      _selected = value;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 52.0,
                      margin: EdgeInsets.only(top: 10),
                      child: RaisedButton(
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              var fcmToken = await FirebaseMessaging.instance.getToken();
                              formFields['fcmToken'] = fcmToken;
                              await switchAccount(context,'parent');
                              if (image != null) {
                                var photoUrl = await StorageService().uploadFile(image);
                                formFields['photoUrl'] = photoUrl;
                              }
                              sendData();
                            } else {
                              scrollToTop();
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
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
