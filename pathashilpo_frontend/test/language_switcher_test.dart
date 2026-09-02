import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/core/i18n/generated/app_localizations.dart';
import 'package:pathashilpa/core/i18n/locale_provider.dart';
import 'package:pathashilpa/core/theme/app_theme.dart';
import 'package:pathashilpa/core/widgets/language_switcher.dart';
import 'package:pathashilpa/data/local/session_box.dart';
import 'package:provider/provider.dart';

/// LocaleProvider persists through Hive, which is not open in a widget test.
/// Injecting this keeps the test about the widget rather than about storage.
class _MemorySessionBox implements SessionBox {
  String? _locale;
  String? _role;

  @override
  String? get locale => _locale;
  @override
  Future<void> setLocale(String languageCode) async => _locale = languageCode;
  @override
  String? get role => _role;
  @override
  Future<void> setRole(String role) async => _role = role;
  @override
  Future<void> clearRole() async => _role = null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Behaviour tests for [LanguageSwitcher].
///
/// NOTE ON THE RED SCREEN THIS DID NOT CAUSE: switching languages used to end
/// in a full-screen error, and the visible assertions were
/// "check that it really is our descendant"
/// (`InheritedElement.notifyClients`) and `_deactivateRecursively`. Both were
/// downstream noise. The device log held exactly one ROOT exception — an
/// ElevatedButton forced to infinite width in a Row on the RFQ screen (see
/// button_constraints_test.dart). Because BuyerShell hosts its tabs in an
/// IndexedStack, that broken screen was laid out even while invisible, and a
/// locale change re-lays out everything — which is why changing language was
/// what set it off.
///
/// The switcher still reads its active locale from `Localizations` rather than
/// watching `LocaleProvider`. The provider sits above `MaterialApp`, so a
/// dependency registered from inside a route crosses the boundary that the
/// locale change itself rebuilds. That was not the bug, but it is a hazard
/// worth not having; these tests pin the resulting behaviour.
void main() {
  /// Mirrors app.dart: provider above MaterialApp, switcher deep inside a
  /// route — and inside a LayoutBuilder, as both real screens have it.
  Widget app(LocaleProvider provider) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: provider,
      child: Consumer<LocaleProvider>(
        builder: (BuildContext context, LocaleProvider locale, _) => MaterialApp(
          theme: AppTheme.light,
          locale: locale.locale,
          supportedLocales: kSupportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Mirrors RoleSelectScreen / PhoneLoginScreen exactly: the switcher
          // sits under SafeArea > LayoutBuilder > SingleChildScrollView >
          // ConstrainedBox > IntrinsicHeight > Column, with Spacers. The
          // IntrinsicHeight speculative layout pass is part of the repro.
          home: Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) =>
                    SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const <Widget>[
                          LanguageSwitcher(),
                          Spacer(),
                          Text('body'),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('cycling en → hi → bn → en does not throw',
      (WidgetTester tester) async {
    final LocaleProvider provider = LocaleProvider(initial: const Locale('en'), session: _MemorySessionBox());
    await tester.pumpWidget(app(provider));

    for (final String code in <String>['hi', 'bn', 'en', 'bn', 'hi']) {
      await tester.tap(find.text(kLocaleNames[code]!));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Switching to "$code" threw.',
      );
      expect(provider.locale.languageCode, code);
    }
  });

  testWidgets('every supported language is offered, in its own script',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(LocaleProvider(initial: const Locale('en'), session: _MemorySessionBox())));

    // A Bengali speaker has to be able to find বাংলা without reading English.
    expect(find.text('English'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget);
  });

  testWidgets('the switcher reflects a locale changed from elsewhere',
      (WidgetTester tester) async {
    final LocaleProvider provider = LocaleProvider(initial: const Locale('en'), session: _MemorySessionBox());
    await tester.pumpWidget(app(provider));

    // e.g. the Settings screen changing it: the chips must still follow, which
    // is what reading from Localizations buys us.
    provider.setLocale(const Locale('bn'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      Localizations.localeOf(
        tester.element(find.byType(LanguageSwitcher)),
      ).languageCode,
      'bn',
    );
  });
}
