// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/firebase_config.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String userId, File file) async {
    try {
      final ref = _storage
          .ref()
          .child(FirebaseConfig.profileImagesPath)
          .child('$userId.jpg');

      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      await _storage
          .ref()
          .child(FirebaseConfig.profileImagesPath)
          .child('$userId.jpg')
          .delete();
    } catch (_) {}
  }

  Future<String?> uploadLessonImage(String lessonId, File file) async {
    try {
      final ref = _storage
          .ref()
          .child(FirebaseConfig.lessonImagesPath)
          .child('$lessonId.jpg');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
