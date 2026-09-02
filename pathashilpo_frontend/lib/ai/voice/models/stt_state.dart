enum SttStatus {
  uninitialized,
  ready,
  listening,
  processing,
  done,
  error,
  permissionDenied,
}

class SttResult {
  final String text;
  final bool isFinal;
  final double confidence;
  final String? languageCode;

  const SttResult({
    required this.text,
    required this.isFinal,
    this.confidence = 1.0,
    this.languageCode,
  });

  @override
  String toString() =>
      'SttResult(text: $text, isFinal: $isFinal, confidence: $confidence, lang: $languageCode)';
}
