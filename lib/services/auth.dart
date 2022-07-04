import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sitter_app/models/user.dart';
import 'package:http/http.dart' as http;


import '../globals.dart';

class AuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser _userFromFirebaseUser(user) {
    return user != null ? FirebaseUser(uid: user.uid) : null;
  }

  Stream<FirebaseUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in with google
  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      var result = await _auth.signInWithCredential(credential);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } else {
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    var response = {};
    try {
      var result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      response = {'success': true, 'response': _userFromFirebaseUser(user)};
    } on FirebaseAuthException catch (e) {
      response = {'success': false, 'response': e};
    }
    return response;
  }

  // sign up with email and password

  Future registerWithEmailAndPassword(String email, String password) async {
    var response = {};
    try {
      var result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user;
      response = {'success': true, 'response': _userFromFirebaseUser(user)};
    } on FirebaseAuthException catch (e) {
      response = {'success': false, 'response': e};
    }
    return response;
  }

  Future changePassword(String currentPassword, String newPassword) async {
    var response = {};
    final user = _auth.currentUser;
    final cred = EmailAuthProvider.credential(
        email: user.email, password: currentPassword);
    try {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      response = {'success': true};
    } on FirebaseAuthException catch (e) {
      response = {'success': false, 'response': e};
    }
    return response;
  }

  // reset password
  Future resetPasswordLink(String email) async {
    var response = {};
    try {
      await _auth.sendPasswordResetEmail(email: email);
      response = {'success': true};
    } on FirebaseAuthException catch (e) {
      response = {'success': false, 'response': e};
    }
    return response;
  }

  // sign out
  Future signOut() async {
    try {
      var storageDir = await getApplicationDocumentsDirectory();
      var token = await _auth.currentUser.getIdToken();
      if (await File(storageDir.path + "/" + fileName).exists()) {
        storageDir.delete(recursive: true);
      }
      http.post(
        Uri.http('www.$urlPath', '/signOut'),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: token,
        },
        body: jsonEncode({'userRole': globalUser['userRole']}),
      ).timeout(const Duration(seconds: timeout));
      unreadCount.value = 0;
      globalUser = null;
      GoogleSignIn _googleSignIn = GoogleSignIn();
      await _googleSignIn.signOut();
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
