import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage Service for media files (PRD.md §4 & TRD.md §7).
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads artisan craft photo (processed / original)
  Future<String> uploadProductPhoto({
    required String artisanId,
    required String productId,
    required Uint8List bytes,
    bool isOriginal = false,
  }) async {
    final fileName = isOriginal ? 'original.jpg' : 'processed.jpg';
    final ref = _storage.ref().child('products/$artisanId/$productId/$fileName');
    
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'artisanId': artisanId, 'productId': productId},
    );

    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Uploads audio voice note recorded by the artisan
  Future<String> uploadAudioStory({
    required String artisanId,
    required String productId,
    required File audioFile,
  }) async {
    final ref = _storage.ref().child('products/$artisanId/$productId/audio.m4a');
    
    final metadata = SettableMetadata(
      contentType: 'audio/mp4',
      customMetadata: {'artisanId': artisanId, 'productId': productId},
    );

    final uploadTask = await ref.putFile(audioFile, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Uploads artisan profile picture
  Future<String> uploadProfilePicture({
    required String uid,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child('users/$uid/avatar.jpg');
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }
}
