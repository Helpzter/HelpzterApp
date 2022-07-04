import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sitter_app/screens/parentProfile/profileLoadingPage.dart';
import 'package:sitter_app/screens/serverUnreachableError/serverUnreachablePage.dart';
import 'package:sitter_app/screens/sitterInbox/sitterInboxDetails/sitterInboxDetails.dart';

import '../../../globals.dart';
import '../../../loadingPage.dart';
import '../../../materialColor.dart';
import 'package:http/http.dart' as http;

class GetSitterInboxDetails extends StatefulWidget {
  final jobId;

  GetSitterInboxDetails(this.jobId);

  @override
  _SitterInboxDetailsState createState() => _SitterInboxDetailsState();
}

class _SitterInboxDetailsState extends State<GetSitterInboxDetails> {
  Map inboxDetails;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future getJobData(jobId, context) async {
    User user = auth.currentUser;
    var token = await user.getIdToken();
    try {
      var response = await http.get(
        Uri.http('sitter.$urlPath', '/inbox/notificationData', {'jobId': jobId}),
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
        return response;
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
  Widget build(BuildContext context) {
    return 
  FutureBuilder(future: getJobData(widget.jobId, context),
    builder: (context, snapshot) {
    if (!snapshot.hasData) {
    return LoadingPage();
    } else {
      return SitterInboxDetails(inboxDetails: snapshot.data);
    }
    });
  }
}
