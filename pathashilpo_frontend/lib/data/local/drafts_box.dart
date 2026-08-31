import 'package:hive_flutter/hive_flutter.dart';

import 'hive_init.dart';

/// Thin typed wrapper over the Hive `drafts` box.
///
/// Keyed by `localId` (TRD.md §9.2) - the same UUID that becomes the
/// Firestore document id once synced, which is what makes writes idempotent.
/// Values are plain maps; `AddProductState.toMap()`/`fromMap()` define the
/// shape.
class DraftsBox {
  const DraftsBox();

  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(HiveBoxes.drafts);

  Future<void> put(String localId, Map<String, dynamic> data) =>
      _box.put(localId, data);

  Map<String, dynamic>? get(String localId) {
    final Map<dynamic, dynamic>? raw = _box.get(localId);
    if (raw == null) return null;
    return raw.map((dynamic k, dynamic v) => MapEntry(k as String, v));
  }

  Future<void> delete(String localId) => _box.delete(localId);

  /// All saved drafts, most recently updated first.
  List<Map<String, dynamic>> all() {
    final List<Map<String, dynamic>> drafts = _box.values
        .map((Map<dynamic, dynamic> raw) =>
            raw.map((dynamic k, dynamic v) => MapEntry(k as String, v)))
        .toList();
    drafts.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      final int au = a['updatedAtMs'] as int? ?? 0;
      final int bu = b['updatedAtMs'] as int? ?? 0;
      return bu.compareTo(au);
    });
    return drafts;
  }
}
