import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../data/mock/mock_buyer_data.dart';
import '../../../data/models/buyer_model.dart';
import '../product/buyer_product_detail_screen.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  late BuyerModel _buyer;
  String _selectedLocale = 'en';

  @override
  void initState() {
    super.initState();
    _buyer = MockBuyerData.currentBuyer;
  }

  @override
  Widget build(BuildContext context) {
    final savedItems = MockBuyerData.products
        .where((p) => _buyer.savedProducts.contains(p.productId))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvasLight,
      appBar: AppBar(
        title: const Text('Buyer Profile • प्रोफाइल'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buyer Identity Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.artisanHeroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepUmber.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.ochreGold,
                    child: Text(
                      _buyer.name.substring(0, 1),
                      style: const TextStyle(
                        fontFamily: 'Kalam',
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: AppColors.deepUmber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _buyer.name,
                          style: const TextStyle(
                            fontFamily: 'Kalam',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppColors.canvasParchment,
                          ),
                        ),
                        if (_buyer.company != null)
                          Text(
                            _buyer.company!,
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
                            border: Border.all(color: AppColors.ochreGold.withOpacity(0.6)),
                          ),
                          child: Text(
                            'ROLE: ${_buyer.buyerType.toUpperCase()} SOURCING',
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.canvasParchment,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sourcing Details / GSTIN
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
                  const Text(
                    'Buyer Sourcing Details',
                    style: TextStyle(
                      fontFamily: 'Kalam',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.deepUmber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildProfileRow('Phone:', _buyer.phone),
                  if (_buyer.email != null) ...[
                    const SizedBox(height: 6),
                    _buildProfileRow('Email:', _buyer.email!),
                  ],
                  if (_buyer.gstin != null) ...[
                    const SizedBox(height: 6),
                    _buildProfileRow('GSTIN Verified:', _buyer.gstin!),
                  ],
                  const Divider(color: AppColors.surfaceBorder, height: 20),
                  const Text(
                    'Craft Interests:',
                    style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.deepUmber),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _buyer.interests
                        .map(
                          (interest) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.canvasParchment,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(fontFamily: 'Lora', fontSize: 11.5, color: AppColors.deepUmber),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bookmarked Handcrafted Masterpieces
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Masterpieces (${savedItems.length})',
                  style: const TextStyle(
                    fontFamily: 'Kalam',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.deepUmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (savedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Center(
                  child: Text(
                    'No saved items yet. Tap the heart icon on any craft to save it.',
                    style: TextStyle(fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: savedItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = savedItems[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BuyerProductDetailScreen(product: item)),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontFamily: 'Kalam',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.deepUmber,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '₹${item.priceFinal} • ${item.artisanCluster}',
                                  style: const TextStyle(fontFamily: 'Lora', fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.sandstone),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Language & Role Switch Section
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
                  const Text(
                    'App Language & Regional Settings',
                    style: TextStyle(
                      fontFamily: 'Kalam',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.deepUmber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildLangChoice('English', 'en'),
                      const SizedBox(width: 8),
                      _buildLangChoice('हिंदी (Hindi)', 'hi'),
                      const SizedBox(width: 8),
                      _buildLangChoice('বাংলা (Bengali)', 'bn'),
                    ],
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 24),
                  // Role Switcher (MVP §1.5)
                  const Text(
                    'Switch Role • भूमिका बदलें',
                    style: TextStyle(
                      fontFamily: 'Kalam',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.deepUmber,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Are you a rural craftsman or artisan? Switch to Artisan Mode to list and price your handiwork.',
                    style: TextStyle(fontFamily: 'Lora', fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.deepUmber,
                            content: Text(
                              'Switching to Artisan Mode ("मैं बनाता/बनाती हूँ")...',
                              style: TextStyle(fontFamily: 'Lora', color: AppColors.canvasParchment),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.handyman_outlined, color: AppColors.deepUmber),
                      label: const Text(
                        'Switch to Artisan Mode • "मैं बनाता हूँ"',
                        style: TextStyle(
                          fontFamily: 'Kalam',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.deepUmber,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.terracottaClay, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted)),
        Text(
          value,
          style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.deepUmber),
        ),
      ],
    );
  }

  Widget _buildLangChoice(String label, String code) {
    final isSelected = _selectedLocale == code;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: isSelected ? 'Kalam' : 'Lora',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
          color: isSelected ? AppColors.deepUmber : AppColors.textMuted,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.ochreGold,
      backgroundColor: AppColors.canvasParchment,
      side: BorderSide(color: isSelected ? AppColors.ochreGold : AppColors.surfaceBorder),
      onSelected: (val) {
        if (val) setState(() => _selectedLocale = code);
      },
    );
  }
}
