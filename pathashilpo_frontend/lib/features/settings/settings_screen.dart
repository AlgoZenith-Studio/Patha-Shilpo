import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/generated/app_localizations.dart';
import '../../core/i18n/locale_provider.dart';
import '../../core/theme/colors.dart';

/// Settings — the single place the app's language is chosen.
///
/// Changing it here re-renders every screen in the selected language. Nothing
/// in the app displays a second language alongside it.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    // Read from Localizations, not by watching LocaleProvider: the provider
    // lives above MaterialApp, so a dependency registered here is torn down
    // by the very rebuild it triggers. See LanguageSwitcher for the full
    // explanation of the assertion that caused.
    final String activeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: <Widget>[
          Text(t.settingsLanguage,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(t.settingsLanguageBody,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppShape.cardRadius),
              border: Border.all(
                color: AppColors.border,
                width: AppShape.hairline,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: RadioGroup<String>(
              groupValue: activeCode,
              onChanged: (String? code) {
                if (code != null) {
                  context.read<LocaleProvider>().setLocale(Locale(code));
                }
              },
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < kSupportedLocales.length; i++) ...<Widget>[
                    if (i > 0) const Divider(height: 1),
                    RadioListTile<String>(
                      value: kSupportedLocales[i].languageCode,
                      activeColor: AppColors.action,
                      title: Text(
                        kLocaleNames[kSupportedLocales[i].languageCode]!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text(t.settingsAbout,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(t.appName, style: Theme.of(context).textTheme.titleMedium),
          Text(t.appTagline, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(t.settingsVersion('1.0.0'),
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
