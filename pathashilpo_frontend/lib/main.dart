import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'data/local/hive_init.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase across Android and Web platforms
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
