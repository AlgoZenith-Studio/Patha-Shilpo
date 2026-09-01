/// Artisan Model according to TRD.md §4.1
class ArtisanModel {
  final String uid;
  final String name;
  final String nameHi;
  final String village;
  final String district;
  final String state;
  final String craft;
  final String cluster;
  final String? giTag;

  /// Which identity document the artisan holds: 'gstin' | 'pan' | 'aadhaar'.
  ///
  /// **The number itself is never stored** (TRD.md §5.6, §19.8). Aadhaar and
  /// PAN are regulated personal data, and `artisans/{uid}` is world-readable,
  /// so only the *type* is persisted. GSTIN is a public business registration
  /// and is the one identifier safe to keep in full.
  final String? idType;
  final String? gstin;
  final bool idVerified;
  final String story;
  final String storyHi;
  final int yearsOfPractice;
  final String? photoUrl;
  final bool verified;
  final int productCount;
  final double rating;
  final String? audioStoryUrl;
  final DateTime createdAt;

  const ArtisanModel({
    required this.uid,
    required this.name,
    required this.nameHi,
    required this.village,
    required this.district,
    required this.state,
    required this.craft,
    required this.cluster,
    this.giTag,
    this.idType,
    this.gstin,
    this.idVerified = false,
    required this.story,
    required this.storyHi,
    required this.yearsOfPractice,
    this.photoUrl,
    this.verified = true,
    this.productCount = 0,
    this.rating = 4.9,
    this.audioStoryUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'nameHi': nameHi,
      'village': village,
      'district': district,
      'state': state,
      'craft': craft,
      'cluster': cluster,
      'giTag': giTag,
      'idType': idType,
      'gstin': gstin,
      'idVerified': idVerified,
      'story': story,
      'storyHi': storyHi,
      'yearsOfPractice': yearsOfPractice,
      'photoUrl': photoUrl,
      'verified': verified,
      'productCount': productCount,
      'rating': rating,
      'audioStoryUrl': audioStoryUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ArtisanModel.fromMap(Map<String, dynamic> map) {
    return ArtisanModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      nameHi: map['nameHi'] ?? '',
      village: map['village'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      craft: map['craft'] ?? '',
      cluster: map['cluster'] ?? '',
      giTag: map['giTag'],
      idType: map['idType'],
      gstin: map['gstin'],
      idVerified: map['idVerified'] ?? false,
      story: map['story'] ?? '',
      storyHi: map['storyHi'] ?? '',
      yearsOfPractice: map['yearsOfPractice']?.toInt() ?? 0,
      photoUrl: map['photoUrl'],
      verified: map['verified'] ?? true,
      productCount: map['productCount']?.toInt() ?? 0,
      rating: (map['rating'] ?? 4.9).toDouble(),
      audioStoryUrl: map['audioStoryUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
