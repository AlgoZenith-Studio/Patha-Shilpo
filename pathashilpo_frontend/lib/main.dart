import 'package:flutter/material.dart';

import 'app.dart';

// Firebase and Hive are deliberately not initialised yet — `firebase_options.dart`
// and `google-services.json` do not exist, and calling Firebase.initializeApp()
// before they do would break the build. See PROJECT_CONTEXT.md §8.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PathashilpaApp());
}
