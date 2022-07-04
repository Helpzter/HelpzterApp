import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sitter_app/screens/parentBookings/parentsBookingsPage.dart';

import '../../globals.dart';
import '../../materialColor.dart';
import 'package:intl/intl.dart';


class EmergencyBookingPendingPage extends StatefulWidget {
  final Map job;

  EmergencyBookingPendingPage(this.job);

  @override
  State<EmergencyBookingPendingPage> createState() => _EmergencyBookingPendingPageState();
}

class _EmergencyBookingPendingPageState extends State<EmergencyBookingPendingPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future cancel() async {
    var token = await auth.currentUser.getIdToken();
    try {
      var response = await http.post(
        Uri.parse('http://sitter.$urlPath/bookings/cancelPending'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
        body: jsonEncode({'jobId': widget.job['_id']}),
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ParentsBookingPage()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Booking',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 15, left: 20, right: 20),
                child: Text(
                  'No sitters has accepted for your job From ${timeFormatter(widget.job['startDateTime'])} To ${timeFormatter(widget.job['endDateTime'] )} On ${ DateFormat('EEE, MMMM d').format(
          DateTime.parse(widget.job['startDateTime'])
                .toLocal())} yet',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17.5, color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await cancel();
                },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
