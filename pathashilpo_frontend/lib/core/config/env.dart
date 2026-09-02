import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App runtime config, loaded from the `.env` bundled as an asset
/// (`pubspec.yaml` -> `flutter: assets:`).
///
/// `.env` is git-ignored per developer (see `.env.example` at the project
/// root for the template). This mechanism is dev-only: it bundles a plain
/// LAN IP into the APK, which is fine for local builds but not how a
/// production build pointed at a real backend should get its URL.
abstract final class Env {
  /// Resolves the backend URL:
  /// 1. `--dart-define=BACKEND_URL=https://...` (for release builds / CI)
  /// 2. `.env` file `BACKEND_URL` (for local development)
  /// 3. Fallback to Android emulator loopback `http://10.0.2.2:8000`
  static String get backendUrl {
    const String fromDefine = String.fromEnvironment('BACKEND_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine.trim();
    }
    final String? value = dotenv.env['BACKEND_URL'];
    if (value == null || value.trim().isEmpty) {
      return 'http://10.0.2.2:8000';
    }
    return value.trim();
  }
}
