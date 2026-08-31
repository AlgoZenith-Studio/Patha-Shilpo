import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/widgets/badges/sync_indicator.dart';
import '../../../core/widgets/cards/craft_card.dart';

/// The artisan's own product list — their inventory and its sync state.
class ArtisanProductsScreen extends StatelessWidget {
  const ArtisanProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: <Widget>[
        Text(t.productsTitle,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),

        const _ProductRow(
          title: 'Chanderi silk saree',
          price: 2850,
          state: SyncState.offlineProcessed,
          isDraft: true,
        ),
        const SizedBox(height: 12),
        const _ProductRow(
          title: 'Blue pottery vase',
          price: 950,
          state: SyncState.live,
        ),
        const SizedBox(height: 12),
        const _ProductRow(
          title: 'Bamboo storage basket',
          price: 480,
          state: SyncState.syncing,
        ),

        const SizedBox(height: 20),
        Text(t.commonSampleData,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.title,
    required this.price,
    required this.state,
    this.isDraft = false,
  });

  final String title;
  final int price;
  final SyncState state;
  final bool isDraft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 240,
          child: CraftCard(
            title: title,
            price: price,
            isOfflineDraft: isDraft,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 8),
        SyncIndicator(state: state),
      ],
    );
  }
}
