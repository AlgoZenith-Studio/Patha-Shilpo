/// Which tier actually spoke (TRD.md §7 router contract).
///
/// Kept on the result so the UI can tell an online readback from the
/// on-device fallback, exactly as the listing and image pipelines do.
enum TtsSource {
  /// Sarvam AI, via the backend.
  sarvam,

  /// Bhashini ULCA, via the backend.
  bhashini,

  /// `flutter_tts` on the phone. No network involved.
  device,

  /// Nothing could speak - no online tier and no device voice for the
  /// language. The caller should stay silent rather than show a fake success.
  none,
}

/// What to read aloud.
class TtsInput {
  const TtsInput({required this.text, required this.languageCode});

  /// Capped at 1000 characters by the backend (`TtsRequest`), which is a cost
  /// guard rather than a model limit - TTS bills per character.
  final String text;

  /// BCP-47-ish language code: 'hi', 'bn', 'en'.
  final String languageCode;
}

class TtsResult {
  const TtsResult({required this.source, required this.spoken});

  final TtsSource source;

  /// False when nothing was audible, so the caller can surface a message
  /// instead of leaving the artisan waiting on silence.
  final bool spoken;
}
