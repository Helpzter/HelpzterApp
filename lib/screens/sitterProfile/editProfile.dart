import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/globals.dart';
import 'package:http/http.dart' as http;
import 'package:sitter_app/screens/parentProfile/parentProfile.dart';
import 'package:sitter_app/screens/sitterProfile/sitterProfile.dart';
import 'package:sitter_app/services/storage.dart';

import '../../customRadioButtons.dart';
import '../../materialColor.dart';

class EditSitterProfilePage extends StatefulWidget {
  @override
  _EditSitterProfilePageState createState() => _EditSitterProfilePageState();
}

class _EditSitterProfilePageState extends State<EditSitterProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map formFields;
  User user;
  File image;
  bool showPhoto = true;
  var _value = globalUser['user']['paymentMethod'];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ScrollController scrollController;

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
                if(formFields['photoUrl'] != null && showPhoto)
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
                              showPhoto = false;
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
                            Icons.undo_rounded,
                            color: materialColor(RosePink.primary),
                          ),
                        ),
                      ),
                      Text(
                        'Undo',
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

  void sendData() async {
    var token = await user.getIdToken();
    try {
      var response = await http.post(
        Uri.parse('http://sitter.$urlPath/profile/edit'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
        body: jsonEncode(formFields),
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        var storageDir = await getApplicationDocumentsDirectory();
        globalUser['user'] = jsonResponse;
        File file = new File(storageDir.path + "/" + fileName);
        if (!file.existsSync()) {
          //TODO: Save the json response in the file in storage
          await file.create(recursive: true);
        }
        file.writeAsString(jsonEncode(globalUser), flush: true, mode: FileMode.write);
        userInfo.value = jsonResponse;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SitterProfile()),
            (route) => route.isFirst);
      } else if (response.statusCode == 500) {
        if(jsonResponse == 'need-update') {
          if(versionValid) {
            versionValid = false;
            showUpdateDialog(
              context,

            );
          }
        } else {
          final snackBar = SnackBar(
            content: Text(jsonResponse),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  void scrollToTop() {
    //if (scrollController.hasClients) {
    scrollController.animateTo(0,
        duration: Duration(milliseconds: 400), curve: Curves.linear);
    //}
  }

  @override
  void initState() {
    scrollController = ScrollController();
    user = auth.currentUser;
    formFields = {...globalUser['user']};

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose(); // dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: materialColor(RosePink.primary)),
            ),
            style: ButtonStyle(
              overlayColor:
                  MaterialStateColor.resolveWith((states) => Colors.grey[300]),
            ),
            onPressed: () async {
              if (formKey.currentState.validate()) {
                if (image != null) {
                  var photoUrl = await StorageService().uploadFile(image);
                  formFields['photoUrl'] = photoUrl;
                  globalUser['user']['photoUrl'] = photoUrl;
                  var storageDir = await getApplicationDocumentsDirectory();
                  File file = new File(storageDir.path + "/" + fileName);
                  if (!file.existsSync()) {
                    //TODO: Save the json response in the file in storage
                    await file.create(recursive: true);
                  }
                  file.writeAsString(jsonEncode(globalUser), flush: true, mode: FileMode.write);
                  userInfo.value = globalUser['user'];
                }
                if(!showPhoto) {
                  await StorageService().deleteUserProfileImage(user.uid);
                  formFields['photoUrl'] = null;
                  globalUser['user']['photoUrl'] = null;
                  var storageDir = await getApplicationDocumentsDirectory();
                  File file = new File(storageDir.path + "/" + fileName);
                  if (!file.existsSync()) {
                    //TODO: Save the json response in the file in storage
                    await file.create(recursive: true);
                  }
                  file.writeAsString(jsonEncode(globalUser), flush: true, mode: FileMode.write);
                  userInfo.value = globalUser['user'];
                }
                sendData();
              } else {
                scrollToTop();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ValueListenableBuilder(
              valueListenable: userInfo,
              builder: (context, user, snapshot) {
                return Column(
                  children: [
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
                                backgroundImage: image != null
                                    ? Image.file(
                                        image,
                                      ).image
                                    : user['photoUrl'] != null && showPhoto
                                        ? NetworkImage(user['photoUrl'])
                                        : AssetImage(
                                            'assets/images/profilePlaceholder.png'),
                              ),
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
                            margin: EdgeInsets.only(top: 10, bottom: 10),
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
                              initialValue: user['name'],
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
                              initialValue: user['address'],
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
                                } else if (value.replaceAll(RegExp('[^0-9]'), '').length < 10) {
                                  return 'Please enter a valid Phone number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                formFields['phoneNumber'] =
                                    value.replaceAll(RegExp('[^0-9]'), '');
                              },
                              initialValue:
                                  phoneNumberFormatter(user['phoneNumber']),
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
                              initialValue: '\$${user['hourlyRate']}',
                              decoration: InputDecoration(
                                labelText: 'Hourly Rate',
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
                                formFields['SpecialExperience'] = value;
                              },
                              initialValue: user['SpecialExperience'],
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
                              initialValue: user['description'],
                              decoration: InputDecoration(
                                labelText: '*Description',
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
                              initialValue: user['paymentInfo'],
                              decoration: InputDecoration(
                                labelText: 'Phone Number associated with $_value',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(27)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}