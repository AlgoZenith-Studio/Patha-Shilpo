import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ai/tts/controllers/tts_router.dart';
import '../../../ai/tts/models/tts_input.dart';
import '../../../ai/voice/views/on_device_voice_modal.dart';
import '../../../core/i18n/generated/app_localizations.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/badges/provenance_tag.dart';
import '../../../core/widgets/badges/sync_indicator.dart';
import '../../../data/local/drafts_box.dart';
import '../../../data/models/product_model.dart';
import '../../../data/remote/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import 'artisan_product_detail_screen.dart';

/// The artisan's own product list — inventory, sync state, voice search with offline fallback,
/// and luxury product management modals.
class ArtisanProductsScreen extends StatefulWidget {
  const ArtisanProductsScreen({super.key});

  @override
  State<ArtisanProductsScreen> createState() => _ArtisanProductsScreenState();
}

class _ArtisanProductsScreenState extends State<ArtisanProductsScreen> {
  /// Localised strings for this screen. A getter rather than a local in
  /// every helper: the whole class renders in one language, and that
  /// language is whichever Localizations resolves right now.
  AppLocalizations get t => AppLocalizations.of(context);

  final TextEditingController _searchController = TextEditingController();
  final TtsRouter _tts = TtsRouter();

  String _searchQuery = '';
  String _filterTab = 'all'; // 'all' | 'live' | 'drafts'

  late final String? _uid = context.read<AuthController>().currentUser?.uid;
  late final Stream<List<ProductModel>> _products =
      FirestoreService().streamArtisanProducts(_uid ?? '__none__');

  @override
  void dispose() {
    _searchController.dispose();
    _tts.stop();
    _tts.dispose();
    super.dispose();
  }

