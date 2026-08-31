import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App runtime config, loaded from the `.env` bundled as an asset
/// (`pubspec.yaml` -> `flutter: assets:`).
///
/// `.env` is git-ignored per developer (see `.env.example` at the project
/// root for the template). This mechanism is dev-only: it bundles a plain
/// LAN IP into the APK, which is fine for local builds but not how a
/// production build pointed at a real backend should get its URL.
abstract final class Env {
  /// Falls back to the Android emulator's host-loopback alias if `.env` is
  /// missing or `BACKEND_URL` isn't set, so the app still boots for a dev who
  /// hasn't configured it yet - it just won't reach a real device that way.
  static String get backendUrl {
    final String? value = dotenv.env['BACKEND_URL'];
    if (value == null || value.trim().isEmpty) {
      return 'http://10.0.2.2:8000';
    }
    return value.trim();
  }
}
