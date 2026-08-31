import 'package:flutter/material.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../core/widgets/cards/artisan_mini_card.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../data/mock/mock_buyer_data.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/enquiry_model.dart';
import '../artisan/buyer_artisan_storefront_screen.dart';
import '../rfq/buyer_rfq_screen.dart';

class BuyerProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const BuyerProductDetailScreen({super.key, required this.product});

  @override
  State<BuyerProductDetailScreen> createState() => _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = MockBuyerData.currentBuyer.savedProducts.contains(widget.product.productId);
  }

  void _openEnquiryModal() {
    final AppLocalizations t = AppLocalizations.of(context);
    int quantity = 1;
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.mark_chat_unread_outlined, color: AppColors.action),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.buyerDirectEnquiryTo(widget.product.artisanName),
                            style: const TextStyle(
                              fontFamily: 'Pally',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.ink,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.buyerEnquiryNote,
                      style: TextStyle(fontFamily: 'Lora', fontSize: 12.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    // Quantity selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.buyerQuantityRequired,
                          style: TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.ink,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16, color: AppColors.ink),
                                onPressed: quantity > 1
                                    ? () => setModalState(() => quantity--)
                                    : null,
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontFamily: 'Pally',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.ink,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16, color: AppColors.ink),
                                onPressed: () => setModalState(() => quantity++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Message Field
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: const TextStyle(fontFamily: 'Lora', fontSize: 14, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: t.buyerEnquiryHint,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.heritage,
                        ),
                        icon: const Icon(Icons.send_rounded, color: AppColors.ink),
                        label: Text(
                          t.buyerSendEnquiry,
                          style: TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                        ),
                        onPressed: () {
                          final newEnquiry = EnquiryModel(
                            enquiryId: 'enq_${DateTime.now().millisecondsSinceEpoch}',
                            productId: widget.product.productId,
                            productTitle: widget.product.title,
                            productImageUrl: widget.product.imageUrl,
                            artisanId: widget.product.artisanId,
                            artisanName: widget.product.artisanName,
                            buyerUid: MockBuyerData.currentBuyer.uid,
                            buyerName: MockBuyerData.currentBuyer.name,
                            buyerPhone: MockBuyerData.currentBuyer.phone,
                            buyerType: MockBuyerData.currentBuyer.buyerType,
                            quantity: quantity,
                            message: messageController.text.isNotEmpty
                                ? messageController.text
                                : 'Interested in purchasing $quantity piece(s) of ${widget.product.title}.',
                            status: 'new',
                            createdAt: DateTime.now(),
                          );
                          MockBuyerData.initialEnquiries.insert(0, newEnquiry);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.ink,
                              content: Text(
                                'Enquiry sent directly to artisan! View in "Sent Enquiries" tab.',
                                style: TextStyle(fontFamily: 'Lora', color: AppColors.canvas),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    // Product copy follows the language chosen in Settings - there is no
    // separate per-screen toggle, so the app never mixes scripts.
    final bool showHindi =
        Localizations.localeOf(context).languageCode == 'hi';
    final product = widget.product;
    final artisan = MockBuyerData.artisans.firstWhere(
      (a) => a.uid == product.artisanId,
      orElse: () => MockBuyerData.artisans.first,
    );
    final similarProducts = MockBuyerData.products
        .where((p) => p.productId != product.productId && (p.craftType == product.craftType || p.artisanCluster == product.artisanCluster))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar with Back & Save Button
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.canvas,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.ink, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSaved ? Icons.favorite : Icons.favorite_border,
                    color: _isSaved ? AppColors.vermillionAccent : AppColors.ink,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isSaved = !_isSaved;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppColors.ink,
                      content: Text(
                        _isSaved ? t.buyerSavedToBookmarks : t.buyerRemovedFromSaved,
                        style: const TextStyle(fontFamily: 'Lora', color: AppColors.canvas),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.canvas,
                      child: const Center(
                        child: Icon(Icons.palette_outlined, size: 60, color: AppColors.action),
                      ),
                    ),
                  ),
                  // Dark gradient bottom overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.ink.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Provenance Tag on image
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // giTag is nullable - not every craft carries one.
                        if (product.giTag != null) ...<Widget>[
                          ProvenanceTag(label: product.giTag!, verified: true),
                          const SizedBox(width: 8),
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
            ),
          ),

          // Main Details & Story Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Language Switcher
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          showHindi ? product.titleHi : product.title,
                          style: const TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            height: 1.25,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Artisan Mini Card with Storefront Navigation
                  ArtisanMiniCard(
                    artisan: artisan,
                    onViewStorefront: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerArtisanStorefrontScreen(artisan: artisan),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Material, Technique & Craft specs chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSpecPill(Icons.category_outlined, product.craftType),
                      _buildSpecPill(Icons.texture_outlined, product.material),
                      _buildSpecPill(Icons.timer_outlined, t.buyerHoursOfCraftCount(product.hoursOfWork)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Story / Description
                  const Text(
                    'Craft Story & Provenance',
                    style: TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    showHindi ? product.descriptionHi : product.description,
                    style: const TextStyle(
                      fontFamily: 'Lora',
                      fontSize: 14.5,
                      height: 1.6,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FAIR PRICE TRANSPARENCY BREAKDOWN (Core USP)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.heritage.withValues(alpha: 0.6), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.heritage.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AppColors.action, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Fair Wage Transparency Breakdown',
                                style: TextStyle(
                                  fontFamily: 'Pally',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                  color: AppColors.ink,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.giTagBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.buyer100Direct,
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.giTagGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPriceRow(t.buyerMaterialCost, '₹${product.materialCost}'),
                        const SizedBox(height: 6),
                        _buildPriceRow(
                          'Fair Artisan Wage (${product.hoursOfWork}h @ ₹150/hr):',
                          '₹${product.hoursOfWork * 150}',
                        ),
                        const SizedBox(height: 6),
                        _buildPriceRow(t.buyerPackagingOverhead, '₹${product.priceFloor - product.materialCost - (product.hoursOfWork * 150) > 0 ? product.priceFloor - product.materialCost - (product.hoursOfWork * 150) : 350}'),
                        const Divider(color: AppColors.border, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                t.buyerDirectFairPrice,
                                style: TextStyle(
                                  fontFamily: 'Pally',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${product.priceFinal}',
                              style: const TextStyle(
                                fontFamily: 'Pally',
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          showHindi ? product.priceReasoningHi : product.priceReasoning,
                          style: const TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons (Direct Connect & Bulk Custom RFQ)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: _openEnquiryModal,
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.ink),
                          label: const Text(
                            'Send Enquiry',
                            style: TextStyle(
                              fontFamily: 'Pally',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.ink,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.heritage,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BuyerRfqScreen(prefilledCraft: product.craftType),
                              ),
                            );
                          },
                          icon: const Icon(Icons.request_quote_outlined, color: AppColors.ink, size: 18),
                          label: Text(
                            t.buyerBulkRfq,
                            style: TextStyle(
                              fontFamily: 'Pally',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.ink,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.action, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Similar Works from same cluster
                  if (similarProducts.isNotEmpty) ...[
                    Text(
                      t.buyerMoreFromCluster,
                      style: TextStyle(
                        fontFamily: 'Pally',
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          // Similar products horizontal list or grid
          if (similarProducts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = similarProducts[index];
                    return CraftCard(
                      title: p.title,
                      titleHi: p.titleHi,
                      craftType: p.craftType,
                      price: p.priceFinal,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuyerProductDetailScreen(product: p),
                          ),
                        );
                      },
                    );
                  },
                  childCount: similarProducts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.action),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Lora',
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Lora',
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
