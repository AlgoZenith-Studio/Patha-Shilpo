import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/core/constants/craft_taxonomy.dart';

void main() {
  group('CraftTaxonomy.categoryFor', () {
    test('passes canonical values through unchanged', () {
      for (final String category in CraftTaxonomy.categories) {
        expect(CraftTaxonomy.categoryFor(category), category);
      }
    });

    test('normalises the legacy artisan-registration labels', () {
      // These are the values CraftConstants.craftTypes wrote before the
      // taxonomy existed, and they still sit on real artisan documents.
      expect(CraftTaxonomy.categoryFor('Dhokra & Metalware'), 'Metal Casting');
      expect(
          CraftTaxonomy.categoryFor('Handloom & Textiles'), 'Handloom Weaving');
      expect(CraftTaxonomy.categoryFor('Terracotta & Pottery'),
          'Terracotta Pottery');
      expect(CraftTaxonomy.categoryFor('Woodcarving & Woodwork'),
          'Wood Carving');
      expect(CraftTaxonomy.categoryFor('Bamboo & Cane Craft'), 'Bamboo Craft');
    });

    test('normalises the free text on seeded artisan documents', () {
      expect(CraftTaxonomy.categoryFor('Dhokra Lost-Wax Metal Casting'),
          'Metal Casting');
      expect(CraftTaxonomy.categoryFor('Madhubani Mithila Painting'),
          'Folk Art Painting');
      expect(CraftTaxonomy.categoryFor('Retro Screen-print Poster Art'),
          'Folk Art Painting');
      expect(CraftTaxonomy.categoryFor('Chanderi Handloom Weaving'),
          'Handloom Weaving');
    });

    test('prefers the narrower category when keywords overlap', () {
      // 'Contemporary Watercolour' contains no 'paint', but 'Watercolour
      // Painting' does - the specific entry must still win over Folk Art.
      expect(CraftTaxonomy.categoryFor('Contemporary Watercolour'),
          'Contemporary Art');
      expect(CraftTaxonomy.categoryFor('Contemporary Watercolour Painting'),
          'Contemporary Art');
    });

    test('returns null rather than guessing for unknown crafts', () {
      expect(CraftTaxonomy.categoryFor('Glassblowing'), isNull);
      expect(CraftTaxonomy.categoryFor(''), isNull);
      expect(CraftTaxonomy.categoryFor(null), isNull);
    });

    test('is case and whitespace insensitive', () {
      expect(CraftTaxonomy.categoryFor('  METAL CASTING  '), 'Metal Casting');
    });
  });

  group('CraftTaxonomy.matches — the RFQ routing that was broken', () {
    test('a buyer category reaches an artisan whose craft is free text', () {
      // Before the taxonomy this compared raw strings and was always false,
      // so no buyer RFQ ever reached a single artisan.
      expect(
        CraftTaxonomy.matches('Metal Casting', 'Dhokra Lost-Wax Metal Casting'),
        isTrue,
      );
      expect(
        CraftTaxonomy.matches('Folk Art Painting', 'Madhubani Mithila Painting'),
        isTrue,
      );
    });

    test('a buyer category reaches an artisan on the legacy vocabulary', () {
      expect(CraftTaxonomy.matches('Metal Casting', 'Dhokra & Metalware'),
          isTrue);
      expect(CraftTaxonomy.matches('Handloom Weaving', 'Handloom & Textiles'),
          isTrue);
    });

    test('does not match across different crafts', () {
      expect(
        CraftTaxonomy.matches('Metal Casting', 'Madhubani Mithila Painting'),
        isFalse,
      );
      expect(
        CraftTaxonomy.matches('Handloom Weaving', 'Terracotta & Pottery'),
        isFalse,
      );
    });

    test('two uncategorised crafts only match on identical text', () {
      // An artisan the taxonomy cannot place must not receive every
      // unplaceable request.
      expect(CraftTaxonomy.matches('Glassblowing', 'Glassblowing'), isTrue);
      expect(CraftTaxonomy.matches('Glassblowing', 'Enamelling'), isFalse);
    });
  });

  group('CraftTaxonomy.filterOptions', () {
    test('leads with the all-crafts sentinel and keeps every category', () {
      expect(CraftTaxonomy.filterOptions.first, CraftTaxonomy.all);
      expect(
        CraftTaxonomy.filterOptions.sublist(1),
        CraftTaxonomy.categories,
      );
    });

    test('every seeded product craftType is a selectable filter', () {
      // The values seed_data.json writes to products.craftType. A mismatch
      // here means a seeded craft is unreachable from the explore chips.
      for (final String seeded in <String>[
        'Metal Casting',
        'Folk Art Painting',
        'Contemporary Art',
      ]) {
        expect(CraftTaxonomy.filterOptions, contains(seeded));
      }
    });
  });
}
