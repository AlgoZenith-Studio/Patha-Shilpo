import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/config/env.dart';

/// Shared Dio client for the FastAPI backend.
///
/// Timeouts match what the backend enforces per provider (TRD.md §8.5): 12s
/// for Gemini/listing, 30s for fal.ai/image, set per-request.
///
/// Attaches the signed-in user's **real Firebase ID token** on every call.
/// The backend verifies it with `firebase_admin.auth.verify_id_token()`
/// (TRD.md §5.5), so an unauthenticated caller cannot reach the AI endpoints
/// or spend the provider quota.
class ApiClient {
  ApiClient._();

  static Dio? _instance;

  static Dio get instance {
    return _instance ??= _build();
  }

  static Dio _build() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: Env.backendUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options,
            RequestInterceptorHandler handler) async {
          try {
            // Firebase refreshes this automatically when it is close to
            // expiring, so fetching per request is the supported pattern.
            final String? token =
                await FirebaseAuth.instance.currentUser?.getIdToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // No token available - let the request go out unauthenticated and
            // be rejected by the backend, rather than throwing here. The AI
            // routers already treat a failure as "fall back to offline".
          }
          handler.next(options);
        },
      ),
    );

    return dio;
  }
}
