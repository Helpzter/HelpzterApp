import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sitter_app/drawers/parentDrawer.dart';
import 'package:sitter_app/screens/homePage/sitterHome/homeLoadingScreen.dart';
import 'package:intl/intl.dart';
import 'package:sitter_app/screens/pickSitterPage/emergencyBookingPending.dart';
import 'package:sitter_app/screens/pickSitterPage/pickSitter.dart';
import 'package:sitter_app/screens/serverUnreachableError/serverUnreachablePage.dart';

import '../../../globals.dart';
import '../../../materialColor.dart';
import 'package:http/http.dart' as http;

import 'bookedDetails.dart';
import 'bookingLoadingScreen.dart';

class ParentsBookingPage extends StatefulWidget {
  @override
  _ParentsBookingPageState createState() => _ParentsBookingPageState();
}

class _ParentsBookingPageState extends State<ParentsBookingPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  Map result;

  Future getBookings() async {
    var token = await user.getIdToken();
    try {
      var response = await http.get(
        Uri.parse('http://www.$urlPath/bookings'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse;
      } else if (response.statusCode == 500) {
        if (jsonResponse == 'need-update') {
          if (versionValid) {
            versionValid = false;
            showUpdateDialog(
              context,

            );
          }
          throw Exception(jsonResponse);
        }
      } else {
        print(response.body);
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

  @override
  void initState() {
    user = auth.currentUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ParentDrawer(2),
      appBar: AppBar(
        title: Text(
          'Bookings',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
      ),
      body: FutureBuilder(
          future: getBookings(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return BookingLoadingScreen();
            } else {
              result = snapshot.data;
              return RefreshIndicator(
                onRefresh: () async {
                  var response = await getBookings();
                  setState(() {
                    result = response;
                  });
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pending',
                                style: TextStyle(fontSize: 17),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 7, top: 6),
                                child: Container(
                                  height: 3,
                                  width: 50,
                                  color: materialColor(RosePink.primary),
                                ),
                              ),
                              if (result['pending'].length == 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    'You do not have any pending jobs currently',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              else
                                for (var job in result['pending'])
                                  pendingCard(context, job),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'Booked',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 7, top: 6),
                                child: Container(
                                  height: 3,
                                  width: 50,
                                  color: materialColor(RosePink.primary),
                                ),
                              ),
                              if (result['booked'].length == 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    'You do not have booked jobs currently',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              else
                                for (var job in result['booked'])
                                  bookedCard(context, job, false),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'Completed Jobs',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 7, top: 6),
                                child: Container(
                                  height: 3,
                                  width: 50,
                                  color: materialColor(RosePink.primary),
                                ),
                              ),
                              if (result['completed'].length == 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    'You do not have any completed jobs',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              else
                                for (var job in result['completed'])
                                  bookedCard(context, job, true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }
}

Widget pendingCard(BuildContext context, Map job) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          if(job['emergencyBooking']) {
            Navigator
                .push(
              context,
              MaterialPageRoute(
                builder: (context) => EmergencyBookingPendingPage(job),
              ),
            );
          } else {
            Navigator
                .push(
              context,
              MaterialPageRoute(
                builder: (context) => PickSitterPage(job['_id']),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
              child: ListTile(
                title: Text(DateFormat('EEE, MMMM d')
                    .format(DateTime.parse(job['startDateTime']).toLocal())),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 2,
                    children: [
                      Text(
                        '${timeFormatter(job['startDateTime'])} - ${timeFormatter(job['endDateTime'])}',
                      ),
                      job['emergencyBooking'] ? Text('Emergency Booking') : Text(
                          'Amount of sitters applied: ${job['sitters'].length}'),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget bookedCard(BuildContext context, Map job, bool completed) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookedDetails(job, completed),
          ),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
              child: ListTile(
                title: Text(DateFormat('EEE, MMMM d')
                    .format(DateTime.parse(job['startDateTime']).toLocal())),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 2,
                    children: [
                      Text(
                        '${timeFormatter(job['startDateTime'])} - ${timeFormatter(job['endDateTime'])}',
                      ),
                      job['emergencyBooking'] ? Text('Emergency Booking') : Text(
                          'Amount of sitters applied: ${job['sitters'].length}'),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
