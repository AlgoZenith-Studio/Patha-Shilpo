import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/sync_indicator.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../core/widgets/layout/artisan_shell.dart';
import '../enquiries/artisan_enquiries_screen.dart';
import '../products/artisan_products_screen.dart';
import '../profile/artisan_profile_screen.dart';

/// The artisan shell host — owns the bottom-nav index and hosts each tab.
class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ArtisanShell(
      currentIndex: _index,
      onDestinationSelected: (int i) => setState(() => _index = i),
      onAddProduct: () => Navigator.pushNamed(context, Routes.artisanAddProduct),
      child: switch (_index) {
        1 => const ArtisanProductsScreen(),
        2 => const ArtisanEnquiriesScreen(),
        3 => const ArtisanProfileScreen(),
        _ => const _Dashboard(),
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: <Widget>[
        Text(t.homeGreeting,
            style: Theme.of(context).textTheme.displayMedium),
        Text(t.homeWelcome, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.action,
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                t.homeAddPromptTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                t.homeAddPromptBody,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.canvas),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(t.homeYourProducts,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SyncIndicator(state: SyncState.offlineProcessed),
          ],
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.66,
          children: <Widget>[
            CraftCard(
              title: 'Chanderi silk saree',
              craftType: 'Handloom',
              price: 2850,
              isOfflineDraft: true,
              onTap: () {},
            ),
            CraftCard(
              title: 'Blue pottery vase',
              craftType: 'Pottery',
              price: 950,
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 16),
        Text(t.commonSampleData,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
