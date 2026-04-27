import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get uid => auth.currentUser!.uid;

  Future<String> uploadStudyMaterial({
    required File file,
    required String groupId,
    required String fileName,
  }) async {
    final ref = storage.ref().child(
          'groups/$groupId/materials/$fileName',
        );

    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadProfileImage({
    required File file,
  }) async {
    final ref = storage.ref().child(
          'users/$uid/profile.jpg',
        );

    final uploadTask = await ref.putFile(file);
    return uploadTask.ref.getDownloadURL();
  }
}