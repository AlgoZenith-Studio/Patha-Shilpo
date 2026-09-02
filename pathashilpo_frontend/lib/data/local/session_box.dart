import 'package:hive_flutter/hive_flutter.dart';

import 'hive_init.dart';

/// Thin wrapper over the Hive `session` box - TRD.md §4.4: `role`, `locale`,
/// `lastSyncAt`. Lets the app know which shell to render and which language
/// to use before the network responds. **Never trusted for authorisation** -
/// that is the Security Rules' job, this is UI convenience only.
class SessionBox {
  const SessionBox();

  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.session);

  static const String _localeKey = 'locale';
  static const String _roleKey = 'role';

  String? get locale => _box.get(_localeKey) as String?;
  Future<void> setLocale(String languageCode) =>
      _box.put(_localeKey, languageCode);

  String? get role => _box.get(_roleKey) as String?;
  Future<void> setRole(String role) => _box.put(_roleKey, role);
  Future<void> clearRole() => _box.delete(_roleKey);
}
