import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../theme/colors.dart';
import '../badges/provenance_tag.dart';
import '../badges/fair_price_chip.dart';

class CraftCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onEnquire;

  const CraftCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onEnquire,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepUmber.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with GI Tag overlay
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.canvasParchment,
                      child: const Center(
                        child: Icon(
                          Icons.palette_outlined,
                          size: 40,
                          color: AppColors.terracottaClay,
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.canvasParchment,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.ochreGold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: ProvenanceTag(
                    giTag: product.giTag,
                    cluster: product.artisanCluster,
                    compact: true,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.deepUmber.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.hoursOfWork}h',
                      style: const TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Artisan byline
                  Row(
                    children: [
                      const Icon(
                        Icons.person_pin_circle_outlined,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.artisanName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Product Title in Pally
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.2,
                      color: AppColors.deepUmber,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Price and direct action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FairPriceChip(
                          price: product.priceFinal,
                          hours: product.hoursOfWork,
                          showHours: false,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onEnquire ?? onTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: AppColors.warmOchreGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 11,
                                color: AppColors.deepUmber,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Connect',
                                style: TextStyle(
                                  fontFamily: 'Pally',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: AppColors.deepUmber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
