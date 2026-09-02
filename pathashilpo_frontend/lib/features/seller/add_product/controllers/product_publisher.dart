import 'dart:typed_data';

import '../../../../ai/pricing/models/price_result.dart';
import '../../../../core/constants/craft_taxonomy.dart';
import '../../../../data/local/drafts_box.dart';
import '../../../../data/models/artisan_model.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/remote/firestore_service.dart';
import '../../../../data/remote/storage_service.dart';
import '../models/add_product_state.dart';

/// What happened to a publish attempt.
enum PublishStatus {
  /// Photo uploaded and the product document written. It is live for buyers.
  published,

  /// The write did not reach Firebase. The draft is still in the local Hive
  /// box, so nothing the artisan recorded is lost - they can publish again.
  keptAsDraft,

  /// The artisan has no profile document yet, so a product cannot be
  /// attributed. Registration has to finish first.
  noArtisanProfile,
}

class PublishResult {
  const PublishResult(this.status, {this.productId});

  final PublishStatus status;
  final String? productId;
}

/// Turns a completed [AddProductState] into a live product.
///
/// This is the step the add-product flow was missing entirely: `_publish()`
/// showed "saved offline" and popped the navigator without writing anything,
/// anywhere, so a photographed and priced craft simply vanished. Nothing
/// uploaded, no document created, and the products tab could not have shown it
/// even if it had been reading Firestore - which it also was not.
///
/// Ordering matters. The photo is uploaded **before** the document is written,
/// so a product document never exists pointing at an image that is not there.
/// If the upload fails the document is never created and the draft survives.
class ProductPublisher {
  ProductPublisher({
    FirestoreService? firestore,
    StorageService? storage,
    DraftsBox drafts = const DraftsBox(),
  })  : _firestore = firestore ?? FirestoreService(),
        _storage = storage ?? StorageService(),
        _drafts = drafts;

  final FirestoreService _firestore;
  final StorageService _storage;
  final DraftsBox _drafts;

  Future<PublishResult> publish({
    required AddProductState draft,
    required String artisanId,
  }) async {
    final ArtisanModel? artisan = await _firestore.getArtisan(artisanId);
    if (artisan == null) {
      return const PublishResult(PublishStatus.noArtisanProfile);
    }

    try {
      final Uint8List? bytes = draft.photoBytes;
      String imageUrl = draft.processedImageUrl ?? '';

      // Upload the captured bytes even when the AI pipeline returned a
      // processed URL: `photoBytes` is the source of truth (see
      // AddProductState.processedImageUrl) and the processed URL may be a
      // short-lived data: URI from the offline fallback, which is not
      // something a buyer's device can load later.
      if (bytes != null) {
        imageUrl = await _storage.uploadProductPhoto(
          artisanId: artisanId,
          productId: draft.localId,
          bytes: bytes,
        );
      }

      final ProductModel product = _toProduct(
        draft: draft,
        artisan: artisan,
        imageUrl: imageUrl,
      );

      await _firestore.saveProduct(product);

      // Only now is it safe to drop the local copy.
      await _drafts.delete(draft.localId);
      return PublishResult(PublishStatus.published, productId: product.localId);
    } catch (_) {
      // The draft was persisted after every step by AddProductState, so there
      // is nothing to write back here - it is already on disk and the artisan
      // can retry.
      return const PublishResult(PublishStatus.keptAsDraft);
    }
  }

  ProductModel _toProduct({
    required AddProductState draft,
    required ArtisanModel artisan,
    required String imageUrl,
  }) {
    final PriceResult? price = draft.price;
    final int finalPrice = draft.priceFinal ?? price?.suggested ?? 0;

    // The artisan's own craft decides the category, normalised so the product
    // lands under a filter chip buyers can actually select.
    final String craftType = CraftTaxonomy.categoryFor(artisan.craft) ??
        CraftTaxonomy.categories.first;

    final String cluster = artisan.cluster.isNotEmpty
        ? artisan.cluster
        : <String>[artisan.village, artisan.district]
            .where((String s) => s.isNotEmpty)
            .join(', ');

    return ProductModel(
      // localId is the client UUID minted at capture and never regenerated,
      // so republishing upserts the same document instead of duplicating it.
      productId: draft.localId,
      localId: draft.localId,
      artisanId: artisan.uid,
      artisanName: artisan.name,
      artisanCluster: cluster,
      artisanState: artisan.state,
      artisanPhotoUrl: artisan.photoUrl,
      imageUrl: imageUrl,
      originalImageUrl: null,
      title: draft.title ?? '',
      titleHi: draft.titleHi ?? '',
      description: draft.description ?? '',
      descriptionHi: draft.descriptionHi ?? '',
      tags: draft.tags,
      // Not captured anywhere in the four-step flow. Left empty rather than
      // invented - a buyer reading "Pure Mulberry Silk" on a guess is worse
      // than reading nothing.
      material: '',
      craftType: craftType,
      colors: const <String>[],
      hoursOfWork: draft.hoursOfWork ?? 0,
      materialCost: draft.materialCost ?? 0,
      priceFloor: price?.floor ?? finalPrice,
      priceSuggested: price?.suggested ?? finalPrice,
      priceMax: price?.max ?? finalPrice,
      priceFinal: finalPrice,
      // Numbers only in PriceResult by design (TRD.md §7); the prose is built
      // here from those components so it matches what the artisan was shown.
      priceReasoning: price == null
          ? ''
          : 'Fair wage ₹${price.fairWagePerHour}/hr × ${price.hoursOfWork} hrs '
              '(₹${price.labourCost}) + materials ₹${price.materialCost}.',
      priceReasoningHi: price == null
          ? ''
          : 'निष्पक्ष पारिश्रमिक ₹${price.fairWagePerHour}/घंटा × '
              '${price.hoursOfWork} घंटे (₹${price.labourCost}) + '
              'सामग्री ₹${price.materialCost}।',
      // AI_UPGRADED is for a later server pass; what the artisan published is
      // live and buyable now.
      state: 'LIVE',
      status: 'live',
      giTag: artisan.giTag,
      // Verification is a moderator action (TRD.md §5.6). A self-published
      // product is not verified, whatever the model's default says.
      isVerified: false,
      createdAt: DateTime.now(),
    );
  }
}
