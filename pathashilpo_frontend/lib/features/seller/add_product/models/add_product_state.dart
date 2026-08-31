import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../ai/pricing/controllers/pricing_service.dart';
import '../../../../ai/pricing/models/price_result.dart';

/// State for the four-step add-product flow — TRD.md §11.4.
///
/// Held by the `PageView` parent and persisted to Hive after every step so a
/// crash or backgrounding never loses the artisan's work. (Hive is not wired
/// yet; [persist] is the seam where that lands.)
class AddProductState extends ChangeNotifier {
  AddProductState() : localId = const Uuid().v4();

  /// Client-generated UUID, created at capture and **never regenerated**.
  /// This becomes the Firestore document id, which is what makes sync
  /// idempotent — a retry upserts, it cannot duplicate (TRD.md §9.2).
  final String localId;

  // Step 1 — photo
  String? photoPath;
  Uint8List? photoBytes;
  double? qualityScore;

  // Step 2 — voice
  String? transcript;
  String? audioPath;
  int speechTier = 3;

  // Step 3 — costs
  int? materialCost;
  int? hoursOfWork;

  // Step 4 — generated listing and price
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

  void setPhoto({String? path, Uint8List? bytes, double? quality}) {
    photoPath = path;
    photoBytes = bytes;
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
  /// (TRD.md §9.4) — the price they saw is the price that stands.
  void setPriceFinal(int value) {
    priceFinal = value;
    notifyListeners();
    persist();
  }

  /// Seam for Hive persistence (`drafts` box, keyed by [localId]).
  void persist() {
    // TODO(sync): write to the Hive `drafts` box once data/local is wired.
  }
}
