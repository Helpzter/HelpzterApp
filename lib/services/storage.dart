import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sitter_app/globals.dart';

class StorageService {
  FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: 'gs://helpzter-69822.appspot.com');

  Future<String> uploadFile(File file) async {
    var user = FirebaseAuth.instance.currentUser;
    var storageRef = storage.ref().child('user/${user.uid}/${globalUser['userRole']}');
    var uploadTask = await storageRef.putFile(file);
    String downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> getUserProfileImage(String uid) async {
    var user = FirebaseAuth.instance.currentUser;
    return await storage.ref().child('user/${user.uid}/${globalUser['userRole']}').getDownloadURL();
  }

  Future deleteUserProfileImage(String uid) async {
    await storage.ref().child('user/$uid/${globalUser['userRole']}').delete();
  }
}