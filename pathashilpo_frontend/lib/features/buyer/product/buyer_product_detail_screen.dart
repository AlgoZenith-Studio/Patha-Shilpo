import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../core/widgets/cards/artisan_mini_card.dart';
import '../../../core/widgets/cards/craft_card.dart';
import '../../../data/models/artisan_model.dart';
import '../../../data/models/buyer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/enquiry_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../artisan/buyer_artisan_storefront_screen.dart';
import '../rfq/buyer_rfq_screen.dart';

class BuyerProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const BuyerProductDetailScreen({super.key, required this.product});

  @override
  State<BuyerProductDetailScreen> createState() =>
      _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  bool _isSaved = false;

  /// Null until the artisan document arrives, or permanently if this product
  /// references an artisan that no longer exists. The maker panel is hidden in
  /// that case rather than showing someone else's name, which is what the old
  /// `orElse: () => artisans.first` fallback did.
  ArtisanModel? _artisan;

  /// Other live crafts from the same craft type or cluster. Read once - this
  /// panel is a browsing aid, not something that needs a live subscription.
  List<ProductModel> _similarProducts = const <ProductModel>[];

  /// The signed-in buyer, needed to attribute an enquiry and to know whether
  /// this craft is already saved. Null while loading, or when a signed-out
  /// visitor is browsing the catalogue.
  BuyerModel? _buyer;

  final FirestoreService _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadCatalogueContext();
  }

  Future<void> _loadCatalogueContext() async {
    final ProductModel product = widget.product;
    final String? uid = context.read<AuthController>().currentUser?.uid;
    try {
      final results = await Future.wait(<Future<Object?>>[
        _firestore.getArtisan(product.artisanId),
        _firestore.fetchLiveProducts(),
        if (uid != null) _firestore.getBuyer(uid) else Future<Object?>.value(),
      ]);
      if (!mounted) return;
      setState(() {
        _artisan = results[0] as ArtisanModel?;
        _similarProducts = (results[1] as List<ProductModel>)
            .where((ProductModel p) =>
                p.localId != product.localId &&
                (p.craftType == product.craftType ||
                    p.artisanCluster == product.artisanCluster))
            .toList();
        _buyer = results[2] as BuyerModel?;
        _isSaved = _buyer?.savedProducts.contains(product.productId) ?? false;
      });
    } catch (_) {
      // Non-fatal: the product itself is already in hand, so the page still
      // renders. Only the maker panel and "more like this" rail stay hidden.
      if (!mounted) return;
      setState(() => _similarProducts = const <ProductModel>[]);
    }
  }

  /// Persists the heart toggle. The icon flips immediately so the tap feels
  /// instant, and reverts if the write fails - previously this was local-only
  /// state that silently vanished when the screen was popped.
  Future<void> _toggleSaved() async {
    final AppLocalizations t = AppLocalizations.of(context);
    final BuyerModel? buyer = _buyer;
    final bool next = !_isSaved;
    setState(() => _isSaved = next);

    if (buyer == null) {
      // Signed-out or profile not loaded: nowhere to persist it.
      setState(() => _isSaved = false);
      _toast('Sign in to save crafts.');
      return;
    }

    try {
      await _firestore.setProductSaved(
        buyerUid: buyer.uid,
        productId: widget.product.productId,
        saved: next,
      );
      if (!mounted) return;
      _toast(next ? t.buyerSavedToBookmarks : t.buyerRemovedFromSaved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaved = !next);
      _toast('Could not update your saved crafts. Check your connection.');
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.ink,
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Lora', color: AppColors.canvas),
        ),
      ),
    );
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
              decoration: BoxDecoration(
                color: AppColors.canvas,
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
              child: SingleChildScrollView(
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.mark_chat_unread_outlined,
                            color: AppColors.action),
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
                      style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 12.5,
                          color: AppColors.textMuted),
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    size: 16, color: AppColors.ink),
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
                                icon: const Icon(Icons.add,
                                    size: 16, color: AppColors.ink),
                                onPressed: () =>
                                    setModalState(() => quantity++),
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
                      style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 14,
                          color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: t.buyerEnquiryHint,
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.action, width: 1.4),
                        ),
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
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded,
                            color: AppColors.ink),
                        label: Text(
                          t.buyerSendEnquiry,
                          style: TextStyle(
                            fontFamily: 'Pally',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                        ),
                        onPressed: () async {
                          final BuyerModel? buyer = _buyer;
                          if (buyer == null) {
                            Navigator.pop(ctx);
                            _toast('Sign in as a buyer to send an enquiry.');
                            return;
                          }

                          final newEnquiry = EnquiryModel(
                            enquiryId: '',
                            productId: widget.product.productId,
                            productTitle: widget.product.title,
                            productImageUrl: widget.product.imageUrl,
                            artisanId: widget.product.artisanId,
                            artisanName: widget.product.artisanName,
                            buyerUid: buyer.uid,
                            buyerName: buyer.name,
                            buyerPhone: buyer.phone,
                            buyerType: buyer.buyerType,
                            quantity: quantity,
                            message: messageController.text.isNotEmpty
                                ? messageController.text
                                : 'Interested in purchasing $quantity piece(s) of ${widget.product.title}.',
                            status: 'new',
                            createdAt: DateTime.now(),
                          );

                          Navigator.pop(ctx);
                          try {
                            // Actually reaches the artisan now. This used to
                            // push onto an in-memory mock list and report
                            // success regardless, so nothing was ever sent.
                            await _firestore.sendEnquiry(newEnquiry);
                            _toast(
                                'Enquiry sent to the artisan. View it in "Sent Enquiries".');
                          } catch (_) {
                            _toast(
                                'Could not send the enquiry. Check your connection and try again.');
                          }
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
    final bool showHindi = Localizations.localeOf(context).languageCode == 'hi';
    final product = widget.product;
    final ArtisanModel? artisan = _artisan;
    final List<ProductModel> similarProducts = _similarProducts;

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
                child: const Icon(Icons.arrow_back,
                    color: AppColors.ink, size: 18),
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
                    color:
                        _isSaved ? AppColors.vermillionAccent : AppColors.ink,
                    size: 18,
                  ),
                ),
                onPressed: () => _toggleSaved(),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    // Cached so revisiting the product, or losing signal after
                    // first view, still shows the craft.
                    placeholder: (_, __) => Container(
                      color: AppColors.canvas,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.action,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.canvas,
                      child: const Center(
                        child: Icon(Icons.palette_outlined,
                            size: 60, color: AppColors.action),
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

                  // Artisan Mini Card with Storefront Navigation. Hidden until
                  // the artisan document loads - the product already carries
                  // artisanName and cluster, shown above, so the page is not
                  // missing attribution in the meantime.
                  if (artisan != null) ...<Widget>[
                    ArtisanMiniCard(
                      artisan: artisan,
                      onViewStorefront: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BuyerArtisanStorefrontScreen(artisan: artisan),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Material, Technique & Craft specs chips.
                  //
                  // Wrap hands each child UNBOUNDED width, so a pill can only
                  // move to the next line as a whole - it can never shrink. A
                  // long material string ("Artist-grade Watercolour on 300gsm
                  // Cold-press Paper") therefore ran off the screen. The
                  // LayoutBuilder passes the real available width down so each
                  // pill can cap itself and wrap its text instead.
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints c) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSpecPill(Icons.category_outlined,
                            product.craftType, c.maxWidth),
                        if (product.material.isNotEmpty)
                          _buildSpecPill(Icons.texture_outlined,
                              product.material, c.maxWidth),
                        _buildSpecPill(
                            Icons.timer_outlined,
                            t.buyerHoursOfCraftCount(product.hoursOfWork),
                            c.maxWidth),
                      ],
                    ),
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
                      border: Border.all(
                          color: AppColors.heritage.withValues(alpha: 0.6),
                          width: 1.2),
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
                            const Icon(Icons.verified_user_outlined,
                                color: AppColors.action, size: 20),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
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
                        _buildPriceRow(
                            t.buyerMaterialCost, '₹${product.materialCost}'),
                        const SizedBox(height: 6),
                        _buildPriceRow(
                          'Fair Artisan Wage (${product.hoursOfWork}h @ ₹150/hr):',
                          '₹${product.hoursOfWork * 150}',
                        ),
                        const SizedBox(height: 6),
                        _buildPriceRow(t.buyerPackagingOverhead,
                            '₹${product.priceFloor - product.materialCost - (product.hoursOfWork * 150) > 0 ? product.priceFloor - product.materialCost - (product.hoursOfWork * 150) : 350}'),
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
                          showHindi
                              ? product.priceReasoningHi
                              : product.priceReasoning,
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
                          icon: const Icon(Icons.chat_bubble_outline_rounded,
                              color: AppColors.ink),
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
                                builder: (_) => BuyerRfqScreen(
                                    prefilledCraft: product.craftType),
                              ),
                            );
                          },
                          icon: const Icon(Icons.request_quote_outlined,
                              color: AppColors.ink, size: 18),
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
                            side: const BorderSide(
                                color: AppColors.action, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                      imageUrl: p.imageUrl.isEmpty
                          ? null
                          : CachedNetworkImageProvider(p.imageUrl),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BuyerProductDetailScreen(product: p),
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

  Widget _buildSpecPill(IconData icon, String text, double maxWidth) {
    return ConstrainedBox(
      // Never wider than the row it sits in, whatever the text says.
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
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
            // Flexible so the text yields once the pill hits maxWidth, rather
            // than pushing the Row past it.
            Flexible(
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
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
            style: const TextStyle(
                fontFamily: 'Lora', fontSize: 13, color: AppColors.textMuted),
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
