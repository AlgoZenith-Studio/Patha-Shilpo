import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/colors.dart';
import '../badges/offline_draft_badge.dart';

/// Product card for the artisan product list and the buyer explore grid.
///
/// DESIGN_SYSTEM.md §2A: white surface on the canvas, 18dp radius, 0.8dp
/// [AppColors.border] hairline, all text in [AppColors.ink].
class CraftCard extends StatelessWidget {
  const CraftCard({
    super.key,
    required this.title,
    this.titleHi,
    this.price,
    this.craftType,
    this.imageUrl,
    this.isOfflineDraft = false,
    this.onTap,
  });

  final String title;
  final String? titleHi;
  final int? price;
  final String? craftType;
  final ImageProvider? imageUrl;
  final bool isOfflineDraft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppShape.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppShape.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppShape.cardRadius),
            border: Border.all(
              color: AppColors.border,
              width: AppShape.hairline,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (imageUrl != null)
                      Image(image: imageUrl!, fit: BoxFit.cover)
                    else
                      Container(
                        color: AppColors.canvas,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppColors.border,
                        ),
                      ),
                    if (isOfflineDraft)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: OfflineDraftBadge(compact: true),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (titleHi != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        titleHi!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (craftType != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        craftType!,
                        style: TextStyle(
                          fontFamily: AppTheme.bodyFont,
                          fontFamilyFallback: AppTheme.scriptFallback,
                          fontSize: 13,
                          color: AppColors.border,
                        ),
                      ),
                    ],
                    if (price != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        '₹$price',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
