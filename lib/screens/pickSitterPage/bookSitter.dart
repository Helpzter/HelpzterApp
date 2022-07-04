import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sitter_app/screens/homePage/parentHome/parentHome.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';

import '../../globals.dart';
import '../../materialColor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class BookSitter extends StatefulWidget {
  final Map jobDetails;
  final int index;
  final String jobId;

  BookSitter(this.jobDetails, this.index, this.jobId);

  @override
  _BookSitterState createState() => _BookSitterState();
}

class _BookSitterState extends State<BookSitter> {
  Map jobDetails;
  Map sitterDetails;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  var paymentCalc;

  Future<void> _pay() async {
    await InAppPayments.setSquareApplicationId(
        'sq0idp-UT-WGaHR8QaL2C_NCkTyPg');
    await InAppPayments.startCardEntryFlow(
        onCardNonceRequestSuccess: _onCardEntryCardNonceRequestSuccess,
        onCardEntryCancel: _onCancelCardEntryFlow);
  }

  void _onCancelCardEntryFlow() {
    // Handle the cancel callback
  }

  void _onCardEntryCardNonceRequestSuccess(CardDetails result) async {
    try {
      // take payment with the card nonce details
      // you can take a charge
      // await chargeCard(result);
      await bookSitter(result.nonce);

      // payment finished successfully
      // you must call this method to close card entry
      // this ONLY apply to startCardEntryFlow, please don't call this method when use startCardEntryFlowWithBuyerVerification
      InAppPayments.completeCardEntry(
          onCardEntryComplete: _onCardEntryComplete);
    } catch (ex) {
      // payment failed to complete due to error
      // notify card entry to show processing error
      InAppPayments.showCardNonceProcessingError(ex.message);
    }
  }

  void _onCardEntryComplete() {
    // Update UI to notify user that the payment flow is finished successfully
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => ParentHomePage()), (route) => false);
  }

  bookSitter(nonce) async {
    var token = await user.getIdToken();
    var response;
    try {
      response = await http.post(Uri.parse('http://www.$urlPath/findSitters/book'),
          headers: {
            'VersionNumber': jsonEncode(versionNumber),
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: token,
          },
          body: jsonEncode({
            'jobId': widget.jobId,
            'sitterId': sitterDetails['_id'],
            'nonce': nonce,
            'total': paymentCalc['total'],
          })).timeout(const Duration(seconds: timeout));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again'),
        ),
      );
      print(error);
    }
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);
    if (response.statusCode == 200) {
      return jsonResponse;
    } else if(jsonResponse == 'need-update') {
      if(versionValid) {
        versionValid = false;
        showUpdateDialog(
          context,

        );
      }
    } else {
          throw Exception(jsonResponse['errorMessage']);
      }
    }

  paymentCalculation() {
    DateTime startDateTime =
        DateTime.parse(jobDetails['startDateTime']).toLocal();
    DateTime endDateTime = DateTime.parse(jobDetails['endDateTime']).toLocal();
    double amountOfMin =
        endDateTime.difference(startDateTime).inMinutes.toDouble();
    double subtotalDecimal =
        sitterDetails['hourlyRate'].toDouble() / 60 * amountOfMin;
    double subtotal = subtotalDecimal.toPrecision(2);
    double serviceFee = (((globalServiceFee / 100) * subtotal) + globalSquareCharge).toPrecision(2);
    var total = (subtotal + serviceFee).toStringAsFixed(2);
    return {
      'subtotal': subtotal.toStringAsFixed(2),
      'serviceFee': serviceFee.toStringAsFixed(2),
      'total': total
    };
  }

  @override
  void initState() {
    user = auth.currentUser;
    jobDetails = widget.jobDetails;
    sitterDetails = jobDetails['sitters'][widget.index];
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
                    backgroundImage: sitterDetails['photoUrl'] != null
                        ? NetworkImage(sitterDetails['photoUrl'])
                        : AssetImage('assets/images/profilePlaceholder.png'),
                    radius: 60,
                  ),
                ),
              ),
              Text(
                sitterDetails['name'],
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
                      phoneNumberFormatter(sitterDetails['phoneNumber']),
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
                      yearsOfExperience(sitterDetails['experience']),
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
                      '\$${sitterDetails['hourlyRate']}',
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
                      initialRating: sitterDetails['rating'] != null
                          ? sitterDetails['rating'].toDouble()
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
              if (sitterDetails['description'] != null)
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
                            sitterDetails['description'],
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (sitterDetails['description'] != null)
                Divider(
                  height: 20,
                  thickness: 2,
                ),
              Container(
                margin: EdgeInsets.only(top: 40, bottom: 5),
                height: 52.0,
                child: RaisedButton(
                  onPressed: () async {
                    paymentCalc = paymentCalculation();
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, bottom: 8),
                                    child: Text(
                                      'Review Booking',
                                      style: TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Text(
                                    'SITTER',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                                Divider(
                                  height: 10,
                                  thickness: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: sitterDetails[
                                                  'photoUrl'] !=
                                              null
                                          ? NetworkImage(
                                              sitterDetails['photoUrl'])
                                          : AssetImage(
                                              'assets/images/profilePlaceholder.png'),
                                      radius: 23,
                                    ),
                                    title: Text(
                                      sitterDetails['name'],
                                      style: TextStyle(fontSize: 19),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 5, top: 10),
                                  child: Text(
                                    'PAYMENT',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                                Divider(
                                  height: 10,
                                  thickness: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 11, bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Hourly Rate',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      ),
                                      Text(
                                        '\$${sitterDetails['hourlyRate']}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Subtotal',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      ),
                                      Text(
                                        '\$${paymentCalc['subtotal']}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, bottom: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Service Fee',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      ),
                                      Text(
                                        '\$${paymentCalc['serviceFee']}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        '\$${paymentCalc['total']}',
                                        style: TextStyle(fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: const Text('PAY',
                                        style: TextStyle(
                                            fontSize: 18.5,
                                            color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      shape: StadiumBorder(),
                                      minimumSize: const Size.fromHeight(50),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      var startDateTime = DateTime.parse(jobDetails['startDateTime']).toLocal();
                                      if(startDateTime.difference(DateTime.now()).inHours >= 1) {
                                        await _pay();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Babysitting job has to be booked at least an hour in advanced, please try creating new job'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
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
                        'BOOK',
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
