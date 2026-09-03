import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the project's single-language rule (see `LocaleProvider`):
/// when a language is selected, the whole app renders in **that** language.
///
/// The rule kept being broken in two ways, both of which these tests catch:
///
///  1. A single label containing two languages, e.g. the artisan registration
///     banner `'आवाज़ से निर्देश सुनें / Listen to Instructions'` and the buyer
///     RFQ button `'Broadcast RFQ to Artisans • कोटेशन मंगाएं'`. A Bengali user
///     saw Hindi *and* English on one line.
///  2. A Hindi or Bengali translation with English left inside it.
///
/// A few tokens are genuinely language-neutral and are allowed everywhere:
/// the brand name, GI registration codes, and the government scheme acronyms
/// that have no Indic form in common use.
void main() {
  final Directory l10n = Directory('lib/core/i18n/l10n');

  /// Proper nouns and identifiers that stay Latin in every language.
  const List<String> allowedLatin = <String>[
    'Patha-Shilpo',
    'Pathashilpa',
    'GeM',
    'ONDC',
    'GI',
    'GSTIN',
    'PAN',
    'UPI',
    'SMS',
    'OTP',
    'AI',
  ];

  Map<String, String> readArb(String code) {
    final File f = File('${l10n.path}/app_$code.arb');
    final Map<String, dynamic> raw =
        jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    return <String, String>{
      for (final MapEntry<String, dynamic> e in raw.entries)
        if (!e.key.startsWith('@') && e.value is String)
          e.key: e.value as String,
    };
  }

  /// Strips placeholders and allow-listed proper nouns before looking for
  /// leftover Latin script.
  String residue(String value) {
    String s = value.replaceAll(RegExp(r'\{\w+\}'), ' ');
    for (final String token in allowedLatin) {
      s = s.replaceAll(token, ' ');
    }
    return s;
  }

  test('every locale defines exactly the same keys', () {
    final Set<String> en = readArb('en').keys.toSet();
    final Set<String> hi = readArb('hi').keys.toSet();
    final Set<String> bn = readArb('bn').keys.toSet();

    expect(hi.difference(en), isEmpty, reason: 'hi has keys en does not');
    expect(en.difference(hi), isEmpty, reason: 'hi is missing keys from en');
    expect(bn.difference(en), isEmpty, reason: 'bn has keys en does not');
    expect(en.difference(bn), isEmpty, reason: 'bn is missing keys from en');
  });

  for (final String code in <String>['hi', 'bn']) {
    test('$code translations contain no leftover English', () {
      final Map<String, String> table = readArb(code);
      final List<String> offenders = <String>[];

      table.forEach((String key, String value) {
        // Three or more consecutive Latin letters is a word, not a symbol.
        if (RegExp(r'[A-Za-z]{3,}').hasMatch(residue(value))) {
          offenders.add('$key -> $value');
        }
      });

      expect(
        offenders,
        isEmpty,
        reason: 'These $code strings still contain English. Selecting $code '
            'must not surface English text:\n${offenders.join("\n")}',
      );
    });
  }

  test('no single string mixes Latin with Devanagari or Bengali', () {
    final RegExp indic = RegExp(r'[ऀ-ॿঀ-৿]');
    final List<String> offenders = <String>[];

    for (final String code in <String>['en', 'hi', 'bn']) {
      readArb(code).forEach((String key, String value) {
        final String r = residue(value);
        if (indic.hasMatch(r) && RegExp(r'[A-Za-z]{3,}').hasMatch(r)) {
          offenders.add('[$code] $key -> $value');
        }
      });
    }

    expect(
      offenders,
      isEmpty,
      reason: 'One label must never carry two languages:\n'
          '${offenders.join("\n")}',
    );
  });
}
