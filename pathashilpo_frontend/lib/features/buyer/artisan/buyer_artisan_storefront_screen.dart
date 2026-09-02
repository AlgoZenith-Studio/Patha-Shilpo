import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../data/models/artisan_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../product/buyer_product_detail_screen.dart';
import '../rfq/buyer_rfq_screen.dart';

class BuyerArtisanStorefrontScreen extends StatefulWidget {
  final ArtisanModel artisan;

  const BuyerArtisanStorefrontScreen({super.key, required this.artisan});

  @override
  State<BuyerArtisanStorefrontScreen> createState() =>
      _BuyerArtisanStorefrontScreenState();
}

class _BuyerArtisanStorefrontScreenState
    extends State<BuyerArtisanStorefrontScreen> {
  bool _isPlayingAudio = false;

  /// Subscribed once in initState rather than per build, so playing the audio
  /// story does not re-subscribe the Firestore listener.
  late final Stream<List<ProductModel>> _productStream =
      FirestoreService().streamArtisanProducts(widget.artisan.uid);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    // The artisan's story follows the language chosen in Settings,
    // so the screen never shows two scripts at once.
    final bool showHindiStory =
        Localizations.localeOf(context).languageCode == 'hi';
    final artisan = widget.artisan;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: StreamBuilder<List<ProductModel>>(
        stream: _productStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
          final List<ProductModel> artisanProducts =
              snapshot.data ?? const <ProductModel>[];
          return CustomScrollView(
            slivers: [
              // Artistic Header with Portrait & Cluster Cover
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.canvas,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.ink, size: 18),
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
                          color: Colors.white.withValues(alpha: 0.06),
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
                              backgroundColor: AppColors.heritage,
                              backgroundImage: artisan.photoUrl != null
                                  ? CachedNetworkImageProvider(
                                      artisan.photoUrl!)
                                  : null,
                              child: artisan.photoUrl == null
                                  ? const Icon(Icons.person,
                                      size: 40, color: AppColors.ink)
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
                                            color: AppColors.canvas,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (artisan.verified) ...[
                                        const SizedBox(width: 6),
                                        const Icon(Icons.verified,
                                            size: 18,
                                            color: AppColors.heritage),
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.heritage
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      artisan.craft,
                                      style: const TextStyle(
                                        fontFamily: 'Lora',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        color: AppColors.canvas,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              '${artisan.yearsOfPractice} Yrs',
                              t.buyerCraftHeritage,
                              Icons.history_edu_rounded,
                            ),
                            Container(
                                width: 1, height: 28, color: AppColors.border),
                            _buildStatItem(
                              '${artisan.productCount} Items',
                              t.buyerHandmadeLive,
                              Icons.inventory_2_outlined,
                            ),
                            Container(
                                width: 1, height: 28, color: AppColors.border),
                            _buildStatItem(
                              '${artisan.rating} ★',
                              t.buyerDirectFairRating,
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.auto_stories_outlined,
                                        color: AppColors.action, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      t.buyerArtisanHeritageStory,
                                      style: TextStyle(
                                        fontFamily: 'Pally',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              showHindiStory ? artisan.storyHi : artisan.story,
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.ink,
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
                                    backgroundColor: AppColors.ink,
                                    content: Text(
                                      _isPlayingAudio
                                          ? 'Playing spoken artisan narrative in rural dialect...'
                                          : t.buyerAudioPaused,
                                      style: const TextStyle(
                                          fontFamily: 'Lora',
                                          color: AppColors.canvas),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: AppColors.border
                                          .withValues(alpha: 0.8),
                                      width: 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.ink.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isPlayingAudio
                                          ? Icons.pause_circle_filled
                                          : Icons.play_circle_filled,
                                      color: AppColors.action,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isPlayingAudio
                                                ? t.buyerListeningVoiceNote
                                                : t.buyerListenVoiceNote,
                                            style: const TextStyle(
                                              fontFamily: 'Pally',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppColors.ink,
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
                              color: AppColors.ink,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuyerRfqScreen(
                                      prefilledCraft: artisan.craft),
                                ),
                              );
                            },
                            icon: const Icon(Icons.request_quote_outlined,
                                size: 16, color: AppColors.action),
                            label: Text(
                              t.buyerBulkRfq,
                              style: TextStyle(
                                fontFamily: 'Pally',
                                fontWeight: FontWeight.w700,
                                color: AppColors.action,
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
                        title: product.title,
                        titleHi: product.titleHi,
                        craftType: product.craftType,
                        price: product.priceFinal,
                        imageUrl: product.imageUrl.isEmpty
                            ? null
                            : CachedNetworkImageProvider(product.imageUrl),
                        onTap: () => _showProductQuickView(context, product),
                      );
                    },
                    childCount: artisanProducts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showProductQuickView(BuildContext context, ProductModel product) {
    final bool showHindi = Localizations.localeOf(context).languageCode == 'hi';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppShape.sheetRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 220,
                        color: AppColors.canvas,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.action,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 220,
                        color: AppColors.canvas,
                        child: const Center(
                          child: Icon(Icons.palette_outlined,
                              size: 50, color: AppColors.action),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.giTag != null && product.giTag!.isNotEmpty) ...[
                          ProvenanceTag(label: product.giTag!, verified: true),
                          const SizedBox(width: 6),
                        ],
                        ProvenanceTag(
                          label: product.artisanCluster,
                          icon: Icons.place_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showHindi ? product.titleHi : product.title,
                          style: const TextStyle(
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColors.ink,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_pin_circle_outlined,
                                size: 14, color: AppColors.action),
                            const SizedBox(width: 4),
                            Text(
                              product.artisanName,
                              style: const TextStyle(
                                fontFamily: 'Pally',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.green.shade300, width: 0.8),
                              ),
                              child: Text(
                                'Verified Maker',
                                style: TextStyle(
                                  fontFamily: 'Pally',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${product.priceFinal}',
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppColors.action,
                        ),
                      ),
                      Text(
                        '${product.hoursOfWork}h Handcrafted',
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                showHindi ? product.descriptionHi : product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BuyerProductDetailScreen(product: product),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.border, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Full Story & Specs',
                        style: TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BuyerProductDetailScreen(product: product),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'View Product',
                        style: TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.action,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.action),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Pally',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.ink,
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
