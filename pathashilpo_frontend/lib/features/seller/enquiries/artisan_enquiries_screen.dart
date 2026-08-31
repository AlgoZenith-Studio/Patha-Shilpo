import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';

/// Enquiries received on the artisan's own products (PRD.md FEAT-04).
///
/// These are created by the buyer shell, which a separate contributor owns.
/// This screen reads them; it does not create them.
class ArtisanEnquiriesScreen extends StatelessWidget {
  const ArtisanEnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: <Widget>[
        Text(t.enquiriesTitle,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),

        const _EnquiryCard(
          buyerName: 'Meera Textiles',
          product: 'Chanderi silk saree',
          quantity: 12,
          message: 'Do you have this in deeper blue? Needed by Diwali.',
        ),
        const SizedBox(height: 12),
        const _EnquiryCard(
          buyerName: 'Craft Export Co.',
          product: 'Bamboo storage basket',
          quantity: 200,
          message: 'Bulk order for export. Can you meet this quantity?',
        ),

        const SizedBox(height: 20),
        Text(t.commonSampleData,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  const _EnquiryCard({
    required this.buyerName,
    required this.product,
    required this.quantity,
    required this.message,
  });

  final String buyerName;
  final String product;
  final int quantity;
  final String message;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        border: Border.all(color: AppColors.border, width: AppShape.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(buyerName,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.heritage,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(t.enquiriesQuantity(quantity),
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
          ),
          Text(product, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(t.commonDecline),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(t.commonAccept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
