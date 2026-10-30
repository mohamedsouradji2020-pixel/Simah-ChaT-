import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Envoi de médias (photos) vers Firebase Storage.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadChatImage(String chatId, File file) async {
    final id = const Uuid().v4();
    final ref = _storage.ref().child('chats/$chatId/$id.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('profiles/$uid.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
