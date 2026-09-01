import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../data/models/artisan_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

/// The artisan's own profile — their real registered details, live from
/// Firestore.
///
/// The story is not decoration: it travels with every listing and is what lets
/// a buyer tell handmade from machine-made (PRD.md §4).
class ArtisanProfileScreen extends StatelessWidget {
  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AuthController auth = context.watch<AuthController>();
    final String? uid = auth.currentUser?.uid;

    if (uid == null) {
      return Center(
        child: Text(t.profileNotSignedIn,
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return StreamBuilder<ArtisanModel?>(
      stream: FirestoreService().streamArtisan(uid),
      builder: (BuildContext context, AsyncSnapshot<ArtisanModel?> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _Message(text: t.profileLoadFailed);
        }
        final ArtisanModel? artisan = snap.data;
        if (artisan == null) {
          return _Message(text: t.profileIncomplete);
        }
        return _ProfileBody(artisan: artisan, phone: auth.phone);
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.artisan, required this.phone});

  final ArtisanModel artisan;
  final String? phone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final LocaleProvider locale = context.watch<LocaleProvider>();
    final bool showHindi = Localizations.localeOf(context).languageCode == 'hi';

    final String displayName =
        showHindi && artisan.nameHi.isNotEmpty ? artisan.nameHi : artisan.name;
    final String displayStory =
        showHindi && artisan.storyHi.isNotEmpty ? artisan.storyHi : artisan.story;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: <Widget>[
        // ---- identity ----
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.heritage,
              backgroundImage: (artisan.photoUrl != null &&
                      artisan.photoUrl!.isNotEmpty)
                  ? NetworkImage(artisan.photoUrl!)
                  : null,
              child: (artisan.photoUrl == null || artisan.photoUrl!.isEmpty)
                  ? const Icon(Icons.person_rounded,
                      size: 36, color: AppColors.ink)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(displayName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (phone != null && phone!.isNotEmpty)
                    Text(phone!,
                        style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '${artisan.village}, ${artisan.district}, ${artisan.state}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),

        // ---- provenance, from real registration data ----
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (artisan.cluster.isNotEmpty)
              ProvenanceTag(
                  label: artisan.cluster, icon: Icons.place_outlined),
            if (artisan.craft.isNotEmpty)
              ProvenanceTag(
                label: artisan.craft,
                icon: Icons.workspace_premium_outlined,
              ),
            if (artisan.giTag != null && artisan.giTag!.isNotEmpty)
              ProvenanceTag(label: artisan.giTag!, verified: true),
            if (artisan.verified)
              ProvenanceTag(label: t.profileVerified, verified: true),
          ],
        ),

        // ---- story ----
        const SizedBox(height: 20),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(t.profileYourStory,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                displayStory.isNotEmpty ? displayStory : t.profileNoStoryYet,
                style: AppTheme.story,
              ),
              const SizedBox(height: 10),
              Text(t.profileYearsOfPractice(artisan.yearsOfPractice),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        // ---- at-a-glance stats ----
        const SizedBox(height: 12),
        _Card(
          child: Row(
            children: <Widget>[
              _Stat(
                label: t.profileProductsListed,
                value: '${artisan.productCount}',
              ),
              _Stat(
                label: t.profileRating,
                value: artisan.rating.toStringAsFixed(1),
              ),
            ],
          ),
        ),

        // ---- identity document status (never the number itself) ----
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(t.profileIdentity,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Icon(
                    artisan.idVerified
                        ? Icons.verified_rounded
                        : Icons.pending_outlined,
                    size: 18,
                    color: artisan.idVerified
                        ? AppColors.action
                        : AppColors.border,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _idLabel(t, artisan),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(t.profileIdentityNote,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        // ---- settings ----
        const SizedBox(height: 24),
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
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline_rounded, color: AppColors.ink),
          title: Text(t.infoTitle,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(t.infoSubtitle,
              style: Theme.of(context).textTheme.bodySmall),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.pushNamed(context, Routes.info),
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
      ],
    );
  }

  String _idLabel(AppLocalizations t, ArtisanModel a) {
    return switch (a.idType) {
      'gstin' => a.gstin != null && a.gstin!.isNotEmpty
          ? '${t.profileIdGstin} · ${a.gstin}'
          : t.profileIdGstin,
      'pan' => t.profileIdPan,
      'aadhaar' => t.profileIdAadhaar,
      _ => t.profileIdNone,
    };
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          border:
              Border.all(color: AppColors.border, width: AppShape.hairline),
        ),
        child: child,
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: <Widget>[
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}
