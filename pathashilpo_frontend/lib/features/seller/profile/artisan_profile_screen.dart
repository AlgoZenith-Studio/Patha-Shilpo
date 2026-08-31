import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../auth/controllers/auth_controller.dart';

/// The artisan's own profile — their story, cluster and provenance.
///
/// The story is not decoration: it travels with every listing and is what lets
/// a buyer tell handmade from machine-made (PRD.md §4).
class ArtisanProfileScreen extends StatelessWidget {
  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AuthController auth = context.watch<AuthController>();
    final LocaleProvider locale = context.watch<LocaleProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: <Widget>[
        Row(
          children: <Widget>[
            const CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.heritage,
              child: Icon(Icons.person_rounded, size: 36, color: AppColors.ink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Kamala Devi',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(auth.phone ?? '',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            const ProvenanceTag(
                label: 'Chanderi', icon: Icons.place_outlined),
            ProvenanceTag(label: t.profileGiTag, verified: true),
            ProvenanceTag(
              label: t.profileHandloom,
              icon: Icons.workspace_premium_outlined,
            ),
          ],
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
            border:
                Border.all(color: AppColors.border, width: AppShape.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(t.profileYourStory,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'I have woven Chanderi since I was twelve. My mother taught me, '
                'and her mother taught her.',
                style: AppTheme.story,
              ),
              const SizedBox(height: 10),
              Text(t.profileYearsOfPractice(28),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        const SizedBox(height: 24),
        // Language lives in Settings — one control for the whole app.
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.settings_rounded, color: AppColors.ink),
          title: Text(t.commonSettings,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text('${t.commonLanguage} · ${locale.displayName}',
              style: Theme.of(context).textTheme.bodySmall),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.pushNamed(context, Routes.settings),
        ),

        const Divider(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            context.read<AuthController>().signOut();
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.login, (_) => false);
          },
          icon: const Icon(Icons.logout_rounded),
          label: Text(t.commonSignOut),
        ),

        const SizedBox(height: 16),
        Text(t.commonSampleData,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
