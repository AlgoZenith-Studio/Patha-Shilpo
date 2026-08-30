import 'package:flutter/material.dart';
import '../../../data/models/artisan_model.dart';
import '../../theme/colors.dart';

class ArtisanMiniCard extends StatelessWidget {
  final ArtisanModel artisan;
  final VoidCallback onViewStorefront;
  final VoidCallback? onListenStory;

  const ArtisanMiniCard({
    super.key,
    required this.artisan,
    required this.onViewStorefront,
    this.onListenStory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.canvasParchment.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Row(
        children: [
          // Artisan Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.ochreGold,
            backgroundImage: artisan.photoUrl != null ? NetworkImage(artisan.photoUrl!) : null,
            child: artisan.photoUrl == null
                ? const Icon(Icons.person, color: AppColors.deepUmber)
                : null,
          ),
          const SizedBox(width: 14),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        artisan.name,
                        style: const TextStyle(
                          fontFamily: 'Kalam',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.deepUmber,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (artisan.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 15,
                        color: AppColors.giTagGreen,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${artisan.village}, ${artisan.district} (${artisan.state})',
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${artisan.yearsOfPractice} years master experience • ${artisan.craft}',
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 11.5,
                    color: AppColors.terracottaClay,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Storefront button
          IconButton(
            onPressed: onViewStorefront,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            color: AppColors.deepUmber,
            tooltip: 'View Storefront',
          ),
        ],
      ),
    );
  }
}
