import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../ai/tts/controllers/tts_router.dart';
import '../../../ai/tts/models/tts_input.dart';
import '../../../core/constants/pricing_constants.dart';
import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/sync_indicator.dart';
import '../../../data/models/product_model.dart';
import '../../../data/remote/firestore_service.dart';

/// The artisan's own master view of one of their products.
///
/// Gives the artisan full transparency into their pricing formula, fair-wage floor,
/// material costs, product story, voice readout, and listing management controls.
class ArtisanProductDetailScreen extends StatefulWidget {
  const ArtisanProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ArtisanProductDetailScreen> createState() =>
      _ArtisanProductDetailScreenState();
}

class _ArtisanProductDetailScreenState
    extends State<ArtisanProductDetailScreen> {
  final FirestoreService _firestore = FirestoreService();
  final TtsRouter _tts = TtsRouter();
  bool _busy = false;
  bool _isPlayingStory = false;

  @override
  void dispose() {
    _tts.stop();
    _tts.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        content: Text(message,
            style: const TextStyle(
                fontFamily: 'Lora', color: AppColors.canvas)),
      ),
    );
  }

  Future<void> _speakPricingDetails(ProductModel product) async {
    final lang = Localizations.localeOf(context).languageCode;
    final int labour = product.hoursOfWork * PricingConstants.fairWagePerHour;
    final String speech;

    if (lang == 'bn') {
      speech =
          '${product.title}. বিক্রয় মূল্য: ${product.priceFinal} টাকা. কাঁচামাল খরচ: ${product.materialCost} টাকা. কাজের সময়: ${product.hoursOfWork} ঘণ্টা. শ্রমমূল্য: $labour টাকা. ন্যূনতম ন্যায্য মূল্য মেঝে: ${product.priceFloor} টাকা.';
    } else if (lang == 'hi') {
      speech =
          '${product.title}. विक्रय मूल्य: ${product.priceFinal} रुपये. कच्चा माल लागत: ${product.materialCost} रुपये. कुल श्रम: ${product.hoursOfWork} घंटे. पारिश्रमिक: $labour रुपये. न्यूनतम उचित मजदूरी: ${product.priceFloor} रुपये.';
    } else {
      speech =
          '${product.title}. Selling price: ${product.priceFinal} rupees. Material cost: ${product.materialCost} rupees. Labor: ${product.hoursOfWork} hours, earning $labour rupees. Fair-wage floor: ${product.priceFloor} rupees.';
    }

    await _tts.speak(TtsInput(text: speech, languageCode: lang));
  }

  Future<void> _togglePlayStory(String storyText) async {
    if (_isPlayingStory) {
      await _tts.stop();
      setState(() => _isPlayingStory = false);
      return;
    }

    setState(() => _isPlayingStory = true);
    final lang = Localizations.localeOf(context).languageCode;
    try {
      await _tts.speak(TtsInput(text: storyText, languageCode: lang));
    } finally {
      if (mounted) setState(() => _isPlayingStory = false);
    }
  }

  /// Price editing is bounded by the floor.
  Future<void> _editPrice(ProductModel product) async {
    final AppLocalizations t = AppLocalizations.of(context);
    int chosen = product.priceFinal.clamp(product.priceFloor, product.priceMax);

    final int? result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setSheet) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppShape.sheetRadius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              Text(t.reviewYourPrice,
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(t.reviewPriceFloorNote(product.priceFloor),
                  style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 16),
              Center(
                child: Text('₹$chosen',
                    style: Theme.of(ctx).textTheme.displaySmall?.copyWith(
                          color: AppColors.action,
                          fontWeight: FontWeight.w700,
                        )),
              ),
              Slider(
                value: chosen.toDouble(),
                min: product.priceFloor.toDouble(),
                max: (product.priceMax > product.priceFloor
                        ? product.priceMax
                        : product.priceFloor + PricingConstants.roundTo)
                    .toDouble(),
                divisions: null,
                activeColor: AppColors.action,
                inactiveColor: AppColors.border,
                onChanged: (double v) => setSheet(() => chosen =
                    (v / PricingConstants.roundTo).round() *
                        PricingConstants.roundTo),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('${t.priceFloor}  ₹${product.priceFloor}',
                      style: Theme.of(ctx).textTheme.bodySmall),
                  Text('${t.priceMaximum}  ₹${product.priceMax}',
                      style: Theme.of(ctx).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, chosen),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.action,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(t.commonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || result == product.priceFinal) return;
    setState(() => _busy = true);
    try {
      await _firestore.updateProductPrice(
          localId: product.localId, priceFinal: result);
      _toast(t.productPriceUpdated);
    } catch (_) {
      _toast(t.productActionFailed);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _toggleListed(ProductModel product) async {
    final AppLocalizations t = AppLocalizations.of(context);
    final bool live = product.status == 'live';
    setState(() => _busy = true);
    try {
      await _firestore.setProductStatus(
        localId: product.localId,
        status: live ? 'draft' : 'live',
      );
      _toast(live ? t.productUnlisted : t.productRelisted);
    } catch (_) {
      _toast(t.productActionFailed);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _delete(ProductModel product) async {
    final AppLocalizations t = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final bool? sure = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(t.productDeleteTitle),
        content: Text(t.productDeleteBody),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.productDelete,
                style: const TextStyle(color: AppColors.vermillionAccent)),
          ),
        ],
      ),
    );
    if (sure != true) return;
    try {
      await _firestore.deleteProduct(product.localId);
      navigator.pop();
    } catch (_) {
      _toast(t.productActionFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final String currentLang = Localizations.localeOf(context).languageCode;

    return StreamBuilder<ProductModel?>(
      stream: _firestore.streamProduct(widget.product.localId),
      builder: (BuildContext context, AsyncSnapshot<ProductModel?> snap) {
        final ProductModel product = snap.data ?? widget.product;
        final bool live = product.status == 'live';
        final int labour =
            product.hoursOfWork * PricingConstants.fairWagePerHour;

        final String effectiveDescription = product.description.isNotEmpty
            ? product.description
            : (product.descriptionHi.isNotEmpty
                ? product.descriptionHi
                : 'Handcrafted masterwork created with traditional heritage techniques.');

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            backgroundColor: AppColors.canvas,
            elevation: 0,
            title: Text(
              product.title,
              style: const TextStyle(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.ink,
              ),
            ),
            actions: <Widget>[
              IconButton(
                tooltip: t.productDelete,
                onPressed: _busy ? null : () => _delete(product),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: <Widget>[
              // ---- 1. Product Preview Image ----
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: product.imageUrl.isEmpty
                      ? Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.image_outlined,
                              size: 48, color: AppColors.border),
                        )
                      : CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.image_outlined,
                                size: 48, color: AppColors.border),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Status row
              Row(
                children: <Widget>[
                  SyncIndicator(
                      state: live ? SyncState.live : SyncState.offlineProcessed),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: live ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: live
                            ? Colors.green.shade300
                            : Colors.amber.shade300,
                      ),
                    ),
                    child: Text(
                      live ? 'Live on Storefront' : 'Draft Listing',
                      style: TextStyle(
                        fontFamily: 'Pally',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: live
                            ? Colors.green.shade800
                            : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Title & Craft
              Text(
                product.title,
                style: const TextStyle(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppColors.ink,
                ),
              ),
              if (product.titleHi.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  product.titleHi,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              if (product.craftType.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    product.craftType,
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.action,
                    ),
                  ),
                ),

              // ---- 2. Transparent Fair Pricing Breakdown ----
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t.reviewYouWillSellAt,
                          style: const TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        // Voice Readout Button for Pricing
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded,
                              size: 20, color: AppColors.action),
                          tooltip: t.productListenPricing,
                          onPressed: () => _speakPricingDetails(product),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('₹${product.priceFinal}',
                            style: const TextStyle(
                              fontFamily: 'Pally',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.action,
                            )),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : () => _editPrice(product),
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: Text(t.productChangePrice),
                          style: ElevatedButton.styleFrom(
                            // Content-sized: this sits in a Row, where the
                            // theme's Size.fromHeight(56) resolves to an
                            // infinite width and throws during layout. See
                            // AppButtons in app_theme.dart.
                            minimumSize: const Size(0, 40),
                            backgroundColor: AppColors.action,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    _Line(
                        label: t.productMaterialCost,
                        value: '₹${product.materialCost}'),
                    _Line(
                        label: t.productHoursOfWork,
                        value: '${product.hoursOfWork} hrs'),
                    _Line(
                        label: t.productLabourAtFairWage(
                            PricingConstants.fairWagePerHour),
                        value: '₹$labour'),
                    const Divider(height: 24, color: AppColors.border),
                    _Line(
                        label: t.priceFloor,
                        value: '₹${product.priceFloor}',
                        emphasis: true),
                    _Line(
                        label: t.priceSuggested,
                        value: '₹${product.priceSuggested}'),
                    _Line(
                        label: t.priceMaximum, value: '₹${product.priceMax}'),
                    const SizedBox(height: 10),
                    Text(t.reviewPriceFloorNote(product.priceFloor),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textMuted,
                        )),
                  ],
                ),
              ),

              // ---- 3. Product Story & Heritage Process ----
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_stories_rounded,
                                color: AppColors.action, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              switch (currentLang) {
                                'bn' => 'পণ্যের গল্প ও নির্মাণ বিবরণ',
                                'hi' => 'उत्पाद कहानी एवं निर्माण विधि',
                                _ => 'Product Craft Story',
                              },
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _togglePlayStory(effectiveDescription),
                          icon: Icon(
                            _isPlayingStory
                                ? Icons.stop_circle_outlined
                                : Icons.volume_up_rounded,
                            size: 15,
                          ),
                          label: Text(_isPlayingStory ? 'Stop' : 'Listen'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            backgroundColor: _isPlayingStory
                                ? Colors.redAccent
                                : AppColors.canvas,
                            foregroundColor:
                                _isPlayingStory ? Colors.white : AppColors.ink,
                            elevation: 0,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      effectiveDescription,
                      style: const TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),

              if (product.tags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final String tag in product.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                              fontFamily: 'Pally',
                              fontSize: 12,
                              color: AppColors.textMuted,
                            )),
                      ),
                  ],
                ),
              ],

              // ---- 4. Listing Visibility Controls ----
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _toggleListed(product),
                  icon: Icon(live
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  label: Text(live ? t.productUnlist : t.productRelist),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              if (_busy) ...<Widget>[
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  minHeight: 2,
                  color: AppColors.action,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 13.5,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w400,
              color: emphasis ? AppColors.action : AppColors.ink,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Pally',
              fontSize: 14,
              fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
              color: emphasis ? AppColors.action : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
