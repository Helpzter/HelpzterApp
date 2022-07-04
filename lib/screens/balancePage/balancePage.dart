import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sitter_app/loadingPage.dart';
import 'package:sitter_app/size_config.dart';

import '../../globals.dart';
import '../../materialColor.dart';
import '../serverUnreachableError/serverUnreachablePage.dart';
import 'package:http/http.dart' as http;

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class BalancePage extends StatefulWidget {
  const BalancePage({Key key}) : super(key: key);

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  var result;
  List transactions;

  void changeRequestedWithdraw(context, bool requestedWithdraw) async {
    var token = await user.getIdToken();
    try {
      var response = await http.post(
          Uri.parse('http://sitter.$urlPath/balance'),
          headers: {
            'VersionNumber': jsonEncode(versionNumber),
            'Content-Type': 'application/json',
            HttpHeaders.authorizationHeader: token,
          },
          body:
              jsonEncode({'requestedWithdraw': !result['requestedWithdraw']})).timeout(const Duration(seconds: timeout));
      var jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          result['requestedWithdraw'] = !result['requestedWithdraw'];
        });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again'),
        ),
      );
      print(error);
    }
  }

  Future getBalance() async {
    var token = await user.getIdToken();
    try {
      var response = await http.get(
        Uri.parse('http://sitter.$urlPath/balance'),
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

  calculateTotal(List payments, List withdraws) {
    double paymentsTotal = 0;
    double withdrawsTotal = 0;
    payments.forEach((payment) {
      if (payment['price'] != null) {
        paymentsTotal = paymentsTotal + payment['price'];
      }
    });
    withdraws.forEach((withdraw) {
      withdrawsTotal = withdrawsTotal + withdraw['amount'];
    });
    return (paymentsTotal - withdrawsTotal).toStringAsFixed(2);
  }

  mapLists() {
    var mappedPayments = result['payments'].map((payment) => {
          'amount': payment['price'],
          'date': payment['endDateTime'],
          'payment': true,
        });
    var mappedWithdraw = result['withdraws'].map((payment) => {
      'amount': payment['amount'],
      'date': payment['date'],
      'payment': false,
    });
    List transactionList = [...mappedPayments, ...mappedWithdraw];
    transactionList.sort((a,b) => b['date'].compareTo(a['date']));
    return transactionList;
  }

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Balance',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
      ),
      body: FutureBuilder(
          future: getBalance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LoadingPage();
            } else {
              result = snapshot.data;
              transactions = mapLists();
              return RefreshIndicator(
                onRefresh: () async {
                  var response = await getBalance();
                  setState(() {
                    result = response;
                    transactions = mapLists();
                  });
                },
                child: ListView(
                  padding: const EdgeInsets.all(15),
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'Your balance',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 10),
                        child: Text(
                          '\$${calculateTotal(result['payments'], result['withdraws'])}',
                          style: TextStyle(
                              fontSize: 45, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(450),
                      child: Card(
                        elevation: 2,
                        margin: EdgeInsets.all(10),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: transactions.length,
                          itemBuilder: _transactionCard,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 35, bottom: 10, right: 10, left: 10),
                      height: 52.0,
                      child: RaisedButton(
                        onPressed: () {
                          changeRequestedWithdraw(
                              context, result['requestedWithdraw']);
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
                              result['requestedWithdraw']
                                  ? 'Cancel Requested Withdraw'
                                  : 'Request Withdraw',
                              style: TextStyle(
                                  fontSize: 18.5, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }

  Widget _transactionCard(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
            title:
                Text(transactions[index]['payment'] ? 'Payment' : 'Withdraw'),
            subtitle: Text(DateFormat('MMMM d, yyyy').format(
                DateTime.parse(transactions[index]['date'])
                    .toLocal()),),
            trailing: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '\$${transactions[index]['amount']}',
                    style: TextStyle(
                        color: transactions[index]['payment']
                            ? Colors.green
                            : Colors.red,
                        fontSize: 18),
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(
                        transactions[index]['payment']
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: transactions[index]['payment']
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
