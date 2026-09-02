/// The single craft vocabulary shared by artisans, products and RFQs.
///
/// Before this existed the app carried three incompatible lists - the artisan
/// registration picker ('Dhokra & Metalware'), the buyer explore chips
/// ('Metal Casting') and whatever free text sat on an artisan document
/// ('Dhokra Lost-Wax Metal Casting'). RFQ matching compared those with exact
/// string equality, so a buyer's request never reached a single artisan.
///
/// [categories] is now the one list every picker renders. [categoryFor]
/// normalises anything else - legacy labels, seeded free text, an artisan's own
/// wording - onto that list, so existing documents keep matching without a data
/// migration.
abstract final class CraftTaxonomy {
  /// Sentinel used by the explore filter to mean "do not filter".
  static const String all = 'All Crafts';

  /// Canonical categories. These are the values written to
  /// `products.craftType`, `rfqs.craft` and `artisans.craft` from here on.
  ///
  /// Deliberately matches the vocabulary already seeded into Firestore
  /// (pathashilpo_backend/scripts/seed_data.json) so live documents stay valid.
  static const List<String> categories = <String>[
    'Handloom Weaving',
    'Terracotta Pottery',
    'Metal Casting',
    'Folk Art Painting',
    'Contemporary Art',
    'Wood Carving',
    'Bamboo Craft',
    'Leather & Jutti Craft',
    'Stone Carving',
    'Applique & Embroidery',
  ];

  /// [categories] with the "no filter" sentinel in front, for explore chips.
  static const List<String> filterOptions = <String>[all, ...categories];

  /// Keyword table, most specific first.
  ///
  /// Order matters: 'Contemporary Watercolour' must resolve to Contemporary Art,
  /// not to Folk Art Painting via the generic 'paint' keyword, so the narrower
  /// entries are listed above the broader ones.
  static const List<(String, List<String>)> _keywords =
      <(String, List<String>)>[
    (
      'Contemporary Art',
      <String>[
        'contemporary',
        'watercolour',
        'watercolor',
        'sketch',
        'illustration',
      ]
    ),
    (
      'Metal Casting',
      <String>[
        'dhokra',
        'metalware',
        'metal',
        'brass',
        'bronze',
        'bell metal',
        'casting',
        'ghadwa',
      ]
    ),
    (
      'Terracotta Pottery',
      <String>[
        'terracotta',
        'pottery',
        'clay',
        'ceramic',
        'kumbhakar',
        'potter',
      ]
    ),
    (
      'Handloom Weaving',
      <String>[
        'handloom',
        'weav',
        'loom',
        'textile',
        'saree',
        'sari',
        'chanderi',
        'silk',
        'cotton',
        'fabric',
      ]
    ),
    (
      'Applique & Embroidery',
      <String>[
        'applique',
        'embroider',
        'kantha',
        'chikan',
        'zardozi',
      ]
    ),
    ('Bamboo Craft', <String>['bamboo', 'cane', 'wicker']),
    ('Wood Carving', <String>['wood', 'carpent']),
    ('Leather & Jutti Craft', <String>['leather', 'jutti', 'mojari']),
    ('Stone Carving', <String>['stone', 'marble', 'granite']),
    // Broadest last - 'paint' and 'art' would otherwise swallow the narrower
    // categories above.
    (
      'Folk Art Painting',
      <String>[
        'madhubani',
        'mithila',
        'pattachitra',
        'warli',
        'gond',
        'kalamkari',
        'folk',
        'painting',
        'paint',
        'screen-print',
        'screenprint',
        'print',
        'poster',
      ]
    ),
  ];

  /// Resolve any craft string onto a canonical category.
  ///
  /// Returns null when nothing matches, which callers should treat as
  /// "uncategorised" rather than silently bucketing it somewhere wrong.
  static String? categoryFor(String? rawCraft) {
    if (rawCraft == null) return null;
    final String craft = rawCraft.trim().toLowerCase();
    if (craft.isEmpty) return null;

    // An exact canonical value is the common case once data is normalised.
    for (final String category in categories) {
      if (category.toLowerCase() == craft) return category;
    }

    for (final (String category, List<String> words) in _keywords) {
      for (final String word in words) {
        if (craft.contains(word)) return category;
      }
    }
    return null;
  }

  /// Whether an RFQ for [rfqCraft] should be shown to an artisan whose profile
  /// says [artisanCraft].
  ///
  /// Compares resolved categories rather than raw strings. Two unresolvable
  /// crafts are only a match if their raw text agrees, so an uncategorised
  /// artisan does not receive every uncategorised request.
  static bool matches(String rfqCraft, String artisanCraft) {
    final String? a = categoryFor(rfqCraft);
    final String? b = categoryFor(artisanCraft);
    if (a != null && b != null) return a == b;
    return rfqCraft.trim().toLowerCase() == artisanCraft.trim().toLowerCase();
  }
}
