import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/craft_taxonomy.dart';
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

  /// Read an artisan profile. Returns null when the artisan has not
  /// registered yet, so callers can distinguish "new" from "failed".
  Future<ArtisanModel?> getArtisan(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _artisans.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return ArtisanModel.fromMap(doc.data()!);
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

  /// Read a buyer profile. Null when the document does not exist yet, so
  /// callers can tell "not registered" from "read failed".
  Future<BuyerModel?> getBuyer(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _buyers.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return BuyerModel.fromMap(doc.data()!);
  }

  /// Stream a specific Buyer profile - drives the profile screen and the
  /// saved-crafts list, both of which change as the buyer taps around.
  Stream<BuyerModel?> streamBuyer(String uid) {
    return _buyers.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return BuyerModel.fromMap(snap.data()!);
    });
  }

  /// Add or remove a product from the buyer's saved list.
  ///
  /// Uses arrayUnion/arrayRemove rather than read-modify-write so saving from
  /// two devices at once cannot drop the other's change, and so tapping the
  /// same heart twice is idempotent.
  Future<void> setProductSaved({
    required String buyerUid,
    required String productId,
    required bool saved,
  }) {
    return _buyers.doc(buyerUid).set(<String, dynamic>{
      'savedProducts': saved
          ? FieldValue.arrayUnion(<String>[productId])
          : FieldValue.arrayRemove(<String>[productId]),
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

  /// Newest-first, the ordering every catalogue view uses.
  ///
  /// `createdAt` is written as an ISO-8601 string (ProductModel.toMap), so it
  /// would also sort correctly server-side - but pairing an `orderBy` with the
  /// `status` filter demands a composite index. Sorting here instead keeps the
  /// catalogue working against a project with no deployed indexes (TRD.md
  /// §4.2), the same trade-off [streamBuyerRfqs] makes.
  List<ProductModel> _newestFirst(QuerySnapshot<Map<String, dynamic>> snap) {
    final List<ProductModel> list =
        snap.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();
    list.sort(
        (ProductModel a, ProductModel b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Every live product, newest first, for the Buyer Explore view.
  ///
  /// `craftType` and `onlyGiTagged` are applied client-side for the same
  /// no-composite-index reason as the sort above. The catalogue is small
  /// enough that the saving is not worth an index deploy per filter combo.
  Stream<List<ProductModel>> streamLiveProducts({
    String? craftType,
    bool onlyGiTagged = false,
  }) {
    return _products
        .where('status', isEqualTo: 'live')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      return _newestFirst(snap).where((ProductModel p) {
        if (craftType != null &&
            craftType != CraftTaxonomy.all &&
            CraftTaxonomy.categoryFor(p.craftType) !=
                CraftTaxonomy.categoryFor(craftType)) {
          return false;
        }
        if (onlyGiTagged && (p.giTag == null || p.giTag!.isEmpty)) return false;
        return true;
      }).toList();
    });
  }

  /// One-shot read of the live catalogue - for "similar crafts" style panels
  /// that do not need to stay subscribed.
  Future<List<ProductModel>> fetchLiveProducts() async {
    final QuerySnapshot<Map<String, dynamic>> snap =
        await _products.where('status', isEqualTo: 'live').get();
    return _newestFirst(snap);
  }

  /// Live view of one product, for the artisan's own detail page.
  Stream<ProductModel?> streamProduct(String localId) {
    return _products.doc(localId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ProductModel.fromMap(snap.data()!);
    });
  }

  /// The artisan changing what they sell at.
  ///
  /// Only `priceFinal` moves. The floor, suggested and max are the output of
  /// the deterministic pricing formula (TRD.md §7) and must not drift, so the
  /// caller is responsible for refusing anything below `priceFloor` - selling
  /// under it loses the artisan money.
  Future<void> updateProductPrice({
    required String localId,
    required int priceFinal,
  }) {
    return _products.doc(localId).update(<String, dynamic>{
      'priceFinal': priceFinal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Take a product off the storefront, or put it back.
  ///
  /// `status` is what firestore.rules gates public reads on, so flipping it to
  /// anything other than 'live' immediately hides the product from buyers
  /// without deleting the artisan's work.
  Future<void> setProductStatus({
    required String localId,
    required String status,
  }) {
    return _products.doc(localId).update(<String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String localId) =>
      _products.doc(localId).delete();

  /// Stream products created by a specific artisan, newest first.
  Stream<List<ProductModel>> streamArtisanProducts(String artisanId) {
    return _products
        .where('artisanId', isEqualTo: artisanId)
        .snapshots()
        .map(_newestFirst);
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
      // `createdAt` deliberately comes from toMap() as an ISO-8601 string and
      // is NOT overwritten with a server timestamp: RfqModel.fromMap reads it
      // back with DateTime.tryParse, which cannot accept a Timestamp. The
      // server clock is recorded separately.
      'serverCreatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream a single buyer's own RFQs, newest first - what the buyer sees in
  /// their "Active RFQs" list.
  Stream<List<RfqModel>> streamBuyerRfqs(String buyerUid) {
    return _rfqs
        .where('buyerUid', isEqualTo: buyerUid)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<RfqModel> list =
          snap.docs.map((doc) => RfqModel.fromMap(doc.data())).toList();
      // Sorted client-side so this needs no composite index (TRD.md §4.2).
      list.sort((RfqModel a, RfqModel b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Open RFQs an artisan can actually fulfil, i.e. matching their craft.
  ///
  /// Filtered client-side on craft so this needs no composite index, and
  /// sorted newest-first (TRD.md §4.2).
  Stream<List<RfqModel>> streamOpenRfqsForCraft(String craft) {
    return _rfqs
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<RfqModel> list = snap.docs
          .map((doc) => RfqModel.fromMap(doc.data()))
          // Matched through CraftTaxonomy, not raw equality. A buyer picks a
          // category ('Metal Casting') while an artisan's profile may say
          // 'Dhokra & Metalware' or 'Dhokra Lost-Wax Metal Casting'; comparing
          // those literally - as this did - meant no RFQ ever reached anyone.
          .where((RfqModel r) =>
              craft.isEmpty || CraftTaxonomy.matches(r.craft, craft))
          .toList();
      list.sort((RfqModel a, RfqModel b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// An artisan signalling they can fulfil an RFQ.
  ///
  /// Uses arrayUnion so two artisans responding at once cannot clobber each
  /// other, and responding twice is idempotent.
  Future<void> respondToRfq({
    required String rfqId,
    required String artisanId,
  }) async {
    await _rfqs.doc(rfqId).update({
      'matchedArtisanIds': FieldValue.arrayUnion(<String>[artisanId]),
    });
  }

  /// Stream active RFQs, newest first (sorted client-side - see
  /// [streamBuyerRfqs] for why).
  Stream<List<RfqModel>> streamActiveRfqs() {
    return _rfqs
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snap) {
      final List<RfqModel> list =
          snap.docs.map((doc) => RfqModel.fromMap(doc.data())).toList();
      list.sort((RfqModel a, RfqModel b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ==========================================
  // Enquiries (Direct Artisan Messages)
  // ==========================================

  /// Submit a direct craft enquiry
  Future<void> sendEnquiry(EnquiryModel enquiry) async {
    final docRef =
        _enquiries.doc(enquiry.enquiryId.isEmpty ? null : enquiry.enquiryId);
    await docRef.set({
      ...enquiry.toMap(),
      'enquiryId': docRef.id,
      // As in [createRfq]: `createdAt` stays the ISO-8601 string from toMap(),
      // because EnquiryModel.fromMap parses it with DateTime.tryParse and a
      // Timestamp would throw on read.
      'serverCreatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Newest-first, sorted client-side so no composite index is needed for the
  /// `where` + order pairing (TRD.md §4.2).
  List<EnquiryModel> _enquiriesNewestFirst(
      QuerySnapshot<Map<String, dynamic>> snap) {
    final List<EnquiryModel> list =
        snap.docs.map((doc) => EnquiryModel.fromMap(doc.data())).toList();
    list.sort(
        (EnquiryModel a, EnquiryModel b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Stream enquiries received by an artisan, newest first.
  Stream<List<EnquiryModel>> streamArtisanEnquiries(String artisanId) {
    return _enquiries
        .where('artisanId', isEqualTo: artisanId)
        .snapshots()
        .map(_enquiriesNewestFirst);
  }

  /// Stream enquiries sent by a buyer, newest first.
  Stream<List<EnquiryModel>> streamBuyerEnquiries(String buyerUid) {
    return _enquiries
        .where('buyerUid', isEqualTo: buyerUid)
        .snapshots()
        .map(_enquiriesNewestFirst);
  }
}
