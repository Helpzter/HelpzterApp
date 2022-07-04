import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../globals.dart';
import '../../../materialColor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../homePage/sitterHome/sitterHome.dart';

class SitterInboxDetails extends StatefulWidget {
  final Map inboxDetails;
  final int index;
  final Function changeSeen;

  SitterInboxDetails(
      {Key key, @required this.inboxDetails, this.index, this.changeSeen})
      : super(key: key);

  @override
  _SitterInboxDetailsState createState() => _SitterInboxDetailsState();
}

class _SitterInboxDetailsState extends State<SitterInboxDetails> {
  Map inboxDetails;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;

  void joinList(context) async {
    var token = await user.getIdToken();
    try {
      var response =
          await http.post(Uri.parse('http://sitter.$urlPath/inbox/join'),
              headers: {
                'VersionNumber': jsonEncode(versionNumber),
                'Content-Type': 'application/json',
                HttpHeaders.authorizationHeader: token,
              },
              body: jsonEncode({
                'jobId': inboxDetails['job']['_id'],
                'joined': inboxDetails['job']['joined']
              })).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
          setState(() {
            inboxDetails['job']['joined'] = !inboxDetails['job']['joined'];
          });
      } else {
        if (jsonResponse == 'need-update') {
          if (versionValid) {
          versionValid = false;
          if (context != null) {
              showUpdateDialog(
                context,

              );
            }
          }
        } else {
          String snackBarText;
          switch (jsonResponse) {
            case 'canceled':
              {
                snackBarText = 'This job has been canceled';
              }
              break;
            case 'picked':
              {
                snackBarText = 'You have already been picked as sitter';
              }
              break;
            case 'added already':
              {
                snackBarText = 'You have already been added';
              }
              break;
            case 'booking-their-own-job':
              {
                snackBarText = 'You can\'t book your own job';
              }
              break;
            case 'contradicting-dates':
              {
                snackBarText = 'You have already been booked for a different job for this time';
              }
          }
          final snackBar = SnackBar(
            content: Text(snackBarText),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          print(response.body);
        }
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

  void acceptJob(context) async {
    var token = await user.getIdToken();
    try {
      var response =
      await http.post(Uri.parse('http://sitter.$urlPath/inbox/accept'),
          headers: {
            'VersionNumber': jsonEncode(versionNumber),
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: token,
          },
          body: jsonEncode({
            'jobId': inboxDetails['job']['_id'],
          })).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => SitterHomePage()),
                (route) => false);
      } else {
        if (jsonResponse == 'need-update') {
          if (versionValid) {
            versionValid = false;
            if (context != null) {
              showUpdateDialog(
                context,

              );
            }
          }
        } else {
          String snackBarText;
          switch (jsonResponse) {
            case 'canceled':
              {
                snackBarText = 'This job has been canceled';
              }
              break;
            case 'picked':
              {
                snackBarText = 'A sitter has already been booked';
              }
              break;
            case 'above-max-hourlyRate':
              {
                snackBarText = 'Your hourly rate is above the set max hourly rate';
              }
              break;
            case 'job-past':
              {
                snackBarText = 'This job time has past';
              }
              break;
            case 'booking-their-own-job':
              {
                snackBarText = 'You can\'t book your own job';
              }
              break;
            case 'contradicting-dates':
              {
                snackBarText = 'You have already been booked for a different job for this time';
              }

          }
          final snackBar = SnackBar(
            content: Text(snackBarText),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          print(response.body);
        }
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

  void setSeen(context, bool seenValue) async {
    var token = await user.getIdToken();
    try {
      var response = await http.post(Uri.parse('http://sitter.$urlPath/inbox'),
          headers: {
            'VersionNumber': jsonEncode(versionNumber),
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: token,
          },
          body:
              jsonEncode({'inboxId': inboxDetails['_id'], 'seen': seenValue})).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (widget.changeSeen != null) {
          widget.changeSeen(widget.index, seenValue);
        }
      } else if (response.statusCode == 500) {
        if (jsonResponse == 'need-update') {
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
      if(!seenValue)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again'),
        ),
      );
      print(error);
    }
  }

  @override
  void initState() {
    user = auth.currentUser;
    inboxDetails = widget.inboxDetails;
    if (!inboxDetails['seen']) {
      setSeen(context, true);
      if (unreadCount != null) {
        unreadCount.value--;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setSeen(context, false);
                if (unreadCount != null) {
                  unreadCount.value++;
                }
                Navigator.pop(context);
              },
              icon: Icon(Icons.mark_email_unread_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: CircleAvatar(
                    backgroundImage: inboxDetails['job']['parent']
                                ['photoUrl'] !=
                            null
                        ? NetworkImage(
                            inboxDetails['job']['parent']['photoUrl'])
                        : AssetImage('assets/images/profilePlaceholder.png'),
                    radius: 60,
                  ),
                ),
              ),
              Text(
                inboxDetails['job']['parent']['name'],
                style: TextStyle(fontSize: 25),
              ),
              Container(
                margin: EdgeInsets.only(top: 60, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      DateFormat('EEE, MMMM d').format(
                          DateTime.parse(inboxDetails['job']['startDateTime'])
                              .toLocal()),
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
                      "Time",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      '${timeFormatter(inboxDetails['job']['startDateTime'])} - ${timeFormatter(inboxDetails['job']['endDateTime'])}',
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      inboxDetails['job']['address'],
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
                      "Kids",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      inboxDetails['job']['parent']['kids'],
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 20,
                thickness: 2,
              ),
              if (inboxDetails['job']['responsibility'] != null)
                Container(
                  margin: EdgeInsets.only(top: 4, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Responsibilities",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 15),
                          child: Text(
                            inboxDetails['job']['responsibility'],
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (inboxDetails['job']['responsibility'] != null)
                Divider(
                  height: 20,
                  thickness: 2,
                ),
              Container(
                margin: EdgeInsets.only(top: 40, bottom: 5),
                height: 52.0,
                child: RaisedButton(
                  onPressed: () {
                    if(inboxDetails['job']['emergencyBooking']) {
                      acceptJob(context);
                    } else {
                      joinList(context);
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
                        inboxDetails['job']['joined'] ? 'UNJOIN' : inboxDetails['job']['emergencyBooking'] ? 'ACCEPT' : 'JOIN',
                        style: TextStyle(fontSize: 18.5, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
