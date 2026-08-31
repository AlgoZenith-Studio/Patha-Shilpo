import 'package:hive_flutter/hive_flutter.dart';

/// Box names, matching TRD.md §4.4.
///
/// Only `drafts` and `session` are opened for now - `queue`, `cache_products`,
/// `cache_medians` and `media` have no consumer yet (sync engine, buyer
/// explore) and opening them speculatively would be dead weight.
abstract final class HiveBoxes {
  static const String drafts = 'drafts';
  static const String session = 'session';
}

/// Initialises Hive and opens the boxes this app actually uses.
///
/// Call once, before `runApp`. No custom `TypeAdapter`s are registered -
/// every box stores plain `Map<String, dynamic>` values with primitive
/// fields (`String`, `int`, `bool`, `List`, `Uint8List`), which Hive supports
/// natively.
Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxes.drafts);
  await Hive.openBox<dynamic>(HiveBoxes.session);
}
