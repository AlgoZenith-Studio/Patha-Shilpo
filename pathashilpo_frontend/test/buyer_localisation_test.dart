import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/core/i18n/generated/app_localizations.dart';

/// Guards the "one language controls the whole app" rule on the buyer module.
///
/// The buyer screens were merged in with hardcoded English (and some strings
/// mixing two scripts, e.g. 'Sent Enquiries • पूछताछ'). These assertions stop
/// that regressing.
void main() {
  group('buyer localisation', () {
    test('every buyer key is translated in all three locales', () async {
      final AppLocalizations en =
          await AppLocalizations.delegate.load(const Locale('en'));
      final AppLocalizations hi =
          await AppLocalizations.delegate.load(const Locale('hi'));
      final AppLocalizations bn =
          await AppLocalizations.delegate.load(const Locale('bn'));

      final List<String Function(AppLocalizations)> probes =
          <String Function(AppLocalizations)>[
        (AppLocalizations l) => l.buyerTagline,
        (AppLocalizations l) => l.buyerFairTrade,
        (AppLocalizations l) => l.buyerBulkRfq,
        (AppLocalizations l) => l.buyerAllCrafts,
        (AppLocalizations l) => l.buyerSearchHint,
        (AppLocalizations l) => l.buyerResetFilters,
        (AppLocalizations l) => l.buyerQuantityRequired,
        (AppLocalizations l) => l.buyerSendEnquiry,
        (AppLocalizations l) => l.buyerDirectFairPrice,
        (AppLocalizations l) => l.buyerYourMessage,
        (AppLocalizations l) => l.buyerSentEnquiries,
        (AppLocalizations l) => l.buyerNoActiveRfqs,
        (AppLocalizations l) => l.buyerProfileTitle,
        (AppLocalizations l) => l.buyerSwitchRole,
        (AppLocalizations l) => l.buyerArtisanHeritageStory,
        (AppLocalizations l) => l.buyerViewStorefront,
      ];

      for (final String Function(AppLocalizations) probe in probes) {
        expect(probe(en), isNotEmpty);
        expect(probe(hi), isNotEmpty);
        expect(probe(bn), isNotEmpty);
        // A locale identical to English means the key silently fell back.
        expect(probe(hi), isNot(equals(probe(en))));
        expect(probe(bn), isNot(equals(probe(en))));
      }
    });

    test('no buyer string mixes Latin and Devanagari in one label', () async {
      final AppLocalizations en =
          await AppLocalizations.delegate.load(const Locale('en'));

      final List<String> englishStrings = <String>[
        en.buyerSentEnquiries,
        en.buyerSendEnquiry,
        en.buyerProfileTitle,
        en.buyerSwitchRole,
        en.buyerTagline,
        en.buyerBulkRfq,
      ];

      final RegExp devanagari = RegExp(r'[ऀ-ॿ]');
      for (final String s in englishStrings) {
        expect(
          devanagari.hasMatch(s),
          isFalse,
          reason: 'English string "$s" contains Devanagari - scripts must not mix',
        );
      }
    });
  });
}
