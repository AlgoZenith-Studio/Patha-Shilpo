import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/sync_indicator.dart';

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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(color: AppColors.border, width: AppShape.hairline),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_outlined, color: AppColors.border, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹$price',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.action,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                SyncIndicator(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
