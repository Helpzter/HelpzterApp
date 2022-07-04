import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sitter_app/drawers/sitterDrawer.dart';
import 'package:sitter_app/screens/parentProfile/profileLoadingPage.dart';
import 'package:intl/intl.dart';
import 'package:sitter_app/screens/serverUnreachableError/serverUnreachablePage.dart';
import 'package:sitter_app/screens/sitterInbox/sitterInboxDetails/sitterInboxDetails.dart';

import '../../globals.dart';
import '../../loadingPage.dart';
import '../../materialColor.dart';
import 'package:http/http.dart' as http;

import '../emptyPage.dart';

class SitterInboxPage extends StatefulWidget {
  @override
  _SitterInboxPageState createState() => _SitterInboxPageState();
}

class _SitterInboxPageState extends State<SitterInboxPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ScrollController scrollController = ScrollController();
  User user;
  List inbox;
  bool loading, allLoaded;
  var lastMessageId;

  Future getInbox({refreshing: false}) async {
    if (refreshing) {
      getInboxCount(context: context, user: user);
      allLoaded = false;
      lastMessageId = null;
    }
    if (allLoaded) {
      return;
    }
    if (!refreshing) {
      setState(() {
        loading = true;
      });
    }
    var token = await user.getIdToken();
    try {
      var response = await http.get(
        Uri.http('sitter.$urlPath', '/inbox', {'lastMessageId': lastMessageId}),
        headers: {
          'VersionNumber': jsonEncode(versionNumber),
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
      ).timeout(const Duration(seconds: timeout));
      if (response.statusCode == 200) {
        List newMessages = jsonDecode(response.body);
        if (newMessages.isNotEmpty) {
          if (refreshing) {
            inbox = newMessages;
          } else {
            inbox.addAll(newMessages);
          }
          lastMessageId = inbox.last['_id'];
        }
        setState(() {
          loading = false;
          allLoaded = newMessages.isEmpty;
        });
        return;
      } else if(response.statusCode == 500) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          loading = false;
        });
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
        setState(() {
          loading = false;
        });
        print(response.body);
        return response.body;
      }
    } on TimeoutException catch (_) {
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServerUnreachableErrorPage(),)
      );
      setState(() {});
      onBuild();
    } on SocketException catch (_) {
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServerUnreachableErrorPage(),)
      );
      setState(() {});
      onBuild();
    } catch (error) {
      print(error);
    }
  }


  void changeSeen(int index, bool value) {
    setState(() {
      inbox[index]['seen'] = value;
    });
  }

  void onBuild() {
    user = auth.currentUser;
    inbox = [];
    loading = false;
    allLoaded = false;
    getInboxCount(context: context, user: user);
    getInbox();
    scrollController.addListener(() {
      //checking if screen is fully scrolled
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.25 &&
          !loading && !allLoaded) {
        getInbox();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    onBuild();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (loading && inbox.isEmpty) {
        return LoadingPage();
      } else {
        return Scaffold(
          drawer: SitterDrawer(1),
          appBar: AppBar(
            title: Text(
              'Job Openings',
              style: TextStyle(color: materialColor(RosePink.primary)),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                lastMessageId = null;
                allLoaded = false;
                inbox = [];
              });
              await getInbox(refreshing: true);
            },
            child: inbox.isEmpty && !loading
                ? EmptyPage('You have no job openings currently')
                : ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    padding: const EdgeInsets.all(5.5),
                    itemCount: inbox.length + (loading ? 1 : 0),
                    itemBuilder: _itemBuilder,
                  ),
          ),
        );
      }
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index == inbox.length && loading) {
      return Container(
        child: Center(
          child: SpinKitSpinningLines(
            color: RosePink.primary,
            size: 65,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: inbox[index]['job']['parent']
                                ['photoUrl'] !=
                            null
                        ? NetworkImage(
                            inbox[index]['job']['parent']['photoUrl'])
                        : AssetImage('assets/images/profilePlaceholder.png'),
                    radius: 30,
                  ),
                  title: Text(
                    DateFormat('EEE, MMMM d').format(
                        DateTime.parse(inbox[index]['job']['startDateTime'])
                            .toLocal()),
                    style: TextStyle(
                        fontWeight:
                            !inbox[index]['seen'] ? FontWeight.w700 : null),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 2,
                      children: [
                        Text(
                          '${timeFormatter(inbox[index]['job']['startDateTime'])} - ${timeFormatter(inbox[index]['job']['endDateTime'])}',
                        ),
                        Text(
                            '${inbox[index]['job']['parent']['name']},  ${phoneNumberFormatter(inbox[index]['job']['parent']['phoneNumber'])}'),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SitterInboxDetails(
                      inboxDetails: inbox[index],
                      index: index,
                      changeSeen: changeSeen),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
