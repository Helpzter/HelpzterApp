import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/screens/homePage/homePageWrapper.dart';
import 'package:sitter_app/services/storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../customRadioButtons.dart';
import '../../globals.dart';
import '../../materialColor.dart';

class SitterDataInput extends StatefulWidget {
  @override
  _SitterDataInputState createState() => _SitterDataInputState();
}

class _SitterDataInputState extends State<SitterDataInput> {
  ScrollController scrollController;
  var nameControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  var numberControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  Map formFields = {};
  var buttonEnabled = false;
  var errors = {};
  var checkedValue = false;
  File image;
  var _value = 'paypal';

  Future<void> _picChooserDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 0),
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
                if (image != null)
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

  void sendData(context) async {
    try {
      var response = await http.post(
        Uri.parse('http://sitter.$urlPath/signUp'),
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
        file.writeAsString(jsonEncode(globalUser),
            flush: true, mode: FileMode.write);
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
      } else if (response.statusCode == 500) {
        if (jsonResponse == 'need-update') {
          if (versionValid) {
          versionValid = false;
          if (context != null) {
              showUpdateDialog(
                context,

              );
            }
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
                          'SITTER REGISTRATION',
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
                            onPressed: () async {
                              _picChooserDialog();
                              // XFile xFileImage = await ImagePicker()
                              //     .pickImage(source: ImageSource.camera);
                              // setState(() {
                              //   image = File(xFileImage.path);
                              // });
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
                          } else if (value
                                  .replaceAll(RegExp('[^0-9]'), '')
                                  .length <
                              10) {
                            return 'Please enter a valid Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          formFields['phoneNumber'] =
                              value.replaceAll(RegExp('[^0-9]'), '');
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
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '###',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'How much years of experience you have is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          formFields['experience'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Years Of Experience',
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
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '\$#####',
                            filter: {"#": RegExp(r'[0-9.]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains(RegExp(r'[0-9]'))) {
                            return 'Hourly rate is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if(value.isNotEmpty) {
                            formFields['hourlyRate'] = value.substring(1,);
                          } else {
                            formFields['hourlyRate'] = value;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Hourly Rate',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Please submit 3 references (no relatives) ',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Divider(),
                    ),
                    Container(
                      child: Text(
                        '1.',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        controller: nameControllers[0],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Reference name is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        onChanged: (value) {},
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
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '(###) ### ####',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        controller: numberControllers[0],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Reference phone number is required';
                          } else if (value
                                  .replaceAll(RegExp('[^0-9]'), '')
                                  .length <
                              10) {
                            return 'Please enter a valid Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        '2.',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        controller: nameControllers[1],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Reference name is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        onChanged: (value) {},
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
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '(###) ### ####',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        controller: numberControllers[1],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Reference phone number is required';
                          } else if (value
                                  .replaceAll(RegExp('[^0-9]'), '')
                                  .length <
                              10) {
                            return 'Please enter a valid Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        '3.',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        controller: nameControllers[2],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Reference name is required';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        onChanged: (value) {},
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
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '(###) ### ####',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        controller: numberControllers[2],
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Reference phone number is required';
                          } else if (value
                                  .replaceAll(RegExp('[^0-9]'), '')
                                  .length <
                              10) {
                            return 'Please enter a valid Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Divider(),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (value) {
                          formFields['SpecialExperience'] = value;
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g. first aid',
                          labelText: '*Special Experience',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (value) {
                          formFields['description'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: '*Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => node.unfocus(),
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          formFields['referrer'] = value;
                        },
                        decoration: InputDecoration(
                          labelText: '*Who were you referred by',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        'Choose a payment method',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MyRadioListTile<int>(
                            value: 'PayPal',
                            groupValue: _value,
                            leading: SizedBox(
                              width: 81,
                              child: Image(
                                image: AssetImage('assets/images/PayPalLogo.png'),
                              ),
                            ),
                            onChanged: (value) => {
                              formFields['paymentMethod'] = value,
                              setState(() => _value = value)
                            },
                          ),
                          MyRadioListTile<int>(
                            value: 'CashApp',
                            groupValue: _value,
                            leading: SizedBox(
                              width: 81,
                              child: Text(
                                'CashApp',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            onChanged: (value) => {
                              formFields['paymentMethod'] = value,
                              setState(() => _value = value)
                            },
                          ),
                          MyRadioListTile<int>(
                            value: 'Zelle',
                            groupValue: _value,
                            leading: SizedBox(
                              width: 81,
                              child: Text(
                                'Zelle',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            onChanged: (value) => {
                              formFields['paymentMethod'] = value,
                              setState(() => _value = value)
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15, bottom: 10),
                      child: TextFormField(
                        inputFormatters: [
                          MaskTextInputFormatter(
                            mask: '(###) ### ####',
                            filter: {"#": RegExp(r'[0-9]')},
                            type: MaskAutoCompletionType.lazy,
                          )
                        ],
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () => node.nextFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'phone number associated with $_value is required';
                          } else if (value
                                  .replaceAll(RegExp('[^0-9]'), '')
                                  .length <
                              10) {
                            return 'Please enter a valid Phone number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          formFields['paymentInfo'] = value.replaceAll(RegExp('[^0-9]'), '');
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone Number associated with $_value',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(27)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 10),
                      child: CheckboxListTile(
                        title:
                            Text('I am legally authorized to work in the U.S.'),
                        value: checkedValue,
                        onChanged: (newValue) {
                          setState(() {
                            checkedValue = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                    ),
                    Container(
                      height: 52.0,
                      child: RaisedButton(
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              var names = [];
                              var numbers = [];
                              for (var i = 0; i < nameControllers.length; i++) {
                                names.add(nameControllers[i].text);
                                numbers.add(numberControllers[i]
                                    .text
                                    .replaceAll(RegExp('[^0-9]'), ''));
                              }
                              formFields['referenceNames'] = names;
                              formFields['referenceNumbers'] = numbers;
                              formFields['authorized'] = checkedValue;
                              var fcmToken =
                                  await FirebaseMessaging.instance.getToken();
                              formFields['fcmToken'] = fcmToken;
                              await switchAccount(context, 'sitter');
                              if (image != null) {
                                var photoUrl =
                                    await StorageService().uploadFile(image);
                                formFields['photoUrl'] = photoUrl;
                              }
                              sendData(context);
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

