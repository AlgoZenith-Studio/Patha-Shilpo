import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/colors.dart';

/// The explained fair-wage price band.
///
/// This card is the product's answer to "why should the artisan trust a number
/// an app gave them" — it shows the floor, the suggestion and the ceiling, and
/// states the reasoning in the selected language (PRD.md §11).
///
/// The floor is computed by the deterministic formula in TRD.md §17.3 and is
/// **identical online and offline**. It never moves after the artisan confirms.
class PriceBandCard extends StatelessWidget {
  const PriceBandCard({
    super.key,
    required this.floor,
    required this.suggested,
    required this.max,
    this.reasoning,
  });

  final int floor;
  final int suggested;
  final int max;
  final String? reasoning;

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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _PriceCell(label: t.priceFloor, value: floor),
              const SizedBox(width: 8),
              _PriceCell(
                label: t.priceSuggested,
                value: suggested,
                emphasised: true,
              ),
              const SizedBox(width: 8),
              _PriceCell(label: t.priceMaximum, value: max),
            ],
          ),
          if (reasoning != null) ...<Widget>[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(reasoning!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _PriceCell extends StatelessWidget {
  const _PriceCell({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final int value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: emphasised ? 4 : 3,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: emphasised ? AppColors.action : AppColors.canvas,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontFamily: AppTheme.bodyFont,
                fontFamilyFallback: AppTheme.scriptFallback,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: emphasised ? Colors.white : AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(
                '₹$value',
                style: TextStyle(
                  fontFamily: AppTheme.headingFont,
                  fontFamilyFallback: AppTheme.scriptFallback,
                  fontSize: emphasised ? 26 : 20,
                  fontWeight: FontWeight.w700,
                  color: emphasised ? Colors.white : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
