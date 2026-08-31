import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../data/mock/mock_buyer_data.dart';
import '../../../data/models/artisan_model.dart';
import '../product/buyer_product_detail_screen.dart';
import '../rfq/buyer_rfq_screen.dart';

class BuyerArtisanStorefrontScreen extends StatefulWidget {
  final ArtisanModel artisan;

  const BuyerArtisanStorefrontScreen({super.key, required this.artisan});

  @override
  State<BuyerArtisanStorefrontScreen> createState() => _BuyerArtisanStorefrontScreenState();
}

class _BuyerArtisanStorefrontScreenState extends State<BuyerArtisanStorefrontScreen> {
  bool _showHindiStory = false;
  bool _isPlayingAudio = false;

  @override
  Widget build(BuildContext context) {
    final artisan = widget.artisan;
    final artisanProducts = MockBuyerData.products
        .where((p) => p.artisanId == artisan.uid || p.artisanName == artisan.name)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      body: CustomScrollView(
        slivers: [
          // Artistic Header with Portrait & Cluster Cover
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.canvasLight,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.deepUmber, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.artisanHeroGradient,
                    ),
                  ),
                  // Decorative overlay
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.palette_outlined,
                      size: 160,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  // Content
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.ochreGold,
                          backgroundImage: artisan.photoUrl != null
                              ? NetworkImage(artisan.photoUrl!)
                              : null,
                          child: artisan.photoUrl == null
                              ? const Icon(Icons.person, size: 40, color: AppColors.deepUmber)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      artisan.name,
                                      style: const TextStyle(
                                        fontFamily: 'Pally',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        color: AppColors.canvasParchment,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (artisan.verified) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, size: 18, color: AppColors.ochreGold),
                                  ],
                                ],
                              ),
                              Text(
                                '${artisan.village}, ${artisan.district} • ${artisan.state}',
                                style: const TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 12.5,
                                  color: Color(0xFFF3E5D0),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.ochreGold.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  artisan.craft,
                                  style: const TextStyle(
                                    fontFamily: 'Lora',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: AppColors.canvasParchment,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artisan Bio & Audio Story
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provenance & Stats Strip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          '${artisan.yearsOfPractice} Yrs',
                          'Craft Heritage',
                          Icons.history_edu_rounded,
                        ),
                        Container(width: 1, height: 28, color: AppColors.surfaceBorder),
                        _buildStatItem(
                          '${artisan.productCount} Items',
                          'Handmade Live',
                          Icons.inventory_2_outlined,
                        ),
                        Container(width: 1, height: 28, color: AppColors.surfaceBorder),
                        _buildStatItem(
                          '${artisan.rating} ★',
                          'Direct Fair Rating',
                          Icons.star_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Heritage Story Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_stories_outlined, color: AppColors.terracottaClay, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'The Artisan\'s Heritage Story',
                                  style: TextStyle(
                                    fontFamily: 'Pally',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    color: AppColors.deepUmber,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showHindiStory = !_showHindiStory;
                                });
                              },
                              child: Text(
                                _showHindiStory ? 'English' : 'हिंदी',
                                style: const TextStyle(
                                  fontFamily: 'Pally',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.terracottaClay,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showHindiStory ? artisan.storyHi : artisan.story,
                          style: const TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.deepUmber,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Voice Story Player
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isPlayingAudio = !_isPlayingAudio;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.deepUmber,
                                content: Text(
                                  _isPlayingAudio
                                      ? 'Playing spoken artisan narrative in rural dialect...'
                                      : 'Paused artisan audio story.',
                                  style: const TextStyle(fontFamily: 'Lora', color: AppColors.canvasParchment),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.canvasParchment,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.ochreGold.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isPlayingAudio ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                  color: AppColors.terracottaClay,
                                  size: 26,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isPlayingAudio ? 'Listening to Spoken Voice Note' : 'Listen to Artisan\'s Voice Note',
                                        style: const TextStyle(
                                          fontFamily: 'Pally',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.deepUmber,
                                        ),
                                      ),
                                      const Text(
                                        'Spoken in regional dialect with English TTS fallback',
                                        style: TextStyle(
                                          fontFamily: 'Lora',
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Products Heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Master Collection (${artisanProducts.length})',
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: AppColors.deepUmber,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BuyerRfqScreen(prefilledCraft: artisan.craft),
                            ),
                          );
                        },
                        icon: const Icon(Icons.request_quote_outlined, size: 16, color: AppColors.terracottaClay),
                        label: const Text(
                          'Bulk RFQ',
                          style: TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            color: AppColors.terracottaClay,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Artisan's Products Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = artisanProducts[index];
                  return CraftCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerProductDetailScreen(product: product),
                        ),
                      );
                    },
                  );
                },
                childCount: artisanProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.terracottaClay),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Pally',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.deepUmber,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lora',
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
