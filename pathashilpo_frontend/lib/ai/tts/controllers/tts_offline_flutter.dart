import 'package:flutter_tts/flutter_tts.dart';

import '../models/tts_input.dart';

/// Offline tier: the phone's own voice via `flutter_tts` (TRD.md §8.5).
///
/// Whether a given language is actually installed is a device fact, not a
/// guarantee - a budget Android 8 phone may have no Hindi or Bengali voice at
/// all. [speak] reports that honestly instead of silently doing nothing, so
/// the UI can say "no voice available" rather than appear broken.
class TtsOffline {
  TtsOffline({FlutterTts? engine}) : _tts = engine ?? FlutterTts();

  final FlutterTts _tts;

  /// Maps our short codes to the locales Android's TTS expects.
  static const Map<String, String> _locales = <String, String>{
    'hi': 'hi-IN',
    'bn': 'bn-IN',
    'en': 'en-IN',
  };

  Future<bool> speak(TtsInput input) async {
    final String locale = _locales[input.languageCode] ?? 'en-IN';

    try {
      final dynamic available = await _tts.isLanguageAvailable(locale);
      if (available == false) return false;

      await _tts.setLanguage(locale);
      // Slightly slower than default: the listener may have limited literacy
      // and this is a number they are being asked to trust (PRD.md §6).
      await _tts.setSpeechRate(0.45);
      await _tts.speak(input.text);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> prewarm(String languageCode) async {
    final String locale = _locales[languageCode] ?? 'en-IN';
    try {
      await _tts.isLanguageAvailable(locale);
      await _tts.setLanguage(locale);
    } catch (_) {}
  }

  Future<void> stop() => _tts.stop();
}
