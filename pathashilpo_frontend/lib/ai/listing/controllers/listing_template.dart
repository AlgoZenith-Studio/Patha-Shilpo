/// Output contract for the listing pipeline (TRD.md §7).
class ListingResult {
  const ListingResult({
    required this.title,
    required this.titleHi,
    required this.description,
    required this.descriptionHi,
    required this.tags,
    required this.colors,
    required this.material,
    required this.craftType,
    required this.generatedBy,
  });

  final String title;
  final String titleHi;
  final String description;
  final String descriptionHi;
  final List<String> tags;
  final List<String> colors;
  final String material;
  final String craftType;

  /// `gemini` when the backend produced it, `template` when this engine did.
  final String generatedBy;
}

/// Offline listing generation — keyword spotting plus template fill.
///
/// This is the Tier 3 fallback: no network, no model, no API key. It will never
/// write copy as good as Gemini, but it always produces a *usable* listing,
/// which is what keeps the promise that the artisan is never blocked
/// (mvp PIPELINE 3).
class ListingTemplate {
  const ListingTemplate();

  static const Map<String, String> _craftHi = <String, String>{
    'saree': 'साड़ी',
    'shawl': 'शॉल',
    'dupatta': 'दुपट्टा',
    'pottery': 'मिट्टी के बर्तन',
    'vase': 'फूलदान',
    'basket': 'टोकरी',
    'toy': 'खिलौना',
    'rug': 'कालीन',
    'jewellery': 'गहने',
  };

  static const Map<String, String> _materialHi = <String, String>{
    'silk': 'रेशम',
    'cotton': 'सूती',
    'wool': 'ऊन',
    'clay': 'मिट्टी',
    'brass': 'पीतल',
    'bamboo': 'बाँस',
    'jute': 'जूट',
    'wood': 'लकड़ी',
  };

  static const Map<String, String> _colorHi = <String, String>{
    'red': 'लाल',
    'blue': 'नीला',
    'green': 'हरा',
    'yellow': 'पीला',
    'black': 'काला',
    'white': 'सफ़ेद',
    'gold': 'सुनहरा',
    'pink': 'गुलाबी',
  };

  ListingResult generate({
    required String transcript,
    String? craftHint,
    int? hoursOfWork,
  }) {
    final String lower = transcript.toLowerCase();

    final String craft = craftHint?.trim().isNotEmpty == true
        ? craftHint!.trim().toLowerCase()
        : _spot(lower, _craftHi.keys) ?? 'handicraft';
    final String material = _spot(lower, _materialHi.keys) ?? '';
    final List<String> colors = _spotAll(lower, _colorHi.keys);

    final String craftLabel = _titleCase(craft);
    final String colorLabel = colors.isNotEmpty ? _titleCase(colors.first) : '';

    // "Chanderi saree in silk" — mvp PIPELINE 3 template shape.
    final String title = <String>[
      if (colorLabel.isNotEmpty) colorLabel,
      craftLabel,
      if (material.isNotEmpty) 'in ${_titleCase(material)}',
    ].join(' ');

    final String titleHi = <String>[
      if (colors.isNotEmpty) _colorHi[colors.first] ?? '',
      if (material.isNotEmpty) _materialHi[material] ?? '',
      _craftHi[craft] ?? craftLabel,
    ].where((String s) => s.isNotEmpty).join(' ');

    final StringBuffer desc = StringBuffer('Handmade $craftLabel');
    if (material.isNotEmpty) desc.write(' crafted from ${_titleCase(material)}');
    desc.write('.');
    if (hoursOfWork != null && hoursOfWork > 0) {
      desc.write(' Made over $hoursOfWork hours by a single artisan.');
    }
    if (transcript.trim().isNotEmpty) {
      desc.write(' In the maker\'s words: "${transcript.trim()}"');
    }

    final StringBuffer descHi = StringBuffer(
      '${_craftHi[craft] ?? craftLabel} हाथ से बनाया गया है',
    );
    if (material.isNotEmpty) {
      descHi.write(', ${_materialHi[material]} से');
    }
    descHi.write('।');
    if (hoursOfWork != null && hoursOfWork > 0) {
      descHi.write(' इसे बनाने में $hoursOfWork घंटे लगे।');
    }

    final List<String> tags = <String>{
      craft,
      if (material.isNotEmpty) material,
      ...colors,
      'handmade',
      'artisan',
      'handcrafted',
    }.take(8).toList();

    return ListingResult(
      title: _clamp(title, 70),
      titleHi: _clamp(titleHi, 70),
      description: _clamp(desc.toString(), 600),
      descriptionHi: _clamp(descHi.toString(), 600),
      tags: tags,
      colors: colors,
      material: material.isEmpty ? 'handcrafted material' : material,
      craftType: craft,
      generatedBy: 'template',
    );
  }

  static String? _spot(String haystack, Iterable<String> needles) {
    for (final String n in needles) {
      if (haystack.contains(n)) return n;
    }
    return null;
  }

  static List<String> _spotAll(String haystack, Iterable<String> needles) =>
      needles.where(haystack.contains).toList();

  static String _titleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _clamp(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max - 1)}…';
}
