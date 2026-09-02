import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../i18n/locale_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// Compact English / हिन्दी / বাংলা selector for the pre-login screens.
///
/// Language is otherwise only reachable from Settings, which sits behind
/// sign-in and role selection - so a Hindi or Bengali speaker had to read three
/// English screens before they could switch. This puts the choice on the first
/// screens instead.
///
/// Each option is written **in its own script**, which is the one deliberate
/// exception to the app's single-language rule (see [LocaleProvider]): you
/// cannot pick বাংলা from a list that renders it as "Bengali". [kLocaleNames]
/// is the same source Settings uses, so the two can never drift apart.
///
/// Selecting persists through [LocaleProvider], so the choice survives the
/// rest of onboarding and every later launch.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key, this.compact = false});

  /// Tighter padding for use inside an AppBar or a dense header.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // The active locale is read from Localizations, NOT by watching
    // LocaleProvider.
    //
    // The provider sits ABOVE MaterialApp (see app.dart), so changing the
    // locale rebuilds the whole app, Navigator included. A widget down here
    // that had registered a dependency on the provider then gets notified
    // after its element has been reparented, and Flutter asserts
    // "check that it really is our descendant" in
    // InheritedElement.notifyClients — a red screen on the third language
    // switch. Localizations lives below MaterialApp and updates with it, so
    // depending on that instead keeps the dependency inside one subtree.
    final String active = Localizations.localeOf(context).languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final Locale locale in kSupportedLocales)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _LanguageChip(
              label: kLocaleNames[locale.languageCode]!,
              selected: locale.languageCode == active,
              compact: compact,
              // read, not watch: this must not create a dependency across the
              // MaterialApp boundary.
              onTap: () =>
                  context.read<LocaleProvider>().setLocale(locale),
            ),
          ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.heritage : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            // 44dp minimum height keeps every option inside the tap-target
            // floor the design system sets for low-literacy users.
            constraints: const BoxConstraints(minHeight: 44, minWidth: 64),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected ? AppColors.heritage : AppColors.border,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                // The three labels are Latin, Devanagari and Bengali; without
                // the fallback stack the non-Latin two render as tofu, since
                // the bundled display faces are Latin-only (TRD.md §10.1).
                fontFamilyFallback: AppTheme.scriptFallback,
                fontSize: compact ? 13 : 14.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.ink : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
