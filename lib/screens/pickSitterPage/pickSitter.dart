import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sitter_app/screens/parentProfile/profileLoadingPage.dart';
import 'package:sitter_app/screens/pickSitterPage/bookSitter.dart';
import 'package:sitter_app/screens/serverUnreachableError/serverUnreachablePage.dart';

import '../../globals.dart';
import '../../loadingPage.dart';
import '../../materialColor.dart';
import 'package:http/http.dart' as http;

import '../emptyPage.dart';

class PickSitterPage extends StatefulWidget {
  final String jobId;

  PickSitterPage(this.jobId);

  @override
  _PickSitterPageState createState() => _PickSitterPageState();
}

class _PickSitterPageState extends State<PickSitterPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  List sitters;
  var result;

  Future getSitters() async {
    var token = await user.getIdToken();
    try {
      var response = await http.get(
        Uri.http('www.$urlPath', '/findSitters', {'jobId': widget.jobId}),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
      ).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 404) {
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
    } on TimeoutException catch (_) {
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

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSitters(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingPage();
          } else {
            result = snapshot.data;
            if (result != 'cant-find-sitters' && result != 'no-job-pending') {
              sitters = result['sitters'];
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Available Sitters',
                  style: TextStyle(color: materialColor(RosePink.primary)),
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  var sittersResult = await getSitters();
                  setState(() {
                    result = sittersResult;
                    if (result != 'cant-find-sitters' &&
                        result != 'no-job-pending') {
                      sitters = result['sitters'];
                    }
                  });
                },
                child: result == 'cant-find-sitters'
                    ? EmptyPage(
                        'Job description has been sent out to 50 sitters. No sitters have responded yet')
                    : result == 'no-job-pending'
                        ? EmptyPage(
                            'There is no current pending job on your account')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.5, vertical: 15),
                            itemCount: sitters.length,
                            itemBuilder: _itemBuilder,
                          ),
              ),
            );
          }
        });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BookSitter(result, index, widget.jobId)),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 15),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: sitters[index]['photoUrl'] != null
                        ? NetworkImage(sitters[index]['photoUrl'])
                        : AssetImage('assets/images/profilePlaceholder.png'),
                    radius: 30,
                  ),
                  title: Text(sitters[index]['name']),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 3,
                      children: [
                        Text('Hourly Rate: \$${sitters[index]['hourlyRate']}'),
                        RatingBar(
                          initialRating: sitters[index]['rating'] != null ? sitters[index]['rating'].toDouble() : 0,
                          unratedColor: Colors.amber[100],
                          ignoreGestures: true,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          glow: false,
                          allowHalfRating: true,
                          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                          itemSize: 20,
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
                  trailing: Icon(Icons.arrow_forward),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
