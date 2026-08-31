import 'package:dio/dio.dart';

import '../../core/config/env.dart';

/// Shared Dio client for the FastAPI backend.
///
/// Timeouts match what the backend actually enforces per provider
/// (TRD.md §8.5): 12s for Gemini/listing, 30s for fal.ai/image. Using the
/// longer one here as the connection default and letting each call override
/// `receiveTimeout` per-request keeps this client simple.
///
/// Sends a bearer token because every `/api/v1/*` route requires one - but
/// `core/security.py` on the backend is currently a **stub** that accepts any
/// non-empty token (TRD.md §18.3). This is not a real credential; it exists
/// only to satisfy that stub until real Firebase auth is wired on both ends.
class ApiClient {
  ApiClient._();

  static Dio? _instance;

  static Dio get instance {
    return _instance ??= Dio(
      BaseOptions(
        baseUrl: Env.backendUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, String>{
          'Authorization': 'Bearer dev-token',
        },
      ),
    );
  }
}
