/// Product Model according to TRD.md and MVP Architecture
class ProductModel {
  final String productId;
  final String localId;
  final String artisanId;
  final String artisanName;
  final String artisanCluster;
  final String artisanState;
  final String? artisanPhotoUrl;
  final String imageUrl;
  final String? originalImageUrl;
  final String title;
  final String titleHi;
  final String description;
  final String descriptionHi;
  final List<String> tags;
  final String material;
  final String craftType;
  final List<String> colors;
  final int hoursOfWork;
  final int materialCost;
  final int priceFloor;
  final int priceSuggested;
  final int priceMax;
  final int priceFinal;
  final String priceReasoning;
  final String priceReasoningHi;
  final String state; // CAPTURED | OFFLINE_PROCESSED | SYNCING | AI_UPGRADED | LIVE
  final String status; // draft | live | flagged | sold
  final List<String> channels;
  final String? giTag;
  final bool isVerified;
  final DateTime createdAt;

  const ProductModel({
    required this.productId,
    required this.localId,
    required this.artisanId,
    required this.artisanName,
    required this.artisanCluster,
    required this.artisanState,
    this.artisanPhotoUrl,
    required this.imageUrl,
    this.originalImageUrl,
    required this.title,
    required this.titleHi,
    required this.description,
    required this.descriptionHi,
    required this.tags,
    required this.material,
    required this.craftType,
    required this.colors,
    required this.hoursOfWork,
    required this.materialCost,
    required this.priceFloor,
    required this.priceSuggested,
    required this.priceMax,
    required this.priceFinal,
    required this.priceReasoning,
    required this.priceReasoningHi,
    this.state = 'LIVE',
    this.status = 'live',
    this.channels = const ['storefront'],
    this.giTag,
    this.isVerified = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'localId': localId,
      'artisanId': artisanId,
      'artisanName': artisanName,
      'artisanCluster': artisanCluster,
      'artisanState': artisanState,
      'artisanPhotoUrl': artisanPhotoUrl,
      'imageUrl': imageUrl,
      'originalImageUrl': originalImageUrl,
      'title': title,
      'titleHi': titleHi,
      'description': description,
      'descriptionHi': descriptionHi,
      'tags': tags,
      'material': material,
      'craftType': craftType,
      'colors': colors,
      'hoursOfWork': hoursOfWork,
      'materialCost': materialCost,
      'priceFloor': priceFloor,
      'priceSuggested': priceSuggested,
      'priceMax': priceMax,
      'priceFinal': priceFinal,
      'priceReasoning': priceReasoning,
      'priceReasoningHi': priceReasoningHi,
      'state': state,
      'status': status,
      'channels': channels,
      'giTag': giTag,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      localId: map['localId'] ?? '',
      artisanId: map['artisanId'] ?? '',
      artisanName: map['artisanName'] ?? 'Rural Artisan',
      artisanCluster: map['artisanCluster'] ?? 'Craft Cluster',
      artisanState: map['artisanState'] ?? 'India',
      artisanPhotoUrl: map['artisanPhotoUrl'],
      imageUrl: map['imageUrl'] ?? '',
      originalImageUrl: map['originalImageUrl'],
      title: map['title'] ?? '',
      titleHi: map['titleHi'] ?? '',
      description: map['description'] ?? '',
      descriptionHi: map['descriptionHi'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      material: map['material'] ?? '',
      craftType: map['craftType'] ?? '',
      colors: List<String>.from(map['colors'] ?? []),
      hoursOfWork: map['hoursOfWork']?.toInt() ?? 0,
      materialCost: map['materialCost']?.toInt() ?? 0,
      priceFloor: map['priceFloor']?.toInt() ?? 0,
      priceSuggested: map['priceSuggested']?.toInt() ?? 0,
      priceMax: map['priceMax']?.toInt() ?? 0,
      priceFinal: map['priceFinal']?.toInt() ?? 0,
      priceReasoning: map['priceReasoning'] ?? '',
      priceReasoningHi: map['priceReasoningHi'] ?? '',
      state: map['state'] ?? 'LIVE',
      status: map['status'] ?? 'live',
      channels: List<String>.from(map['channels'] ?? ['storefront']),
      giTag: map['giTag'],
      isVerified: map['isVerified'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
