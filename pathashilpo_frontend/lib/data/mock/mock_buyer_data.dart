import '../models/artisan_model.dart';
import '../models/product_model.dart';
import '../models/enquiry_model.dart';
import '../models/rfq_model.dart';
import '../models/buyer_model.dart';

class MockBuyerData {
  MockBuyerData._();

  static final BuyerModel currentBuyer = BuyerModel(
    uid: 'buyer_001',
    name: 'Ananya Roy',
    phone: '+91 98765 43210',
    email: 'ananya.roy@heritagecrafts.in',
    buyerType: 'b2b',
    company: 'Sanskritik Boutique & Exports',
    gstin: '07AAAAA0000A1Z5',
    interests: [
      'Handloom Weaving',
      'Terracotta Pottery',
      'Dhokra Metal',
      'Madhubani Art'
    ],
    states: ['Madhya Pradesh', 'West Bengal', 'Chhattisgarh', 'Bihar'],
    savedProducts: ['prod_001', 'prod_003'],
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
  );

  static final List<ArtisanModel> artisans = [
    ArtisanModel(
      uid: 'artisan_001',
      name: 'Rameshwar Lal Koli',
      nameHi: 'रामेश्वर लाल कोली',
      village: 'Pranpur',
      district: 'Ashoknagar',
      state: 'Madhya Pradesh',
      craft: 'Chanderi Handloom Weaving',
      cluster: 'Chanderi',
      giTag: 'GI-IN-007 (Chanderi Fabric)',
      story:
          'Carrying forward a 4th-generation legacy of weaving featherlight silk-cotton Chanderi sarees on traditional pit looms with real zari motifs inspired by Mughal architecture.',
      storyHi:
          'पारंपरिक गड्ढा करघे (Pit Loom) पर 4 पीढ़ियों से रेशम और सूती चंदेरी साड़ियाँ बुनने की अद्भुत विरासत, जिसमें असली ज़री के बारीक काम हैं।',
      yearsOfPractice: 32,
      photoUrl:
          'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&q=80&w=400',
      verified: true,
      productCount: 14,
      rating: 4.95,
      audioStoryUrl:
          'https://actions.google.com/sounds/v1/ambiences/humming_meditation.ogg',
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
    ArtisanModel(
      uid: 'artisan_002',
      name: 'Gita Rani Kumbhakar',
      nameHi: 'गीता रानी कुंभार',
      village: 'Panchmura',
      district: 'Bankura',
      state: 'West Bengal',
      craft: 'Terracotta Sculpting',
      cluster: 'Bankura Terracotta',
      giTag: 'GI-IN-035 (Bankura Horse)',
      story:
          'Sculpting celebrated Bankura terracotta horses and ceremonial urns with alluvium clay from the Dwarakeswar riverbed, sun-baked and kiln-fired in wood chambers.',
      storyHi:
          'द्वारकेश्वर नदी की चिकनी मिट्टी से प्रसिद्ध बांकुड़ा मिट्टी के घोड़े और अनुष्ठानिक कलश बनाने में पारंगत। धूप में सुखाकर पारंपरिक भट्टी में पकाया जाता है।',
      yearsOfPractice: 24,
      photoUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=400',
      verified: true,
      productCount: 8,
      rating: 4.88,
      createdAt: DateTime.now().subtract(const Duration(days: 210)),
    ),
    ArtisanModel(
      uid: 'artisan_003',
      name: 'Mangal Singh Ghadwa',
      nameHi: 'मंगल सिंह घडवा',
      village: 'Kondagaon',
      district: 'Bastar',
      state: 'Chhattisgarh',
      craft: 'Dhokra Lost-Wax Metal Casting',
      cluster: 'Bastar Dhokra',
      giTag: 'GI-IN-083 (Bastar Dhokra)',
      story:
          'Master of non-ferrous lost-wax metal casting using natural beeswax threads, river clay core, and recycled brass bell metal to craft tribal deities and forest motifs.',
      storyHi:
          'मधुमक्खी के मोम और कांस्य मिश्र धातु से 4000 वर्ष पुरानी लॉस्ट-वैक्स पद्धति द्वारा अद्वितीय जनजातीय शिल्प व आकृतियों का निर्माण।',
      yearsOfPractice: 28,
      photoUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
      verified: true,
      productCount: 19,
      rating: 4.92,
      createdAt: DateTime.now().subtract(const Duration(days: 420)),
    ),
    ArtisanModel(
      uid: 'artisan_004',
      name: 'Shanti Devi Paswan',
      nameHi: 'शांति देवी पासवान',
      village: 'Ranti',
      district: 'Madhubani',
      state: 'Bihar',
      craft: 'Madhubani Mithila Painting',
      cluster: 'Mithila',
      giTag: 'GI-IN-028 (Madhubani Art)',
      story:
          'Painting auspicious Kohbar and nature scenes using handmade bamboo twigs (qalam) and pure organic plant dyes extracted from marigold, turmeric, and neem.',
      storyHi:
          'नीम और हल्दी के प्राकृतिक रंगों तथा बांस की कलम से प्राचीन मिथिला लोककला को हस्तनिर्मित सूती वस्त्रों पर उकेरने वाली प्रतिष्ठित कलाकार।',
      yearsOfPractice: 36,
      photoUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
      verified: true,
      productCount: 12,
      rating: 4.98,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
    ),
  ];

  static final List<ProductModel> products = [
    ProductModel(
      productId: 'prod_001',
      localId: 'loc_001',
      artisanId: 'artisan_001',
      artisanName: 'Rameshwar Lal Koli',
      artisanCluster: 'Chanderi, Ashoknagar (MP)',
      artisanState: 'Madhya Pradesh',
      artisanPhotoUrl:
          'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&q=80&w=400',
      imageUrl:
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800',
      title: 'Handspun Chanderi Silk Saree with Real Zari Booti',
      titleHi: 'असली ज़री बूटी वाली हाथ से बुनी चंदेरी सिल्क साड़ी',
      description:
          'Exquisitely handwoven over 52 hours on a pit loom using pure Mulberry silk and certified zari threads. Features intricate ashrafi motifs with featherweight drape and sheer golden luster.',
      descriptionHi:
          'शुद्ध शहतूत रेशम और प्रमाणित ज़री के धागों से गड्ढा करघे पर 52 घंटे में बुनी गई। इसमें बारीक अशरफी बूटियाँ और मनमोहक सुनहरा पल्लू है।',
      tags: [
        'handloom',
        'saree',
        'chanderi',
        'silk',
        'zari',
        'heritage',
        'gi-tagged'
      ],
      material: 'Pure Mulberry Silk & Cotton (80s count)',
      craftType: 'Handloom Weaving',
      colors: ['Mustard Gold', 'Raw Silk Ivory', 'Deep Rust'],
      hoursOfWork: 52,
      materialCost: 2850,
      priceFloor: 4800,
      priceSuggested: 5800,
      priceMax: 7200,
      priceFinal: 5800,
      priceReasoning:
          'Fair wage of ₹150/hr × 52 hrs (₹7,800 labor) + raw silk cost ₹2,850 + 15% overhead. 100% direct to artisan.',
      priceReasoningHi:
          'कारीगर हेतु निष्पक्ष पारिश्रमिक ₹150/घंटा × 52 घंटे + ₹2,850 कच्चा माल। बिचौलियों से मुक्त सीधी आय।',
      giTag: 'GI-IN-007 (Chanderi)',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ProductModel(
      productId: 'prod_002',
      localId: 'loc_002',
      artisanId: 'artisan_002',
      artisanName: 'Gita Rani Kumbhakar',
      artisanCluster: 'Bankura, Panchmura (WB)',
      artisanState: 'West Bengal',
      artisanPhotoUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=400',
      imageUrl:
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&q=80&w=800',
      title: 'Majestic Bankura Terracotta Temple Horse (22 Inch)',
      titleHi: 'भव्य बांकुड़ा टेराकोटा मंदिर अश्व (22 इंच)',
      description:
          'Symbol of sacred devotion and artistic geometry, featuring erect ears, pointed snout, and hollow clay body fired in a wood-fueled earthen kiln. Sourced from alluvium claybeds.',
      descriptionHi:
          'बांकुड़ा पंचमुड़ा की विश्वप्रसिद्ध टेराकोटा कलाकृति। प्राकृतिक नदीय चिकनी मिट्टी से हस्तनिर्मित और पारंपरिक भट्टी में पकाया गया।',
      tags: [
        'terracotta',
        'pottery',
        'bankura',
        'clay',
        'sculpture',
        'decor',
        'gi-tagged'
      ],
      material: 'Alluvial River Clay & Natural Earth Pigments',
      craftType: 'Terracotta Pottery',
      colors: ['Terracotta Orange', 'Earthy Umber', 'Burnt Ochre'],
      hoursOfWork: 18,
      materialCost: 450,
      priceFloor: 1600,
      priceSuggested: 1950,
      priceMax: 2400,
      priceFinal: 1950,
      priceReasoning:
          'Fair wage ₹150/hr × 18 hrs + kiln firing materials ₹450 + careful straw packaging overhead.',
      priceReasoningHi:
          'निष्पक्ष पारिश्रमिक ₹150/घंटा × 18 घंटे + ₹450 मिट्टी व भट्टी लागत।',
      giTag: 'GI-IN-035 (Bankura Horse)',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ProductModel(
      productId: 'prod_003',
      localId: 'loc_003',
      artisanId: 'artisan_003',
      artisanName: 'Mangal Singh Ghadwa',
      artisanCluster: 'Bastar, Kondagaon (CG)',
      artisanState: 'Chhattisgarh',
      artisanPhotoUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=400',
      imageUrl:
          'https://images.unsplash.com/photo-1582562124811-c09040d0a901?auto=format&fit=crop&q=80&w=800',
      title: 'Bastar Dhokra Brass Lost-Wax Tribal Musician Figurine',
      titleHi: 'बस्तर ढोकरा कांस्य खोया-मोम जनजातीय संगीतकार मूर्ति',
      description:
          'Cast using ancient non-ferrous lost-wax technique with wax threads and clay mould. Each piece is unique because the clay mould is broken during bronze recovery.',
      descriptionHi:
          '4000 वर्ष पुरानी ढोकरा पद्धति से निर्मित पीतल व कांस्य की अनूठी मूर्ति। प्रत्येक कृति अद्वितीय होती है क्योंकि इसका सांचा एक बार ही उपयोग होता है।',
      tags: [
        'dhokra',
        'metalcraft',
        'bastar',
        'brass',
        'tribal',
        'lost-wax',
        'gi-tagged'
      ],
      material: 'Recycled Bell Metal Brass & Natural Beeswax',
      craftType: 'Metal Casting',
      colors: ['Antique Brass Gold', 'Verdigris Patina', 'Dark Earth'],
      hoursOfWork: 26,
      materialCost: 980,
      priceFloor: 2800,
      priceSuggested: 3450,
      priceMax: 4200,
      priceFinal: 3450,
      priceReasoning:
          '26 hours of intricate beeswax thread coiling + bell metal alloy ₹980 + charcoal kiln expenses.',
      priceReasoningHi: '26 घंटे की कठिन मोम नक्काशी + ₹980 कांस्य धातु लागत।',
      giTag: 'GI-IN-083 (Bastar Dhokra)',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    ProductModel(
      productId: 'prod_004',
      localId: 'loc_004',
      artisanId: 'artisan_004',
      artisanName: 'Shanti Devi Paswan',
      artisanCluster: 'Mithila, Madhubani (BR)',
      artisanState: 'Bihar',
      artisanPhotoUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=400',
      imageUrl:
          'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&q=80&w=800',
      title: 'Hand-painted Madhubani Mithila Tree of Life Stole',
      titleHi: 'हस्त-चित्रित मधुबनी मिथिला कल्पवृक्ष दुपट्टा',
      description:
          'Painted on handwoven tussar silk using natural dyes made from turmeric, Indigo, and neem leaves. Features the sacred Tree of Life and mating birds symbolising prosperity.',
      descriptionHi:
          'शुद्ध टसर रेशम पर बांस की कलम से प्राकृतिक रंगों द्वारा चित्रित कल्पवृक्ष व प्रकृति के मांगलिक दृश्य।',
      tags: [
        'madhubani',
        'painting',
        'mithila',
        'tussar',
        'stole',
        'natural-dyes',
        'gi-tagged'
      ],
      material: 'Wild Tussar Silk & Organic Plant Extracts',
      craftType: 'Folk Art Painting',
      colors: [
        'Tussar Golden Beige',
        'Indigo Blue',
        'Turmeric Yellow',
        'Kohl Black'
      ],
      hoursOfWork: 30,
      materialCost: 1400,
      priceFloor: 3200,
      priceSuggested: 3900,
      priceMax: 4800,
      priceFinal: 3900,
      priceReasoning:
          '30 hours fine brushwork with organic plant pigments + wild tussar fabric ₹1,400.',
      priceReasoningHi:
          '30 घंटे की सूक्ष्म कलमकारी व प्राकृतिक रंग + ₹1,400 टसर सिल्क।',
      giTag: 'GI-IN-028 (Madhubani)',
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final List<EnquiryModel> initialEnquiries = [
    EnquiryModel(
      enquiryId: 'enq_101',
      productId: 'prod_001',
      productTitle: 'Handspun Chanderi Silk Saree with Real Zari Booti',
      productImageUrl:
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&q=80&w=800',
      artisanId: 'artisan_001',
      artisanName: 'Rameshwar Lal Koli',
      buyerUid: 'buyer_001',
      buyerName: 'Ananya Roy',
      buyerPhone: '+91 98765 43210',
      buyerType: 'b2b',
      quantity: 5,
      message:
          'Looking to purchase 5 pieces for our festive Diwali collection. Could you customize in emerald green pallu?',
      status: 'accepted',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EnquiryModel(
      enquiryId: 'enq_102',
      productId: 'prod_003',
      productTitle: 'Bastar Dhokra Brass Lost-Wax Tribal Musician Figurine',
      productImageUrl:
          'https://images.unsplash.com/photo-1582562124811-c09040d0a901?auto=format&fit=crop&q=80&w=800',
      artisanId: 'artisan_003',
      artisanName: 'Mangal Singh Ghadwa',
      buyerUid: 'buyer_001',
      buyerName: 'Ananya Roy',
      buyerPhone: '+91 98765 43210',
      buyerType: 'b2b',
      quantity: 2,
      message:
          'Inquiring about delivery timeline to New Delhi and wooden base mounting options.',
      status: 'new',
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
    ),
  ];

  static final List<RfqModel> initialRfqs = [
    RfqModel(
      rfqId: 'rfq_201',
      buyerUid: 'buyer_001',
      buyerName: 'Ananya Roy (Sanskritik Boutique)',
      craft: 'Handloom Weaving',
      cluster: 'Chanderi',
      quantity: 25,
      deadline: '15 Oct 2026',
      budgetMin: 120000,
      budgetMax: 150000,
      matchedArtisanIds: ['artisan_001'],
      status: 'matched',
      notes:
          'Require pure silk-cotton mix sarees with custom temple border weave for corporate gifting.',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  /// Filter chips on the buyer explore screen. Still a static list rather than
  /// a Firestore read: these are the categories the app *offers*, not the ones
  /// that happen to have stock today, so an empty category must stay selectable.
  /// Every value here must match a `craftType` written by the seeder
  /// (pathashilpo_backend/scripts/seed_data.json) or products will be filtered
  /// out of a category that never matches.
  static final List<String> craftCategories = [
    'All Crafts',
    'Handloom Weaving',
    'Terracotta Pottery',
    'Metal Casting',
    'Folk Art Painting',
    'Contemporary Art',
    'Wood Carving',
    'Bamboo Craft',
  ];
}
