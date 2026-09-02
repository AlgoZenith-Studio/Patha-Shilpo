import 'timestamps.dart';

/// Buyer Model according to TRD.md §4.1
class BuyerModel {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final String buyerType; // retail | b2b | exporter | govt
  final String? company;
  final String? gstin;
  final List<String> interests;
  final List<String> states;
  final List<String> savedProducts;
  final DateTime createdAt;

  const BuyerModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    this.buyerType = 'retail',
    this.company,
    this.gstin,
    this.interests = const [],
    this.states = const [],
    this.savedProducts = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'buyerType': buyerType,
      'company': company,
      'gstin': gstin,
      'interests': interests,
      'states': states,
      'savedProducts': savedProducts,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BuyerModel.fromMap(Map<String, dynamic> map) {
    return BuyerModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      buyerType: map['buyerType'] ?? 'retail',
      company: map['company'],
      gstin: map['gstin'],
      interests: List<String>.from(map['interests'] ?? []),
      states: List<String>.from(map['states'] ?? []),
      savedProducts: List<String>.from(map['savedProducts'] ?? []),
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
}
