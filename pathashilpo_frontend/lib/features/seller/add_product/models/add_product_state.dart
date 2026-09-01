import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../ai/pricing/controllers/pricing_service.dart';
import '../../../../ai/pricing/models/price_result.dart';
import '../../../../data/local/drafts_box.dart';

/// State for the four-step add-product flow - TRD.md §11.4.
///
/// Held by the `PageView` parent and persisted to the Hive `drafts` box after
/// every step, so a crash or backgrounding never loses the artisan's work.
class AddProductState extends ChangeNotifier {
  AddProductState({String? localId, DraftsBox drafts = const DraftsBox()})
      : localId = localId ?? const Uuid().v4(),
        _drafts = drafts;

  final DraftsBox _drafts;

  /// Client-generated UUID, created at capture and **never regenerated**.
  /// This becomes the Firestore document id, which is what makes sync
  /// idempotent - a retry upserts, it cannot duplicate (TRD.md §9.2).
  final String localId;

  // Step 1 - photo
  String? photoPath;
  Uint8List? photoBytes;

  /// Backend-processed version of the photo (fal.ai background removal,
  /// TRD.md §8.4). Null until [ImageRouter] returns a non-degraded result.
  /// [photoBytes] is ALWAYS kept as the source of truth - the processed URL
  /// is a display upgrade, never a replacement, so an offline publish still
  /// has a real image to send.
  String? processedImageUrl;
  bool backgroundRemoved = false;
  double? qualityScore;

  // Step 2 - voice
  String? transcript;
  String? audioPath;
  int speechTier = 3;

  // Step 3 - costs
  int? materialCost;
  int? hoursOfWork;

  // Step 4 - generated listing and price
  String? title;
  String? titleHi;
  String? description;
  String? descriptionHi;
  List<String> tags = <String>[];
  String generatedBy = 'template';
  PriceResult? price;
  int? priceFinal;

  /// True when the draft was produced without a network. Drives the
  /// "Offline Draft" badge and tells the sync engine an AI upgrade is pending.
  bool wasOffline = true;

  bool get hasPhoto => photoBytes != null || photoPath != null;
  bool get hasCosts => materialCost != null && hoursOfWork != null;

  /// Records the result of the image pipeline. A degraded result is ignored
  /// so a failed call never clears a URL an earlier attempt succeeded in
  /// getting.
  void setProcessedImage({required String url, required bool bgRemoved}) {
    processedImageUrl = url;
    backgroundRemoved = bgRemoved;
    notifyListeners();
    persist();
  }

  void setPhoto({String? path, Uint8List? bytes, double? quality}) {
    photoPath = path;
    photoBytes = bytes;
    // A new photo invalidates any processing done on the previous one.
    processedImageUrl = null;
    backgroundRemoved = false;
    qualityScore = quality;
    notifyListeners();
    persist();
  }

  void setSpeech({required String transcript, String? audioPath, int tier = 3}) {
    this.transcript = transcript;
    this.audioPath = audioPath;
    speechTier = tier;
    notifyListeners();
    persist();
  }

  void setCosts({required int materialCost, required int hoursOfWork}) {
    this.materialCost = materialCost;
    this.hoursOfWork = hoursOfWork;
    price = const PricingService()
        .compute(materialCost: materialCost, hoursOfWork: hoursOfWork);
    // Default to the suggested price; the artisan may move it (PRD.md §7).
    priceFinal ??= price!.suggested;
    notifyListeners();
    persist();
  }

  void setListing({
    required String title,
    required String titleHi,
    required String description,
    required String descriptionHi,
    required List<String> tags,
    required String generatedBy,
  }) {
    this.title = title;
    this.titleHi = titleHi;
    this.description = description;
    this.descriptionHi = descriptionHi;
    this.tags = tags;
    this.generatedBy = generatedBy;
    notifyListeners();
    persist();
  }

  /// The artisan's confirmed price.
  ///
  /// Once set this is **never overwritten by a server recomputation**
  /// (TRD.md §9.4) - the price they saw is the price that stands.
  void setPriceFinal(int value) {
    priceFinal = value;
    notifyListeners();
    persist();
  }

  /// Serialises to the shape stored in the Hive `drafts` box. Only
  /// primitives Hive supports natively - no custom adapter needed.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'localId': localId,
      'photoPath': photoPath,
      'photoBytes': photoBytes,
      'processedImageUrl': processedImageUrl,
      'backgroundRemoved': backgroundRemoved,
      'qualityScore': qualityScore,
      'transcript': transcript,
      'audioPath': audioPath,
      'speechTier': speechTier,
      'materialCost': materialCost,
      'hoursOfWork': hoursOfWork,
      'title': title,
      'titleHi': titleHi,
      'description': description,
      'descriptionHi': descriptionHi,
      'tags': tags,
      'generatedBy': generatedBy,
      'priceFinal': priceFinal,
      'wasOffline': wasOffline,
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Restores state saved by [toMap]. [price] is not persisted - it is
  /// pure-function output of [materialCost]/[hoursOfWork] and is
  /// recomputed rather than trusted from storage.
  void loadFromMap(Map<String, dynamic> map) {
    photoPath = map['photoPath'] as String?;
    photoBytes = map['photoBytes'] as Uint8List?;
    processedImageUrl = map['processedImageUrl'] as String?;
    backgroundRemoved = map['backgroundRemoved'] as bool? ?? false;
    qualityScore = map['qualityScore'] as double?;
    transcript = map['transcript'] as String?;
    audioPath = map['audioPath'] as String?;
    speechTier = map['speechTier'] as int? ?? 3;
    materialCost = map['materialCost'] as int?;
    hoursOfWork = map['hoursOfWork'] as int?;
    title = map['title'] as String?;
    titleHi = map['titleHi'] as String?;
    description = map['description'] as String?;
    descriptionHi = map['descriptionHi'] as String?;
    tags = (map['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[];
    generatedBy = map['generatedBy'] as String? ?? 'template';
    priceFinal = map['priceFinal'] as int?;
    wasOffline = map['wasOffline'] as bool? ?? true;

    if (materialCost != null && hoursOfWork != null) {
      price = const PricingService()
          .compute(materialCost: materialCost!, hoursOfWork: hoursOfWork!);
    }
    notifyListeners();
  }

  /// Loads an existing draft by [localId], if one was saved. Not wired into
  /// any screen yet - "resume a draft" is a product decision for later.
  static AddProductState? resume(String localId,
      {DraftsBox drafts = const DraftsBox()}) {
    final Map<String, dynamic>? saved = drafts.get(localId);
    if (saved == null) return null;
    final AddProductState state = AddProductState(localId: localId, drafts: drafts);
    state.loadFromMap(saved);
    return state;
  }

  void persist() {
    _drafts.put(localId, toMap());
  }
}
