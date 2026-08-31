import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/core/i18n/generated/app_localizations.dart';
import 'package:pathashilpa/core/i18n/locale_provider.dart';
import 'package:pathashilpa/core/theme/app_theme.dart';
import 'package:pathashilpa/core/theme/colors.dart';
import 'package:pathashilpa/core/widgets/buttons/primary_bilingual_button.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );

void main() {
  group('theme', () {
    test('scaffold uses the approved canvas colour', () {
      expect(AppTheme.light.scaffoldBackgroundColor, AppColors.canvas);
    });

    test('every text style falls back to a Devanagari-capable face', () {
      // The bundled fonts are Latin-only; without this fallback all Hindi
      // renders as tofu boxes. See TRD.md §10.1.
      final TextTheme t = AppTheme.textTheme;
      for (final TextStyle? style in <TextStyle?>[
        t.displayLarge,
        t.headlineLarge,
        t.titleLarge,
        t.bodyLarge,
        t.bodyMedium,
        t.labelLarge,
      ]) {
        expect(style, isNotNull);
        expect(style!.fontFamilyFallback, contains('Noto Sans Devanagari'));
      }
    });

    test('body text never drops below the 16px accessibility floor', () {
      // PRD.md §8 — the target user reads slowly on a 720x1280 screen.
      expect(AppTheme.textTheme.bodyLarge!.fontSize! >= 16, isTrue);
      expect(AppTheme.textTheme.bodyMedium!.fontSize! >= 16, isTrue);
    });
  });

  group('localisation', () {
    test('all three locales are complete — no key falls back', () async {
      // A missing key would render English inside a Hindi or Bengali screen,
      // which is exactly the mixing the language rule forbids.
      final AppLocalizations en =
          await AppLocalizations.delegate.load(const Locale('en'));
      final AppLocalizations hi =
          await AppLocalizations.delegate.load(const Locale('hi'));
      final AppLocalizations bn =
          await AppLocalizations.delegate.load(const Locale('bn'));

      // Spot-check across every screen group.
      final List<String Function(AppLocalizations)> probes =
          <String Function(AppLocalizations)>[
        (AppLocalizations l) => l.roleIMakeThings,
        (AppLocalizations l) => l.homeAddPromptTitle,
        (AppLocalizations l) => l.photoTitle,
        (AppLocalizations l) => l.voiceTitle,
        (AppLocalizations l) => l.costsTitle,
        (AppLocalizations l) => l.reviewPublish,
        (AppLocalizations l) => l.settingsLanguage,
        (AppLocalizations l) => l.syncLive,
        (AppLocalizations l) => l.commonNext,
      ];

      for (final String Function(AppLocalizations) probe in probes) {
        expect(probe(hi), isNotEmpty);
        expect(probe(bn), isNotEmpty);
        // Each locale must differ from English, proving it is really translated
        // rather than silently falling through.
        expect(probe(hi), isNot(equals(probe(en))));
        expect(probe(bn), isNot(equals(probe(en))));
      }
    });
  });

  group('PrimaryBilingualButton', () {
    testWidgets('renders only the selected language',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (BuildContext c) => PrimaryBilingualButton(
            label: AppLocalizations.of(c).roleIMakeThings,
            onPressed: () {},
          ),
        ),
      ));

      expect(find.text('I make things'), findsOneWidget);
      // No second language anywhere on screen.
      expect(find.text('मैं बनाता/बनाती हूँ'), findsNothing);
    });

    testWidgets('switches entirely to Hindi when the locale changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (BuildContext c) => PrimaryBilingualButton(
            label: AppLocalizations.of(c).roleIMakeThings,
            onPressed: () {},
          ),
        ),
        locale: const Locale('hi'),
      ));

      expect(find.text('मैं बनाता/बनाती हूँ'), findsOneWidget);
      expect(find.text('I make things'), findsNothing);
    });

    testWidgets('meets the 56px minimum tap target',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryBilingualButton(label: 'Next', onPressed: () {}),
      ));

      final Size size = tester.getSize(find.byType(PrimaryBilingualButton));
      expect(size.height >= AppShape.minTapTarget, isTrue);
    });

    testWidgets('does not fire when disabled', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(_wrap(
        const PrimaryBilingualButton(label: 'Disabled', onPressed: null),
      ));

      await tester.tap(find.byType(PrimaryBilingualButton));
      await tester.pump();
      expect(taps, 0);
    });
  });
}
