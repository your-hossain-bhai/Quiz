import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage;

  StorageService({FirebaseStorage? firebaseStorage})
      : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    final ref = _firebaseStorage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
