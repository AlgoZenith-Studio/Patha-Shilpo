import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'data/local/hive_init.dart';

// Firebase is deliberately not initialised yet - `firebase_options.dart`
// and `google-services.json` do not exist, and calling
// Firebase.initializeApp() before they do would break the build.
// See PROJECT_CONTEXT.md §8.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A missing .env should not crash the app - Env.backendUrl falls back to
  // the emulator loopback address if BACKEND_URL is unset.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env bundled (e.g. a dev who hasn't set one up yet) - continue with
    // defaults rather than failing to boot.
  }

  await initHive();

  runApp(const PathashilpaApp());
}
