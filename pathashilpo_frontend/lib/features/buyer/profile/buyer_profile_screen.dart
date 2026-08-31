import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../core/routing/route_names.dart';
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

  @override
  void initState() {
    super.initState();
    _buyer = MockBuyerData.currentBuyer;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final LocaleProvider localeProvider = context.watch<LocaleProvider>();
    final savedItems = MockBuyerData.products
        .where((p) => _buyer.savedProducts.contains(p.productId))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(t.buyerProfileTitle),
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
                    color: AppColors.ink.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.heritage,
                    child: Text(
                      _buyer.name.substring(0, 1),
                      style: const TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: AppColors.ink,
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
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppColors.canvas,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_buyer.company != null)
                          Text(
                            _buyer.company!,
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 12.5,
                              color: Color(0xFFF3E5D0),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.heritage.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.heritage.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            t.buyerRoleSourcing(_buyer.buyerType.toUpperCase()),
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.canvas,
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buyer Sourcing Details',
                    style: TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildProfileRow('Phone:', _buyer.phone),
                  if (_buyer.email != null) ...[
                    const SizedBox(height: 6),
                    _buildProfileRow(t.buyerEmailLabel, _buyer.email!),
                  ],
                  if (_buyer.gstin != null) ...[
                    const SizedBox(height: 6),
                    _buildProfileRow(t.buyerGstinVerified, _buyer.gstin!),
                  ],
                  const Divider(color: AppColors.border, height: 20),
                  const Text(
                    'Craft Interests:',
                    style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buyer.interests
                        .map(
                          (interest) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
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
                Flexible(
                  child: Text(
                    'Saved Masterpieces (${savedItems.length})',
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (savedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No saved items yet. Tap the heart icon on any craft to save it.',
                    style: TextStyle(fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
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
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
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
                                    fontFamily: 'Pally',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.ink,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '₹${item.priceFinal} • ${item.artisanCluster}',
                                  style: const TextStyle(fontFamily: 'Lora', fontSize: 12, color: AppColors.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.border),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Language & Regional Settings',
                    style: TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildLangChoice('English', 'en', localeProvider),
                      _buildLangChoice('हिंदी (Hindi)', 'hi', localeProvider),
                      _buildLangChoice('বাংলা (Bengali)', 'bn', localeProvider),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  // Artisan Onboarding & Registration
                  Text(
                    t.buyerSwitchRole,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Are you a rural craftsman or artisan? Complete artisan registration to list, price, and sell your handiwork.',
                    style: TextStyle(fontFamily: 'Lora', fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.artisanRegistration);
                      },
                      icon: const Icon(Icons.handyman_outlined, color: AppColors.action),
                      label: const Text(
                        'Become an Artisan Seller',
                        style: TextStyle(
                          fontFamily: 'Pally',
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.action, width: 1.5),
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
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLangChoice(String label, String code, LocaleProvider localeProvider) {
    final isSelected = localeProvider.locale.languageCode == code;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: isSelected ? 'Pally' : 'Lora',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
          color: isSelected ? AppColors.ink : AppColors.textMuted,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.heritage,
      backgroundColor: AppColors.canvas,
      side: BorderSide(color: isSelected ? AppColors.heritage : AppColors.border),
      onSelected: (val) {
        if (val) {
          context.read<LocaleProvider>().setLocale(Locale(code));
        }
      },
    );
  }
}
