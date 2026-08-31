import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../../data/remote/api_client.dart';
import 'image_result.dart';

/// Router for image processing (TRD.md AD-5): tries the backend's
/// `POST /api/v1/ai/image` (fal.ai background removal + enhancement, per
/// TRD.md §8.4) when a network is reported, and keeps the local photo
/// unprocessed on any failure. `run()` never throws - a degraded [ImageResult]
/// wrapping the original bytes is always returned (TRD.md §7 router contract).
class ImageRouter {
  const ImageRouter({Future<bool> Function()? isOnline, Dio? client})
      : _isOnlineOverride = isOnline,
        _client = client;

  /// Injectable for tests; defaults to a real `connectivity_plus` check.
  final Future<bool> Function()? _isOnlineOverride;
  final Dio? _client;

  Future<ImageResult> run(Uint8List photoBytes) async {
    if (await _safeIsOnline()) {
      try {
        return await _callBackend(photoBytes);
      } catch (_) {
        // Falls through to the local-only result - see class doc.
      }
    }

    return _localResult(photoBytes);
  }

  /// Never throws - a failed connectivity check is treated as offline rather
  /// than propagating, which would break the "run() never throws" contract.
  Future<bool> _safeIsOnline() async {
    try {
      if (_isOnlineOverride != null) return await _isOnlineOverride();
      final List<ConnectivityResult> result =
          await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none) && result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<ImageResult> _callBackend(Uint8List photoBytes) async {
    final Dio client = _client ?? ApiClient.instance;

    final FormData form = FormData.fromMap(<String, dynamic>{
      'file': MultipartFile.fromBytes(photoBytes, filename: 'photo.jpg'),
    });

    final Response<Map<String, dynamic>> response =
        await client.post<Map<String, dynamic>>(
      '/api/v1/ai/image',
      data: form,
      options: Options(receiveTimeout: const Duration(seconds: 30)),
    );

    final Map<String, dynamic> body = response.data!;
    return ImageResult(
      imageUrl: body['image_url'] as String,
      backgroundRemoved: body['background_removed'] as bool,
      degraded: body['degraded'] as bool,
    );
  }

  ImageResult _localResult(Uint8List photoBytes) {
    return ImageResult(
      imageUrl: 'data:image/jpeg;base64,${base64Encode(photoBytes)}',
      backgroundRemoved: false,
      degraded: true,
    );
  }
}
