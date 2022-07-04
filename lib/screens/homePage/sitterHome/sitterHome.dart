import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sitter_app/drawers/sitterDrawer.dart';
import 'package:sitter_app/screens/homePage/sitterHome/homeLoadingScreen.dart';
import 'package:intl/intl.dart';
import 'package:sitter_app/screens/serverUnreachableError/serverUnreachablePage.dart';
import 'package:sitter_app/screens/sitterBookedDetails/sitterBookedDetails.dart';

import '../../../globals.dart';
import '../../../materialColor.dart';
import 'package:http/http.dart' as http;

class SitterHomePage extends StatefulWidget {
  @override
  _SitterHomePageState createState() => _SitterHomePageState();
}

class _SitterHomePageState extends State<SitterHomePage> {
  DateTime currentBackPressTime;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  Map result;

  Future getJobs() async {
    var token = await user.getIdToken();
    try {
      var response = await http.get(
        Uri.parse('http://sitter.$urlPath/jobs'),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return jsonResponse;
      } else if(response.statusCode == 500) {
        if(jsonResponse == 'need-update') {
          if(versionValid) {
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
      drawer: SitterDrawer(0),
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
      ),
      body: FutureBuilder(
          future: getJobs(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return HomeLoadingScreen();
            } else {
              result = snapshot.data;
              return RefreshIndicator(
                onRefresh: () async {
                  var response = await getJobs();
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
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 15),
                                child: ValueListenableBuilder<Map>(
                                  valueListenable: userInfo,
                                  builder: (context, value, child) {
                                    return Text(
                                      'Welcome, ${value['name']}',
                                      style: TextStyle(
                                          fontSize: 25, fontWeight: FontWeight.w200),
                                    );
                                  },
                                ),
                              ),
                              Text(
                                'Today\'s Bookings',
                                style: TextStyle(fontSize: 17),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 7, top: 6),
                                child: Container(
                                  height: 3,
                                  width: 50,
                                  color: materialColor(RosePink.primary),
                                ),
                              ),
                              if (result['todaysJobs'].length == 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    'You do not have any jobs booked for today',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              else
                                for (var job in result['todaysJobs'])
                                  customCard(context, job, DateTime.now().isBefore(DateTime.parse(job['startDateTime']).toLocal())),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'Future Bookings',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 7, top: 6),
                                child: Container(
                                  height: 3,
                                  width: 50,
                                  color: materialColor(RosePink.primary),
                                ),
                              ),
                              if (result['futureJobs'].length == 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    'You do not have any upcoming jobs currently',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              else
                                for (var job in result['futureJobs'])
                                  customCard(context, job, true),
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'Previous Bookings',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 7, top: 6),
                                child: Container(
                                  height: 3,
                                  width: 50,
                                  color: materialColor(RosePink.primary),
                                ),
                              ),
                              if (result['previousJobs'].length == 0)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Text(
                                    'You do not have any previously booked jobs',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                                )
                              else
                                for (var job in result['previousJobs'])
                                  customCard(context, job, false),
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

Widget customCard(context, Map job, cancelable) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SitterBookedDetails(
                      job: job, cancelable: cancelable,),
                ),
              );
            },
            child: Padding(
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
                      Text(
                          '${job['parent']['name']},  ${phoneNumberFormatter(job['parent']['phoneNumber'])}'),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
