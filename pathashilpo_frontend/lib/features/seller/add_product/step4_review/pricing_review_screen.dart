import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../ai/listing/controllers/listing_router.dart';
import '../../../../ai/listing/controllers/listing_template.dart';
import '../../../../ai/image/controllers/image_result.dart';
import '../../../../ai/image/controllers/image_router.dart';
import '../../../../ai/tts/views/tts_readback_button.dart';
import '../../../../ai/pricing/models/price_result.dart';
import '../../../../core/i18n/generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/badges/offline_draft_badge.dart';
import '../../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../../../../core/widgets/cards/price_band_card.dart';
import '../models/add_product_state.dart';

/// Step 4 — review and confirm (PRD.md FEAT-02).
///
/// Everything comes together here: the photo, the generated copy, and the
/// explained price band. One button publishes.
///
/// The artisan can move the price anywhere between floor and max. Whatever they
/// confirm becomes `priceFinal`, and **the server never overwrites it**
/// (TRD.md §9.4) — that guarantee is the reason they can trust the number.
class PricingReviewScreen extends StatefulWidget {
  const PricingReviewScreen({super.key, required this.onPublish});

  final VoidCallback onPublish;

  @override
  State<PricingReviewScreen> createState() => _PricingReviewScreenState();
}

class _PricingReviewScreenState extends State<PricingReviewScreen> {
  final ListingRouter _listingRouter = const ListingRouter();
  final ImageRouter _imageRouter = const ImageRouter();
  bool _generating = false;
  bool _enhancingPhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateListing();
      // Deliberately not awaited alongside the listing call: the two are
      // independent, and the artisan should not wait on fal.ai to read their
      // copy and price. The photo upgrades in place when it arrives.
      _enhancePhoto();
    });
  }

  /// Sends the captured photo to `POST /api/v1/ai/image` (fal.ai background
  /// removal, TRD.md §8.4). [ImageRouter] never throws and returns a degraded
  /// result when offline or on failure - in that case we keep showing the
  /// original bytes, which is exactly the previous behaviour.
  Future<void> _enhancePhoto() async {
    final AddProductState draft = context.read<AddProductState>();
    final Uint8List? bytes = draft.photoBytes;
    if (bytes == null || draft.processedImageUrl != null) return;

    setState(() => _enhancingPhoto = true);
    final ImageResult r = await _imageRouter.run(bytes);
    if (!mounted) return;
    setState(() => _enhancingPhoto = false);

    // A degraded result means nothing was processed - recording it would
    // just store a base64 copy of bytes we already hold.
    if (!r.degraded) {
      draft.setProcessedImage(
        url: r.imageUrl,
        bgRemoved: r.backgroundRemoved,
      );
    }
  }

  /// Prefers the backend (`POST /api/v1/ai/listing`, Gemini) when reachable;
  /// [ListingRouter] falls back to the offline template on any failure, so
  /// this never leaves the artisan without a listing.
  Future<void> _generateListing() async {
    final AddProductState draft = context.read<AddProductState>();
    if (draft.title != null) return;

    setState(() => _generating = true);

    final ListingResult r = await _listingRouter.run(
      transcript: draft.transcript ?? '',
      hoursOfWork: draft.hoursOfWork,
    );

    if (!mounted) return;
    setState(() => _generating = false);

    draft.setListing(
      title: r.title,
      titleHi: r.titleHi,
      description: r.description,
      descriptionHi: r.descriptionHi,
      tags: r.tags,
      generatedBy: r.generatedBy,
    );
  }

  /// Shows the processed image when the backend returned one, otherwise the
  /// original capture. The local bytes stay the fallback for the network
  /// image too, so a dead URL never leaves an empty box.
  Widget _buildPhoto(AppLocalizations t, AddProductState draft) {
    final String? url = draft.processedImageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppShape.cardRadius),
          child: AspectRatio(
            aspectRatio: 1,
            child: url == null
                ? Image.memory(draft.photoBytes!, fit: BoxFit.cover)
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Image.memory(draft.photoBytes!, fit: BoxFit.cover),
                  ),
          ),
        ),
        if (_enhancingPhoto) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(t.reviewEnhancingPhoto,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ] else if (draft.backgroundRemoved) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.auto_fix_high_rounded,
                  size: 16, color: AppColors.action),
              const SizedBox(width: 8),
              Text(t.reviewBackgroundRemoved,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final AddProductState draft = context.watch<AddProductState>();
    final PriceResult? price = draft.price;

    if (price == null || (_generating && draft.title == null)) {
      return const Center(child: CircularProgressIndicator());
    }

    // The listing engine emits both scripts; show only the active language.
    final bool showHindi = Localizations.localeOf(context).languageCode == 'hi';
    final String title =
        (showHindi ? draft.titleHi : draft.title) ?? draft.title ?? '';
    final String description =
        (showHindi ? draft.descriptionHi : draft.description) ??
            draft.description ??
            '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(t.reviewTitle,
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              if (draft.wasOffline) const OfflineDraftBadge(compact: true),
            ],
          ),
          const SizedBox(height: 16),
          if (draft.photoBytes != null) _buildPhoto(t, draft),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppShape.cardRadius),
              border:
                  Border.all(color: AppColors.border, width: AppShape.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(description,
                    style: Theme.of(context).textTheme.bodyMedium),
                if (draft.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: draft.tags
                        .map((String tag) => Chip(
                              label: Text(tag),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  draft.generatedBy == 'gemini'
                      ? t.reviewWrittenByAi
                      : t.reviewWrittenOffline,
                  style: TextStyle(
                    fontFamily: AppTheme.bodyFont,
                    fontFamilyFallback: AppTheme.scriptFallback,
                    fontSize: 12,
                    color: AppColors.border,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(t.reviewYourPrice,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Builder(
            builder: (BuildContext context) {
              // Built once and shared: the card shows the rationale, the
              // button reads out the exact same sentence. An artisan with
              // limited literacy should hear precisely what is on screen,
              // never a separately worded summary (PRD.md §6 step 4).
              final String reasoning = t.priceReasoning(
                price.materialCost,
                price.hoursOfWork,
                price.fairWagePerHour,
                price.labourCost,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PriceBandCard(
                    floor: price.floor,
                    suggested: price.suggested,
                    max: price.max,
                    reasoning: reasoning,
                  ),
                  TtsReadbackButton(text: reasoning),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _PriceChooser(price: price, draft: draft),
          const SizedBox(height: 24),
          PrimaryBilingualButton(
            label: t.reviewPublish,
            icon: Icons.check_rounded,
            onPressed: widget.onPublish,
          ),
          const SizedBox(height: 10),
          Text(
            t.reviewPriceLocked,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// Lets the artisan move the final price within the band.
class _PriceChooser extends StatelessWidget {
  const _PriceChooser({required this.price, required this.draft});

  final PriceResult price;
  final AddProductState draft;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final int current = draft.priceFinal ?? price.suggested;
    // A zero-width band (both costs zero) would make Slider throw.
    final bool adjustable = price.max > price.floor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(t.reviewYouWillSellAt,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Text('₹$current',
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        if (adjustable)
          Slider(
            value: current.toDouble().clamp(
                  price.floor.toDouble(),
                  price.max.toDouble(),
                ),
            min: price.floor.toDouble(),
            max: price.max.toDouble(),
            divisions: ((price.max - price.floor) / 50).round().clamp(1, 200),
            activeColor: AppColors.action,
            inactiveColor: AppColors.border,
            onChanged: (double v) => draft.setPriceFinal(v.round()),
          ),
        Text(
          t.reviewPriceFloorNote(price.floor),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
