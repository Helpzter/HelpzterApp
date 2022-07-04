import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/services/auth.dart';

import '../../globals.dart';
import '../../loadingPage.dart';
import '../../materialColor.dart';
import 'package:http/http.dart' as http;

import '../serverUnreachableError/serverUnreachablePage.dart';
import 'editProfile.dart';

class SitterProfile extends StatefulWidget {
  @override
  _SitterProfileState createState() => _SitterProfileState();
}

class _SitterProfileState extends State<SitterProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  Map userData;
  String currentPassword;
  String newPassword;
  var value;
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
  }

  Future getSitterInfo() async {
    var token = await user.getIdToken();
    try {
      var storageDir = await getApplicationDocumentsDirectory();
      var response = await http.get(
        Uri.http('sitter.$urlPath', '/profile'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = await jsonDecode(response.body);
      if (response.statusCode == 200) {
        globalUser['user'] = jsonResponse;
        File file = new File(storageDir.path + "/" + fileName);
        if (!file.existsSync()) {
          //TODO: Save the json response in the file in storage
          await file.create(recursive: true);
        }
        file.writeAsString(jsonEncode(globalUser),
            flush: true, mode: FileMode.write);
        userInfo.value = jsonResponse;
        return jsonResponse;
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
          throw Exception(jsonResponse);
        }
      }
    } on TimeoutException catch (e) {
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServerUnreachableErrorPage(),)
      );
      setState(() {});
    } on SocketException catch (_) {
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServerUnreachableErrorPage(),)
      );
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  Future<void> _passwordDialog() async {
    final node = FocusScope.of(context);
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: TextFormField(
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () => node.nextFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Your current password is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.visiblePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      onChanged: (value) {
                        currentPassword = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(27)),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 10,
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => node.unfocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Your new password is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.visiblePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      onChanged: (value) {
                        newPassword = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(27)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'CANCEL'),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                var snackBarMessage;
                if (formKey.currentState.validate()) {
                  var result =
                      await _auth.changePassword(currentPassword, newPassword);
                  if (result['success']) {
                    snackBarMessage = 'Password changed successfully';
                  } else {
                    snackBarMessage = result['response'].message;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(snackBarMessage),
                    ),
                  );
                  Navigator.pop(context, 'OK');
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => EditSitterProfilePage(),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: getSitterInfo(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LoadingPage();
            } else {
              value = snapshot.data;
              return RefreshIndicator(
                onRefresh: () async {
                  var sitterInfo = await getSitterInfo();
                  setState(() {
                    value = sitterInfo;
                  });
                },
                child: ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 20),
                        child: CircleAvatar(
                          backgroundImage: value['photoUrl'] != null
                              ? NetworkImage(value['photoUrl'])
                              : AssetImage(
                                  'assets/images/profilePlaceholder.png'),
                          radius: 60,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        value['name'],
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Email",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Address",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            value['address'],
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Phone Number",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            phoneNumberFormatter(value['phoneNumber']),
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Years Of Experience",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            yearsOfExperience(value['experience']),
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hourly Rate",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            '\$${value['hourlyRate']}',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Payment Method",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            value['paymentMethod'],
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Payment Info",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            phoneNumberFormatter(value['paymentInfo']),
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rating",
                            style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          RatingBar(
                            initialRating: value['rating'] != null
                                ? value['rating'].toDouble()
                                : 0,
                            unratedColor: Colors.amber[100],
                            ignoreGestures: true,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            glow: false,
                            allowHalfRating: true,
                            itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                            itemSize: 27,
                            ratingWidget: RatingWidget(
                              full: Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              half: Icon(
                                Icons.star_half,
                                color: Colors.amber,
                              ),
                              empty: Icon(
                                Icons.star_outline,
                                color: Colors.amber,
                              ),
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 20,
                      thickness: 2,
                    ),
                    if (user.providerData
                        .where((provider) => provider.providerId == 'password')
                        .isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 4, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Change Password",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _passwordDialog();
                              },
                              color: materialColor(RosePink.primary),
                              splashRadius: 25,
                            )
                          ],
                        ),
                      ),
                    if (user.providerData
                        .where((provider) => provider.providerId == 'password')
                        .isNotEmpty)
                      Divider(
                        height: 20,
                        thickness: 2,
                      ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
