import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/sync_indicator.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../core/widgets/layout/artisan_shell.dart';
import '../../../data/models/product_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../enquiries/artisan_enquiries_screen.dart';
import '../rfq/artisan_rfq_screen.dart';
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
      onAddProduct: () =>
          Navigator.pushNamed(context, Routes.artisanAddProduct),
      child: switch (_index) {
        1 => const ArtisanProductsScreen(),
        2 => const _IncomingTab(),
        3 => const ArtisanProfileScreen(),
        _ => const _Dashboard(),
      },
    );
  }
}

/// The artisan's dashboard: their own crafts, live from Firestore.
///
/// The product grid used to be two hardcoded CraftCards ("Chanderi silk
/// saree", "Blue pottery vase") with a "sample data" caption and a fixed
/// sync badge, so it never reflected anything the artisan had actually done.
class _Dashboard extends StatefulWidget {
  const _Dashboard();

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  late final Stream<List<ProductModel>> _products =
      FirestoreService().streamArtisanProducts(
    context.read<AuthController>().currentUser?.uid ?? '__none__',
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return StreamBuilder<List<ProductModel>>(
      stream: _products,
      builder:
          (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
        final List<ProductModel> products =
            snapshot.data ?? const <ProductModel>[];

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
                // Reflects the real state: everything read back from Firestore
                // is, by definition, synced.
                if (products.isNotEmpty)
                  const SyncIndicator(state: SyncState.live),
              ],
            ),
            const SizedBox(height: 12),
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (products.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppShape.cardRadius),
                  border: Border.all(
                      color: AppColors.border, width: AppShape.hairline),
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.add_a_photo_outlined,
                        size: 40, color: AppColors.border),
                    const SizedBox(height: 10),
                    Text(t.productsEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(t.productsEmptyBody,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              )
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: <Widget>[
                  for (final ProductModel p in products)
                    CraftCard(
                      title: p.title,
                      titleHi: p.titleHi,
                      craftType: p.craftType,
                      price: p.priceFinal,
                      imageUrl: p.imageUrl.isEmpty
                          ? null
                          : CachedNetworkImageProvider(p.imageUrl),
                      onTap: () {},
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// Enquiries and bulk RFQs are both incoming buyer demand, so they share one
/// tab rather than adding a fifth item to the bottom bar - which would crowd
/// the 720x1280 target screen (TRD.md §3.4).
class _IncomingTab extends StatefulWidget {
  const _IncomingTab();

  @override
  State<_IncomingTab> createState() => _IncomingTabState();
}

class _IncomingTabState extends State<_IncomingTab> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: SegmentedButton<int>(
            segments: <ButtonSegment<int>>[
              ButtonSegment<int>(value: 0, label: Text(t.artisanTabEnquiries)),
              ButtonSegment<int>(value: 1, label: Text(t.artisanTabRfqs)),
            ],
            selected: <int>{_index},
            onSelectionChanged: (Set<int> v) =>
                setState(() => _index = v.first),
          ),
        ),
        Expanded(
          child: _index == 0
              ? const ArtisanEnquiriesScreen()
              : const ArtisanRfqScreen(),
        ),
      ],
    );
  }
}
