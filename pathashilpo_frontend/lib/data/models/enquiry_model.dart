/// Enquiry Model according to TRD.md §4.1
class EnquiryModel {
  final String enquiryId;
  final String productId;
  final String productTitle;
  final String productImageUrl;
  final String artisanId;
  final String artisanName;
  final String buyerUid;
  final String buyerName;
  final String buyerPhone;
  final String buyerType;
  final int quantity;
  final String message;
  final String status; // new | accepted | declined
  final DateTime createdAt;

  const EnquiryModel({
    required this.enquiryId,
    required this.productId,
    required this.productTitle,
    required this.productImageUrl,
    required this.artisanId,
    required this.artisanName,
    required this.buyerUid,
    required this.buyerName,
    required this.buyerPhone,
    this.buyerType = 'retail',
    this.quantity = 1,
    required this.message,
    this.status = 'new',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'enquiryId': enquiryId,
      'productId': productId,
      'productTitle': productTitle,
      'productImageUrl': productImageUrl,
      'artisanId': artisanId,
      'artisanName': artisanName,
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerType': buyerType,
      'quantity': quantity,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EnquiryModel.fromMap(Map<String, dynamic> map) {
    return EnquiryModel(
      enquiryId: map['enquiryId'] ?? '',
      productId: map['productId'] ?? '',
      productTitle: map['productTitle'] ?? '',
      productImageUrl: map['productImageUrl'] ?? '',
      artisanId: map['artisanId'] ?? '',
      artisanName: map['artisanName'] ?? '',
      buyerUid: map['buyerUid'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerPhone: map['buyerPhone'] ?? '',
      buyerType: map['buyerType'] ?? 'retail',
      quantity: map['quantity']?.toInt() ?? 1,
      message: map['message'] ?? '',
      status: map['status'] ?? 'new',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
