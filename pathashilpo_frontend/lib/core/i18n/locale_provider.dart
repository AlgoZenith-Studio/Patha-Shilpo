import 'dart:ui';

import 'package:flutter/material.dart';

/// Locales the app ships. All three are **complete** — a partial locale would
/// fall back to English per key and mix scripts on screen, which the language
/// rule forbids.
const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('hi'),
  Locale('bn'),
];

/// Display name for each locale, written in that locale.
const Map<String, String> kLocaleNames = <String, String>{
  'en': 'English',
  'hi': 'हिन्दी',
  'bn': 'বাংলা',
};

/// Holds the active UI locale.
///
/// **This is the single control for the whole app.** Every user-visible string
/// resolves through `AppLocalizations` against this locale — no screen renders
/// a second language alongside it.
///
/// Resolution order is stored setting → device → `en` (TRD.md §10). The stored
/// setting will move to the Hive `session` box once local persistence is wired;
/// until then it lives in memory for the session.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({Locale? initial}) : _locale = initial ?? _resolveFromDevice();

  Locale _locale;

  Locale get locale => _locale;

  String get displayName => kLocaleNames[_locale.languageCode] ?? 'English';

  void setLocale(Locale locale) {
    if (!_isSupported(locale) || locale.languageCode == _locale.languageCode) {
      return;
    }
    _locale = locale;
    notifyListeners();
    persist();
  }

  static bool _isSupported(Locale l) =>
      kSupportedLocales.any((Locale s) => s.languageCode == l.languageCode);

  static Locale _resolveFromDevice() {
    final String deviceCode = PlatformDispatcher.instance.locale.languageCode;
    return kSupportedLocales.firstWhere(
      (Locale l) => l.languageCode == deviceCode,
      orElse: () => const Locale('en'),
    );
  }

  /// Seam for Hive persistence (`session` box).
  void persist() {
    // TODO(data): store locale in the Hive `session` box once wired.
  }
}
