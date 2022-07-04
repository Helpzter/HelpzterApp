import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../globals.dart';
import '../../../materialColor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../homePage/sitterHome/sitterHome.dart';


class SitterBookedDetails extends StatefulWidget {
  final Map job;
  final bool cancelable;

  SitterBookedDetails({Key key, @required this.job, @required this.cancelable}) : super(key: key);

  @override
  _SitterBookedDetailsState createState() => _SitterBookedDetailsState();
}

class _SitterBookedDetailsState extends State<SitterBookedDetails> {
  Map job;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;


  @override
  void initState() {
    user = auth.currentUser;
    job = widget.job;
    super.initState();
  }

  Future cancel() async {
    var token = await user.getIdToken();
    try {
      var response = await http.post(
        Uri.parse('http://sitter.$urlPath/jobs/cancel'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
        body: jsonEncode({
          "jobId": job['_id']
        })
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => SitterHomePage()),
                (route) => false);
      } else {
        if (jsonResponse == 'need-update') {
          if (versionValid) {
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
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child:CircleAvatar(
                    backgroundImage: job['parent']['photoUrl'] !=
                        null
                        ? NetworkImage(job['parent']['photoUrl'])
                        : AssetImage('assets/images/profilePlaceholder.png'),
                    radius: 60,
                  ),
                ),
              ),
              Text(
                job['parent']['name'],
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
                          DateTime.parse(job['startDateTime'])
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
                      '${timeFormatter(job['startDateTime'])} - ${timeFormatter(job['endDateTime'])}',
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
                      job['address'],
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
                      phoneNumberFormatter(job['parent']['phoneNumber']),
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      job['parent']['kids'],
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 20,
                thickness: 2,
              ),
              if(job['responsibility'] != null)
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
                          job['responsibility'],
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.left,

                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if(job['responsibility'] != null)
                Divider(
                height: 20,
                thickness: 2,
              ),
              if(widget.cancelable)
                Container(
                margin: EdgeInsets.only(top: 40, bottom: 5),
                height: 52.0,
                child: RaisedButton(
                  onPressed: () async {
                    await cancel();
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
                        'Cancel',
                        style: TextStyle(
                            fontSize: 18.5, color: Colors.white),
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