  void _showProductDetailsModal({
    required BuildContext context,
    required String title,
    required int price,
    required SyncState state,
    String? imageUrl,
    String? craftType,
    int? hours,
    String? description,
    String? localDraftId,
  }) {
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
              const SizedBox(height: 16),

              // Product Preview Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 190,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.canvas,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.action, strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.canvas,
                            child: const Icon(Icons.palette_outlined,
                                size: 48, color: AppColors.action),
                          ),
                        )
                      : Container(
                          color: AppColors.canvas,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined,
                                  size: 48, color: AppColors.border),
                              SizedBox(height: 8),
                              Text(
                                'Local Offline Photo Saved',
                                style: TextStyle(
                                  fontFamily: 'Lora',
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                            ProvenanceTag(
                              label: craftType ?? 'Handcrafted Art',
                              icon: Icons.workspace_premium_outlined,
                            ),
                            const SizedBox(width: 8),
                            SyncIndicator(state: state),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹$price',
                    style: const TextStyle(
                      fontFamily: 'Pally',
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: AppColors.action,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (hours != null) ...[
                Text(
                  'Handcrafted Labor: $hours hours of dedicated artisan work',
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              if (description != null && description.isNotEmpty) ...[
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Voice Readout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final lang = Localizations.localeOf(context).languageCode;
                    final String speech;
                    if (lang == 'bn') {
                      speech =
                          '$title. শিল্প ধরণ: ${craftType ?? 'ঐতিহ্যবাহী হস্তশিল্প'}. মূল্য: $price টাকা. অবস্থা: ${state == SyncState.live ? 'লাইভ স্টোরে প্রকাশিত' : 'স্থানীয় অফলাইন খসড়া'}.';
                    } else if (lang == 'hi') {
                      speech =
                          '$title. शिल्प प्रकार: ${craftType ?? 'पारंपरिक हस्तकला'}. कीमत: $price रुपये. स्थिति: ${state == SyncState.live ? 'लाइव ऑन स्टोर' : 'स्थानीय ड्राफ्ट'}.';
                    } else {
                      speech =
                          '$title. Craft category: ${craftType ?? 'Traditional Handcraft'}. Fair Price: $price rupees. Status: ${state == SyncState.live ? 'Live on Storefront' : 'Local Offline Draft'}.';
                    }
                    _tts.speak(TtsInput(text: speech, languageCode: lang));
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: Text(
                    switch (Localizations.localeOf(context).languageCode) {
                      'bn' => 'ভয়েস বিবরণ শুনুন (Voice Readout)',
                      'hi' => 'विवरण सुनें (Voice Readout)',
                      _ => 'Voice Readout (Listen to details)',
                    },
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  if (localDraftId != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          const DraftsBox().delete(localDraftId);
                          Navigator.pop(ctx);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.redAccent),
                        label: const Text(
                          'Delete Draft',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.redAccent.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  if (localDraftId != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.heritage,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(t.commonClose),
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final List<Map<String, dynamic>> rawDrafts =
        _uid == null ? const <Map<String, dynamic>>[] : const DraftsBox().all();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.artisanAddProduct),
        backgroundColor: AppColors.action,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          t.artisanAddCraft,
          style: TextStyle(fontFamily: 'Pally', fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _products,
        builder:
            (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
          final List<ProductModel> liveProducts =
              snapshot.data ?? const <ProductModel>[];
          final bool loading =
              snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData;

          // Apply Search Query and Filter Tabs
          final filteredDrafts = rawDrafts.where((d) {
            if (_filterTab == 'live') return false;
            if (_searchQuery.isEmpty) return true;
            final title = (d['title'] as String? ?? '').toLowerCase();
            final craft = (d['craftType'] as String? ?? '').toLowerCase();
            final q = _searchQuery.toLowerCase();
            return title.contains(q) || craft.contains(q);
          }).toList();

          final filteredLive = liveProducts.where((p) {
            if (_filterTab == 'drafts') return false;
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return p.title.toLowerCase().contains(q) ||
                p.titleHi.toLowerCase().contains(q) ||
                p.craftType.toLowerCase().contains(q);
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: <Widget>[
              Text(t.productsTitle,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),

              // ---- 1. PILL VOICE SEARCH BAR (WITH OFFLINE ON-DEVICE STT FALLBACK) ----
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
                          hintText: switch (
                              Localizations.localeOf(context).languageCode) {
                            'bn' => 'পণ্য খুঁজুন বা মুখে বলুন...',
                            'hi' => 'उत्पाद खोजें या बोलें...',
                            _ => 'Search products or speak...',
                          },
                          hintStyle: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 13.5,
                            color: AppColors.textMuted.withValues(alpha: 0.85),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded,
                            size: 18, color: AppColors.border),
                        tooltip: t.commonClear,
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
                      tooltip: t.artisanVoiceSearch,
                      onPressed: () async {
                        final lang =
                            Localizations.localeOf(context).languageCode;
                        final spoken = await showOnDeviceVoiceModal(
                          context,
                          preferredLocaleCode: lang,
                        );
                        if (spoken != null && spoken.isNotEmpty && mounted) {
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
              const SizedBox(height: 14),

              // ---- 2. FILTER CHIPS ----
              Row(
                children: [
                  _buildFilterChip('all', 'All (${rawDrafts.length + liveProducts.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('live', 'Live (${liveProducts.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip('drafts', 'Drafts (${rawDrafts.length})'),
                ],
              ),
              const SizedBox(height: 18),

              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.action),
                  ),
                )
              else if (snapshot.hasError)
                _Notice(title: t.productsLoadFailed, body: '')
              else if (filteredProductsEmpty(filteredDrafts, filteredLive))
                _Notice(title: t.productsEmpty, body: t.productsEmptyBody)
              else ...<Widget>[
                // Local Drafts
                for (final Map<String, dynamic> draft in filteredDrafts) ...[
                  _ProductRow(
                    title: (draft['title'] as String?)?.trim().isNotEmpty == true
                        ? draft['title'] as String
                        : t.productsEmpty,
                    price: draft['priceFinal'] as int? ?? 0,
                    craftType: draft['craftType'] as String?,
                    state: SyncState.offlineProcessed,
                    onTap: () {
                      _showProductDetailsModal(
                        context: context,
                        title: draft['title'] as String? ?? 'Offline Craft Draft',
                        price: draft['priceFinal'] as int? ?? 0,
                        craftType: draft['craftType'] as String?,
                        hours: draft['hoursOfWork'] as int?,
                        description: draft['transcript'] as String?,
                        state: SyncState.offlineProcessed,
                        localDraftId: draft['localId'] as String?,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Live Firestore Products
                for (final ProductModel product in filteredLive) ...[
                  _ProductRow(
                    title: product.title,
                    price: product.priceFinal,
                    imageUrl: product.imageUrl,
                    craftType: product.craftType,
                    state: SyncState.live,
                    // Opens the dedicated artisan product page - pricing
                    // breakdown, listing control, delete - rather than the
                    // summary sheet, which showed no cost or floor at all.
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ArtisanProductDetailScreen(product: product),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  bool filteredProductsEmpty(List drafts, List live) =>
      drafts.isEmpty && live.isEmpty;

  Widget _buildFilterChip(String key, String label) {
    final bool isSelected = _filterTab == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pally',
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12.5,
          color: isSelected ? AppColors.ink : AppColors.textMuted,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.heritage,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.action : AppColors.border,
          width: isSelected ? 1.4 : 1.0,
        ),
      ),
      onSelected: (_) => setState(() => _filterTab = key),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: AppShape.hairline),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.inventory_2_outlined,
              size: 44, color: AppColors.border),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          if (body.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.title,
    required this.price,
    required this.state,
    this.craftType,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final int price;
  final SyncState state;
  final String? craftType;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: (imageUrl == null || imageUrl!.isEmpty)
                      ? Container(
                          color: AppColors.canvas,
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.border, size: 28),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.canvas,
                            child: const Icon(Icons.image_outlined,
                                color: AppColors.border, size: 28),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontFamily: 'Pally',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.action,
                          ),
                        ),
                        if (craftType != null && craftType!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '·  $craftType',
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    SyncIndicator(state: state),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
