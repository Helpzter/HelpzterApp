import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sitter_app/screens/parentBookings/parentsBookingsPage.dart';

import '../../globals.dart';
import '../../materialColor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BookedDetails extends StatefulWidget {
  final Map jobDetails;
  final bool completed;

  BookedDetails(this.jobDetails, this.completed);

  @override
  _BookedDetailsState createState() => _BookedDetailsState();
}

class _BookedDetailsState extends State<BookedDetails> {
  Map jobDetails;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  double jobRating = 3;

  Future cancel() async {
    var token = await user.getIdToken();
    try {
      var response =
          await http.post(Uri.parse('http://www.$urlPath/findSitters/cancel'),
              headers: {
                'VersionNumber': jsonEncode(versionNumber),
                'Content-Type': 'application/json',
                HttpHeaders.authorizationHeader: token,
              },
              body: jsonEncode({
                "jobId": jobDetails['_id'],
              })).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ParentsBookingPage()));
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

  Future rateJob() async {
    var token = await user.getIdToken();
    try {
      var response = await http.post(Uri.parse('http://www.$urlPath/bookings/rate'),
          headers: {
            'VersionNumber': jsonEncode(versionNumber),
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: token,
          },
          body: jsonEncode({'jobId': jobDetails['_id'], 'rating': jobRating})).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          jobDetails['rating'] = jobRating;
        });

        final snackBar = SnackBar(
          content: Text('Thank you for rating the sitter'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (response.statusCode == 500) {
        if (jsonResponse == 'need-update') {
          if (versionValid) {
            versionValid = false;
            showUpdateDialog(
              context,

            );
          }
          throw Exception(jsonResponse);
        } else {
          String snackBarText = jsonResponse;
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

  @override
  void initState() {
    user = auth.currentUser;
    jobDetails = widget.jobDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 20),
                  child: CircleAvatar(
                    backgroundImage: jobDetails['pickedSitter']['photoUrl'] !=
                            null
                        ? NetworkImage(jobDetails['pickedSitter']['photoUrl'])
                        : AssetImage('assets/images/profilePlaceholder.png'),
                    radius: 60,
                  ),
                ),
              ),
              Text(
                jobDetails['pickedSitter']['name'],
                style: TextStyle(fontSize: 25),
              ),
              Container(
                margin: EdgeInsets.only(top: 60),
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
                          DateTime.parse(jobDetails['startDateTime'])
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
                      '${timeFormatter(jobDetails['startDateTime'])} - ${timeFormatter(jobDetails['endDateTime'])}',
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      phoneNumberFormatter(
                          jobDetails['pickedSitter']['phoneNumber']),
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
                      'Years Of Experience',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      yearsOfExperience(
                          jobDetails['pickedSitter']['experience']),
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      '\$${jobDetails['pickedSitter']['hourlyRate']}',
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
                      initialRating:
                          jobDetails['pickedSitter']['rating'] != null
                              ? jobDetails['pickedSitter']['rating'].toDouble()
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
              if (jobDetails['pickedSitter']['description'] != null)
                Container(
                  margin: EdgeInsets.only(top: 4, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 7, right: 15),
                          child: Text(
                            jobDetails['pickedSitter']['description'],
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (jobDetails['pickedSitter']['description'] != null)
                Divider(
                  height: 20,
                  thickness: 2,
                ),
              if (widget.completed)
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: RatingBar(
                    initialRating: jobDetails['rating'] != null ? jobDetails['rating'].toDouble() : 3,
                    minRating: 1,
                    unratedColor: Colors.amber[100],
                    direction: Axis.horizontal,
                    itemCount: 5,
                    glow: false,
                    tapOnlyMode: true,
                    ignoreGestures: jobDetails['rating'] != null,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
                        )),
                    onRatingUpdate: (rating) {
                      jobRating = rating;
                    },
                  ),
                ),
              if(jobDetails['rating'] == null)
              Container(
                margin: EdgeInsets.only(top: 30, bottom: 5),
                height: 52.0,
                child: RaisedButton(
                  onPressed: () async {
                    if (widget.completed) {
                      await rateJob();
                    } else {
                      await cancel();
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
                        widget.completed ? 'Submit' : 'Cancel',
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
