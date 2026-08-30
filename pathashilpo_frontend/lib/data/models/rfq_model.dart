/// RFQ Model according to TRD.md §4.1
class RfqModel {
  final String rfqId;
  final String buyerUid;
  final String buyerName;
  final String craft;
  final String? cluster;
  final int quantity;
  final String deadline;
  final int budgetMin;
  final int budgetMax;
  final List<String> matchedArtisanIds;
  final String status; // active | matched | completed
  final String? notes;
  final DateTime createdAt;

  const RfqModel({
    required this.rfqId,
    required this.buyerUid,
    required this.buyerName,
    required this.craft,
    this.cluster,
    required this.quantity,
    required this.deadline,
    required this.budgetMin,
    required this.budgetMax,
    this.matchedArtisanIds = const [],
    this.status = 'active',
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'rfqId': rfqId,
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'craft': craft,
      'cluster': cluster,
      'quantity': quantity,
      'deadline': deadline,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'matchedArtisanIds': matchedArtisanIds,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RfqModel.fromMap(Map<String, dynamic> map) {
    return RfqModel(
      rfqId: map['rfqId'] ?? '',
      buyerUid: map['buyerUid'] ?? '',
      buyerName: map['buyerName'] ?? '',
      craft: map['craft'] ?? '',
      cluster: map['cluster'],
      quantity: map['quantity']?.toInt() ?? 0,
      deadline: map['deadline'] ?? '',
      budgetMin: map['budgetMin']?.toInt() ?? 0,
      budgetMax: map['budgetMax']?.toInt() ?? 0,
      matchedArtisanIds: List<String>.from(map['matchedArtisanIds'] ?? []),
      status: map['status'] ?? 'active',
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
