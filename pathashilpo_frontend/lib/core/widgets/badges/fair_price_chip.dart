import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../theme/colors.dart';

class FairPriceChip extends StatelessWidget {
  final int price;
  final int hours;
  final bool showHours;

  const FairPriceChip({
    super.key,
    required this.price,
    required this.hours,
    this.showHours = true,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.heritage.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.balance_rounded,
            size: 13,
            color: AppColors.action,
          ),
          const SizedBox(width: 4),
          Text(
            '₹$price',
            style: const TextStyle(
              fontFamily: 'Pally',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.ink,
            ),
          ),
          if (showHours && hours > 0) ...[
            const SizedBox(width: 6),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.border,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              t.buyerHoursCraft(hours),
              style: const TextStyle(
                fontFamily: 'Lora',
                fontSize: 11.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
