import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../ai/voice/views/on_device_voice_modal.dart';
import '../../../core/constants/craft_taxonomy.dart';
import '../../../data/models/product_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../product/buyer_product_detail_screen.dart';

class BuyerExploreScreen extends StatefulWidget {
  const BuyerExploreScreen({super.key});

  @override
  State<BuyerExploreScreen> createState() => _BuyerExploreScreenState();
}

class _BuyerExploreScreenState extends State<BuyerExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = CraftTaxonomy.all;
  bool _onlyGiTagged = false;
  String _sortBy = 'featured'; // featured | price_low | hours

  /// Held in a field, not built inside `build`: recreating the stream on every
  /// keystroke or filter tap would tear down and re-subscribe the Firestore
  /// listener each time. Search, category, GI and sort are all applied to the
  /// snapshot in [_applyFilters] instead, so one subscription serves them all.
  late Stream<List<ProductModel>> _productStream;

  @override
  void initState() {
    super.initState();
    _productStream = FirestoreService().streamLiveProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// A failed Firestore stream stays failed, so retrying means subscribing
  /// afresh rather than just rebuilding.
  void _reload() {
    setState(() {
      _productStream = FirestoreService().streamLiveProducts();
    });
  }

  List<ProductModel> _applyFilters(List<ProductModel> source) {
    return source.where((prod) {
      // Category filter
      // Compared as resolved categories so a product saved with a legacy craft
      // label still lands under the right chip.
      if (_selectedCategory != CraftTaxonomy.all &&
          CraftTaxonomy.categoryFor(prod.craftType) !=
              CraftTaxonomy.categoryFor(_selectedCategory)) {
        return false;
      }
      // GI Tag filter
      if (_onlyGiTagged && (prod.giTag == null || prod.giTag!.isEmpty)) {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = prod.title.toLowerCase().contains(query);
        final matchesTitleHi = prod.titleHi.toLowerCase().contains(query);
        final matchesArtisan = prod.artisanName.toLowerCase().contains(query);
        final matchesCluster =
            prod.artisanCluster.toLowerCase().contains(query);
        final matchesTags =
            prod.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchesTitle &&
            !matchesTitleHi &&
            !matchesArtisan &&
            !matchesCluster &&
            !matchesTags) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'price_low') {
          return a.priceFinal.compareTo(b.priceFinal);
        } else if (_sortBy == 'hours') {
          return b.hoursOfWork.compareTo(a.hoursOfWork);
        }
        return 0; // featured default order
      });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: StreamBuilder<List<ProductModel>>(
        stream: _productStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
          final List<ProductModel> products =
              _applyFilters(snapshot.data ?? const <ProductModel>[]);
          return CustomScrollView(
            slivers: [
              // Artistic Header Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.artisanHeroGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.heritage.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.heritage
                                      .withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(Icons.stars_rounded,
                                    size: 14, color: AppColors.canvas),
                                const SizedBox(width: 4),
                                Text(
                                  t.buyerDirectConnect,
                                  style: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.canvas,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.wb_sunny_outlined,
                              color: AppColors.heritage, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t.buyerHeritageTreasures,
                        style: TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: AppColors.canvas,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.buyerHeritageSubtitle,
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 13,
                          color: Color(0xFFF3E5D0),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar & Filter Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Search TextField
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.action.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_rounded,
                                color: AppColors.action,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                style: const TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 14,
                                  color: AppColors.ink,
                                ),
                                decoration: InputDecoration(
                                  hintText: t.buyerSearchHint,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Lora',
                                    fontSize: 13.5,
                                    color: AppColors.textMuted.withValues(alpha: 0.85),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.cancel_rounded,
                                    size: 18, color: AppColors.border),
                                tooltip: 'Clear Search',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.mic_rounded,
                                  size: 20, color: AppColors.action),
                              tooltip: 'Speak to Search (On-Device STT)',
                              onPressed: () async {
                                final spoken = await showOnDeviceVoiceModal(
                                  context,
                                  title: t.buyerSearchHint,
                                );
                                if (spoken != null && spoken.isNotEmpty) {
                                  _searchController.text = spoken;
                                  setState(() {
                                    _searchQuery = spoken;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Horizontal Category Pills
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: CraftTaxonomy.filterOptions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = CraftTaxonomy.filterOptions[index];
                            final isSelected = _selectedCategory == cat;

                            return ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  fontFamily: isSelected ? 'Pally' : 'Lora',
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                  color: isSelected
                                      ? AppColors.ink
                                      : AppColors.textMuted,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.heritage,
                              backgroundColor: AppColors.surface,
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.heritage
                                    : AppColors.border,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Filter Toggles & Sorters
                      Row(
                        children: [
                          Flexible(
                            child: FilterChip(
                              avatar: Icon(
                                _onlyGiTagged
                                    ? Icons.verified
                                    : Icons.verified_outlined,
                                size: 14,
                                color: _onlyGiTagged
                                    ? AppColors.giTagGreen
                                    : AppColors.textMuted,
                              ),
                              label: Text(
                                t.buyerGiTaggedOnly,
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _onlyGiTagged
                                      ? AppColors.giTagGreen
                                      : AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              selected: _onlyGiTagged,
                              selectedColor: AppColors.giTagBg,
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                color: _onlyGiTagged
                                    ? AppColors.giTagGreen
                                    : AppColors.border,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              onSelected: (val) {
                                setState(() {
                                  _onlyGiTagged = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sort Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                icon: const Icon(Icons.sort_rounded,
                                    size: 16, color: AppColors.ink),
                                style: const TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 12,
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: <DropdownMenuItem<String>>[
                                  DropdownMenuItem<String>(
                                      value: 'featured',
                                      child: Text(t.buyerCurated)),
                                  DropdownMenuItem<String>(
                                      value: 'price_low',
                                      child: Text(t.buyerPriceLowToHigh)),
                                  DropdownMenuItem<String>(
                                      value: 'hours',
                                      child: Text(t.buyerHoursOfCraftLabel)),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _sortBy = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Product Grid — the catalogue is remote now, so the grid has to
              // account for "still loading" and "the read failed" as well as
              // "nothing matched".
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const SliverToBoxAdapter(child: _CatalogueMessage.loading())
              else if (snapshot.hasError)
                SliverToBoxAdapter(
                  child: _CatalogueMessage(
                    icon: Icons.cloud_off_rounded,
                    title: 'Could Not Load the Catalogue',
                    body:
                        'Check your connection and try again. Saved drafts are '
                        'unaffected.',
                    actionLabel: 'Retry',
                    onAction: _reload,
                  ),
                )
              else if (products.isEmpty)
                SliverToBoxAdapter(
                  // An empty catalogue and an over-tight filter are different
                  // problems: only one of them is fixed by resetting filters.
                  child: (snapshot.data ?? const <ProductModel>[]).isEmpty
                      ? const _CatalogueMessage(
                          icon: Icons.storefront_outlined,
                          title: 'No Crafts Listed Yet',
                          body:
                              'The catalogue is empty. Once artisans publish their '
                              'work it will appear here.',
                        )
                      : _CatalogueMessage(
                          icon: Icons.search_off_rounded,
                          title: 'No Handcrafted Items Found',
                          body:
                              'Try clearing search filters or selecting another '
                              'craft category.',
                          actionLabel: t.buyerResetFilters,
                          onAction: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedCategory = CraftTaxonomy.all;
                              _onlyGiTagged = false;
                            });
                          },
                        ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return CraftCard(
                          title: product.title,
                          titleHi: product.titleHi,
                          craftType: product.craftType,
                          price: product.priceFinal,
                          // Cached so scrolling back up does not re-download, and
                          // so a craft photo survives going offline mid-session.
                          imageUrl: product.imageUrl.isEmpty
                              ? null
                              : CachedNetworkImageProvider(product.imageUrl),
                          onTap: () => _showProductQuickView(context, product),
                        );
                      },
                      childCount: products.length,
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
              // Top drag pill handle
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

              // Product Preview Hero Image & Badges
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
                  // Provenance Tag overlay
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

              // Title and Artisan Attribution
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
                  // Price Badge
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

              // Short Craft Description
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

              // Action Buttons
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
}

/// Full-width placeholder for the catalogue grid: loading, failed, or empty.
class _CatalogueMessage extends StatelessWidget {
  const _CatalogueMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  }) : isLoading = false;

  const _CatalogueMessage.loading()
      : icon = Icons.hourglass_empty,
        title = '',
        body = '',
        actionLabel = null,
        onAction = null,
        isLoading = true;

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.action)
            : Column(
                children: <Widget>[
                  Icon(icon, size: 48, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (actionLabel != null) ...<Widget>[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
