/// Tolerant `createdAt` parsing shared by every model.
///
/// Documents in this project carry `createdAt` as an ISO-8601 **string**
/// (`toMap()` writes `DateTime.toIso8601String()`), which keeps the models free
/// of a `cloud_firestore` dependency and still sorts lexicographically.
///
/// Some documents were written with `FieldValue.serverTimestamp()` instead and
/// come back as a Firestore `Timestamp`. Passing one of those to
/// `DateTime.tryParse` throws
/// `type 'Timestamp' is not a subtype of type 'String'` at runtime and takes
/// the whole list view down with it. [parseTimestamp] accepts either shape so a
/// single legacy document cannot crash a screen.
DateTime parseTimestamp(Object? raw, {DateTime? fallback}) {
  if (raw is DateTime) return raw;
  if (raw is String) {
    return DateTime.tryParse(raw) ?? fallback ?? DateTime.now();
  }
  if (raw is int) {
    // Milliseconds since epoch, the shape a few older sync payloads used.
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }
  if (raw != null) {
    // Firestore Timestamp, matched structurally so this file need not import
    // cloud_firestore into the model layer.
    try {
      final Object? converted = (raw as dynamic).toDate();
      if (converted is DateTime) return converted;
    } catch (_) {
      // Not a Timestamp after all - fall through to the default.
    }
  }
  return fallback ?? DateTime.now();
}
