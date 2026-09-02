/// Geography presets according to TRD.md §4.1.
///
/// The craft vocabulary that used to live here has moved to [CraftTaxonomy]
/// (`craft_taxonomy.dart`). It was a *second* list of craft names, disagreeing
/// with the one buyers searched by, and RFQ matching compared the two with
/// string equality - so no buyer request ever reached an artisan. Add craft
/// categories there, never here.
abstract final class CraftConstants {
  static const List<String> indianStates = <String>[
    'Madhya Pradesh',
    'West Bengal',
    'Rajasthan',
    'Odisha',
    'Uttar Pradesh',
    'Gujarat',
    'Assam',
    'Karnataka',
    'Tamil Nadu',
    'Bihar',
    'Chhattisgarh',
    'Telangana',
    'Kashmir',
  ];
}
