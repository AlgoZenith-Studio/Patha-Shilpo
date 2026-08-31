import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.ochreGold.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.balance_rounded,
            size: 13,
            color: AppColors.terracottaClay,
          ),
          const SizedBox(width: 4),
          Text(
            '₹$price',
            style: const TextStyle(
              fontFamily: 'Pally',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.deepUmber,
            ),
          ),
          if (showHours && hours > 0) ...[
            const SizedBox(width: 6),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sandstone,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${hours}h craft',
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
