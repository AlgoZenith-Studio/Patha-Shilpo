import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/local/session_box.dart';

/// Locales the app ships. All three are **complete** - a partial locale would
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
/// resolves through `AppLocalizations` against this locale - no screen renders
/// a second language alongside it.
///
/// Resolution order is stored setting -> device -> `en` (TRD.md §10), backed
/// by the Hive `session` box.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider({Locale? initial, SessionBox session = const SessionBox()})
      : _session = session,
        _locale = initial ?? _resolveInitial(session);

  final SessionBox _session;
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

  static Locale _resolveInitial(SessionBox session) {
    final String? stored = session.locale;
    if (stored != null) {
      final Locale? match = kSupportedLocales
          .cast<Locale?>()
          .firstWhere((Locale? l) => l?.languageCode == stored, orElse: () => null);
      if (match != null) return match;
    }

    final String deviceCode = PlatformDispatcher.instance.locale.languageCode;
    return kSupportedLocales.firstWhere(
      (Locale l) => l.languageCode == deviceCode,
      orElse: () => const Locale('en'),
    );
  }

  void persist() {
    _session.setLocale(_locale.languageCode);
  }
}
