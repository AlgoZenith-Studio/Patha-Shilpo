import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../data/mock/mock_buyer_data.dart';
import '../../../data/models/product_model.dart';
import '../product/buyer_product_detail_screen.dart';

class BuyerExploreScreen extends StatefulWidget {
  const BuyerExploreScreen({super.key});

  @override
  State<BuyerExploreScreen> createState() => _BuyerExploreScreenState();
}

class _BuyerExploreScreenState extends State<BuyerExploreScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All Crafts';
  bool _onlyGiTagged = false;
  String _sortBy = 'featured'; // featured | price_low | hours

  List<ProductModel> get _filteredProducts {
    return MockBuyerData.products.where((prod) {
      // Category filter
      if (_selectedCategory != 'All Crafts' && prod.craftType != _selectedCategory) {
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
        final matchesCluster = prod.artisanCluster.toLowerCase().contains(query);
        final matchesTags = prod.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchesTitle && !matchesTitleHi && !matchesArtisan && !matchesCluster && !matchesTags) {
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
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.heritage.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.heritage.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.stars_rounded, size: 14, color: AppColors.canvas),
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
                      const Icon(Icons.wb_sunny_outlined, color: AppColors.heritage, size: 20),
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
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
                        prefixIcon: const Icon(Icons.search, color: AppColors.action),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.border),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Category Pills
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: MockBuyerData.craftCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = MockBuyerData.craftCategories[index];
                        final isSelected = _selectedCategory == cat;

                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: isSelected ? 'Pally' : 'Lora',
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                              color: isSelected ? AppColors.ink : AppColors.textMuted,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.heritage,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.heritage : AppColors.border,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      FilterChip(
                        avatar: Icon(
                          _onlyGiTagged ? Icons.verified : Icons.verified_outlined,
                          size: 14,
                          color: _onlyGiTagged ? AppColors.giTagGreen : AppColors.textMuted,
                        ),
                        label: Text(
                          t.buyerGiTaggedOnly,
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _onlyGiTagged ? AppColors.giTagGreen : AppColors.textMuted,
                          ),
                        ),
                        selected: _onlyGiTagged,
                        selectedColor: AppColors.giTagBg,
                        backgroundColor: Colors.transparent,
                        side: BorderSide(
                          color: _onlyGiTagged ? AppColors.giTagGreen : AppColors.border,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onSelected: (val) {
                          setState(() {
                            _onlyGiTagged = val;
                          });
                        },
                      ),
                      const Spacer(),
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
                            icon: const Icon(Icons.sort_rounded, size: 16, color: AppColors.ink),
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

          // Product Grid
          if (products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: AppColors.border),
                      const SizedBox(height: 12),
                      const Text(
                        'No Handcrafted Items Found',
                        style: TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try clearing search filters or selecting another craft category.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedCategory = 'All Crafts';
                            _onlyGiTagged = false;
                          });
                        },
                        child: Text(t.buyerResetFilters),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
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
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
