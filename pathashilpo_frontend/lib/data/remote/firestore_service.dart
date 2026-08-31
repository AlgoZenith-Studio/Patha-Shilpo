import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/artisan_model.dart';
import '../models/buyer_model.dart';
import '../models/enquiry_model.dart';
import '../models/product_model.dart';
import '../models/rfq_model.dart';

/// Firestore Database Service according to TRD.md §4 & §5.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _artisans =>
      _firestore.collection('artisans');
  CollectionReference<Map<String, dynamic>> get _buyers =>
      _firestore.collection('buyers');
  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');
  CollectionReference<Map<String, dynamic>> get _rfqs =>
      _firestore.collection('rfqs');
  CollectionReference<Map<String, dynamic>> get _enquiries =>
      _firestore.collection('enquiries');

  // ==========================================
  // Users (Artisans & Buyers)
  // ==========================================

  /// Get user profile document
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _users.doc(uid).get();
  }

  /// Create or update an Artisan profile
  Future<void> saveArtisanProfile(ArtisanModel artisan) async {
    // 1. Set user role entry in users/{uid}
    await _users.doc(artisan.uid).set({
      'uid': artisan.uid,
      'role': 'artisan',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Set artisan details in artisans/{uid}
    await _artisans.doc(artisan.uid).set({
      ...artisan.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Create or update a Buyer profile
  Future<void> saveBuyerProfile(BuyerModel buyer) async {
    // 1. Set user role entry in users/{uid}
    await _users.doc(buyer.uid).set({
      'uid': buyer.uid,
      'role': 'buyer',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Set buyer details in buyers/{uid}
    await _buyers.doc(buyer.uid).set({
      ...buyer.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream a specific Artisan profile
  Stream<ArtisanModel?> streamArtisan(String uid) {
    return _artisans.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ArtisanModel.fromMap(snap.data()!);
    });
  }

  // ==========================================
  // Products (Crafts Catalog)
  // ==========================================

  /// Create or upsert a product with idempotent localId as documentId (TRD.md §7)
  Future<void> saveProduct(ProductModel product) async {
    await _products.doc(product.localId).set({
      ...product.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream all live products for the Buyer Explore view
  Stream<List<ProductModel>> streamLiveProducts({
    String? craftType,
    bool onlyGiTagged = false,
  }) {
    Query<Map<String, dynamic>> query = _products
        .where('status', isEqualTo: 'live')
        .orderBy('createdAt', descending: true);

    if (craftType != null && craftType != 'All Crafts') {
      query = query.where('craftType', isEqualTo: craftType);
    }
    if (onlyGiTagged) {
      query = query.where('isVerified', isEqualTo: true);
    }

    return query.snapshots().map((snap) {
      return snap.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
    });
  }

  /// Stream products created by a specific artisan
  Stream<List<ProductModel>> streamArtisanProducts(String artisanId) {
    return _products
        .where('artisanId', isEqualTo: artisanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
    });
  }

  // ==========================================
  // RFQs (Request For Quotes)
  // ==========================================

  /// Submit a new RFQ from buyer
  Future<void> createRfq(RfqModel rfq) async {
    final docRef = _rfqs.doc(rfq.rfqId.isEmpty ? null : rfq.rfqId);
    await docRef.set({
      ...rfq.toMap(),
      'rfqId': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream active RFQs
  Stream<List<RfqModel>> streamActiveRfqs() {
    return _rfqs
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => RfqModel.fromMap(doc.data())).toList();
    });
  }

  // ==========================================
  // Enquiries (Direct Artisan Messages)
  // ==========================================

  /// Submit a direct craft enquiry
  Future<void> sendEnquiry(EnquiryModel enquiry) async {
    final docRef = _enquiries.doc(enquiry.enquiryId.isEmpty ? null : enquiry.enquiryId);
    await docRef.set({
      ...enquiry.toMap(),
      'enquiryId': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream enquiries received by an artisan
  Stream<List<EnquiryModel>> streamArtisanEnquiries(String artisanId) {
    return _enquiries
        .where('artisanId', isEqualTo: artisanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => EnquiryModel.fromMap(doc.data())).toList();
    });
  }

  /// Stream enquiries sent by a buyer
  Stream<List<EnquiryModel>> streamBuyerEnquiries(String buyerUid) {
    return _enquiries
        .where('buyerUid', isEqualTo: buyerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) => EnquiryModel.fromMap(doc.data())).toList();
    });
  }
}
