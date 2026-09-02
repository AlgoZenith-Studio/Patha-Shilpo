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
    final ref =
        _storage.ref().child('products/$artisanId/$productId/$fileName');

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
    final ref =
        _storage.ref().child('products/$artisanId/$productId/audio.m4a');

    final metadata = SettableMetadata(
      contentType: 'audio/mp4',
      customMetadata: {'artisanId': artisanId, 'productId': productId},
    );

    final uploadTask = await ref.putFile(audioFile, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

  /// Uploads artisan profile picture
  /// Uploads a photograph of an identity document (Aadhaar / PAN / GSTIN).
  ///
  /// Written to `identity/{uid}/` which is **private** in storage.rules -
  /// readable only by the artisan who owns it. The document NUMBER is never
  /// stored anywhere (TRD.md §5.6); only this image and the document *type*
  /// are kept, and the type goes to Firestore, not here.
  Future<String> uploadIdentityDocument({
    required String uid,
    required String idType,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child('identity/$uid/$idType.jpg');
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      // Marks intent at the storage layer as well as in the rules.
      customMetadata: <String, String>{'visibility': 'private'},
    );
    final uploadTask = await ref.putData(bytes, metadata);
    return await uploadTask.ref.getDownloadURL();
  }

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
