// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'पथ-शिल्प';

  @override
  String get appTagline => 'आपका शिल्प। आपका दाम। आपका नाम।';

  @override
  String get commonNext => 'अगला';

  @override
  String get commonBack => 'पीछे';

  @override
  String get commonCancel => 'रहने दें';

  @override
  String get commonConfirm => 'पक्का करें';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonRetry => 'फिर कोशिश करें';

  @override
  String get commonStay => 'यहीं रहें';

  @override
  String get commonLeave => 'बाहर जाएँ';

  @override
  String get commonAccept => 'स्वीकार करें';

  @override
  String get commonDecline => 'मना करें';

  @override
  String get commonSignOut => 'बाहर निकलें';

  @override
  String get commonSettings => 'सेटिंग';

  @override
  String get commonLanguage => 'भाषा';

  @override
  String get commonNotFound => 'यह पन्ना मौजूद नहीं है।';

  @override
  String get commonSampleData =>
      'नमूना जानकारी — असली जानकारी डेटाबेस जुड़ने पर आएगी।';

  @override
  String get authSignIn => 'अंदर आएँ';

  @override
  String get authPhoneTitle => 'आपका फ़ोन नंबर';

  @override
  String get authPhoneHint => '00000 00000';

  @override
  String get authPhoneInvalid => 'यह नंबर सही नहीं लगता।';

  @override
  String get authSendCode => 'कोड भेजें';

  @override
  String get authEnterCode => 'कोड डालें';

  @override
  String get authOtpTitle => 'छह अंकों का कोड डालें';

  @override
  String authSentTo(String phone) {
    return '$phone पर भेजा गया';
  }

  @override
  String get authOtpInvalid => 'यह कोड सही नहीं है।';

  @override
  String get authVerify => 'जाँचें';

  @override
  String get authDemoNotice =>
      'एसएमएस से कोड भेजा गया है। आने में कुछ सेकंड लग सकते हैं।';

  @override
  String get roleQuestion => 'आप यहाँ क्यों आए हैं?';

  @override
  String get roleIMakeThings => 'मैं बनाता/बनाती हूँ';

  @override
  String get roleIWantToBuy => 'मुझे खरीदना है';

  @override
  String get roleChooseOnce => 'यह चुनाव एक ही बार होगा।';

  @override
  String get navHome => 'घर';

  @override
  String get navProducts => 'सामान';

  @override
  String get navEnquiries => 'पूछताछ';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get navAdd => 'जोड़ें';

  @override
  String get navExplore => 'देखें';

  @override
  String get navRfq => 'दाम पूछें';

  @override
  String get homeGreeting => 'नमस्ते';

  @override
  String get homeWelcome => 'आपका स्वागत है';

  @override
  String get homeAddPromptTitle => '90 सेकंड में सामान जोड़ें';

  @override
  String get homeAddPromptBody =>
      'तस्वीर लें, बोलें, हो गया — बिना इंटरनेट भी काम करता है।';

  @override
  String get homeYourProducts => 'आपका सामान';

  @override
  String get productsTitle => 'आपका सामान';

  @override
  String get productsEmpty =>
      'अभी कोई सामान नहीं। पहली सूची बनाने के लिए जोड़ें दबाएँ।';

  @override
  String get enquiriesTitle => 'पूछताछ';

  @override
  String enquiriesQuantity(int count) {
    return '$count नग';
  }

  @override
  String get enquiriesEmpty => 'अभी कोई पूछताछ नहीं।';

  @override
  String get profileYourStory => 'आपकी कहानी';

  @override
  String profileYearsOfPractice(int years) {
    return '$years साल का अनुभव';
  }

  @override
  String get profileVerified => 'सत्यापित';

  @override
  String get profileGiTag => 'जीआई टैग';

  @override
  String get profileHandloom => 'हथकरघा';

  @override
  String get settingsTitle => 'सेटिंग';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageBody => 'यह पूरे ऐप की भाषा बदल देता है।';

  @override
  String get settingsAbout => 'ऐप के बारे में';

  @override
  String settingsVersion(String version) {
    return 'संस्करण $version';
  }

  @override
  String get addStepPhoto => 'तस्वीर';

  @override
  String get addStepSpeak => 'बोलें';

  @override
  String get addStepCosts => 'लागत';

  @override
  String get addStepReview => 'जाँचें';

  @override
  String get addLeaveTitle => 'बिना प्रकाशित किए बाहर जाएँ?';

  @override
  String get addLeaveBody =>
      'आपका काम इस फ़ोन में सुरक्षित है। बाद में पूरा कर सकते हैं।';

  @override
  String get addSavedOffline => 'बिना इंटरनेट सहेजा गया';

  @override
  String get photoTitle => 'अपने शिल्प की तस्वीर लें';

  @override
  String get photoNone => 'अभी कोई तस्वीर नहीं';

  @override
  String get photoGallery => 'गैलरी';

  @override
  String get photoCamera => 'कैमरा';

  @override
  String get photoRetake => 'फिर से लें';

  @override
  String get photoGood => 'तस्वीर अच्छी है';

  @override
  String get photoPoor => 'तस्वीर साफ़ नहीं है — फिर से लें';

  @override
  String get photoCameraUnavailable =>
      'कैमरा यहाँ उपलब्ध नहीं है। गैलरी से चुनें।';

  @override
  String get photoOpenFailed => 'यह तस्वीर नहीं खुली। दूसरी चुनें।';

  @override
  String get voiceTitle => 'इसके बारे में बताइए';

  @override
  String get voiceSubtitle => 'अपनी भाषा में बोलें।';

  @override
  String get voiceListening => 'सुन रहे हैं…';

  @override
  String get voiceTapToSpeak => 'बोलने के लिए दबाएँ';

  @override
  String get voiceUnavailableTitle => 'इस फ़ोन में बोलकर लिखना उपलब्ध नहीं है';

  @override
  String get voiceUnavailableBody =>
      'नीचे जानकारी भरें — आपकी सूची फिर भी बनेगी।';

  @override
  String get voiceTypeInstead => 'या यहाँ लिखें';

  @override
  String get voiceTypeHint => 'जैसे: नीली रेशमी चंदेरी साड़ी, हाथ से बुनी';

  @override
  String get voiceOpenSettings => 'ऐप की सेटिंग खोलें';

  @override
  String get costsTitle => 'इसमें कितना खर्च हुआ?';

  @override
  String get costsMaterial => 'सामान की लागत';

  @override
  String get costsHours => 'कितने घंटे लगे';

  @override
  String get costsHoursSuffix => 'घंटे';

  @override
  String get costsSeePrice => 'मेरा दाम देखें';

  @override
  String get costsMaterials => 'सामान';

  @override
  String costsYourLabour(int hours, int rate) {
    return 'आपकी मेहनत · $hours × ₹$rate';
  }

  @override
  String get costsFairWageNote =>
      'आपके समय का पूरा दाम जोड़ा जाता है — कभी शून्य नहीं।';

  @override
  String get reviewTitle => 'जाँचें और प्रकाशित करें';

  @override
  String get reviewOfflineDraft => 'बिना इंटरनेट सहेजा';

  @override
  String get reviewWrittenByAi => 'आपके बताए अनुसार एआई ने लिखा';

  @override
  String get reviewWrittenOffline =>
      'बिना इंटरनेट लिखा गया — इंटरनेट आने पर बेहतर होगा';

  @override
  String get reviewYourPrice => 'आपका दाम';

  @override
  String get reviewYouWillSellAt => 'आप इस दाम पर बेचेंगे';

  @override
  String reviewPriceFloorNote(int floor) {
    return 'आप ₹$floor तक कोई भी दाम चुन सकते हैं। इससे कम पर नुकसान होगा।';
  }

  @override
  String get reviewPublish => 'प्रकाशित करें';

  @override
  String get reviewPriceLocked => 'इसके बाद आपका दाम नहीं बदलेगा।';

  @override
  String get priceFloor => 'कम से कम';

  @override
  String get priceSuggested => 'सुझाया गया';

  @override
  String get priceMaximum => 'ज़्यादा से ज़्यादा';

  @override
  String priceReasoning(int materials, int hours, int rate, int labour) {
    return 'सामान ₹$materials और $hours घंटे की मेहनत ₹$rate प्रति घंटे के हिसाब से (₹$labour)। आपको कम से कम दाम से कम नहीं मिलेगा।';
  }

  @override
  String get syncSavedOnPhone => 'इस फ़ोन में सहेजा';

  @override
  String get syncQueued => 'भेजने की प्रतीक्षा';

  @override
  String get syncSyncing => 'भेजा जा रहा है';

  @override
  String get syncUpgraded => 'बेहतर किया गया';

  @override
  String get syncLive => 'प्रकाशित';

  @override
  String get buyerShellTitle => 'खरीदार';

  @override
  String get buyerNotInWorkstream => 'खरीदार वाला हिस्सा अलग से बन रहा है।';

  @override
  String get buyerNotInWorkstreamBody =>
      'दोनों हिस्से एक ही ऐप में आएँगे। यह बिल्ड कारीगर के लिए है।';

  @override
  String get buyerTagline =>
      'ग्रामीण कारीगरों से सीधा व्यापार, बिना इंटरनेट भी';

  @override
  String get buyerFairTrade => 'उचित व्यापार';

  @override
  String get buyerBulkRfq => 'थोक माँग';

  @override
  String get buyerViewStorefront => 'दुकान देखें';

  @override
  String get buyerAllCrafts => 'सभी शिल्प';

  @override
  String get buyerDirectConnect => 'कारीगर से सीधा संपर्क';

  @override
  String get buyerHeritageTreasures => 'विरासती हस्तशिल्प';

  @override
  String get buyerSearchHint => 'शिल्प, जीआई टैग या क्लस्टर से खोजें...';

  @override
  String get buyerGiTaggedOnly => 'केवल जीआई टैग';

  @override
  String get buyerCurated => 'चुनिंदा';

  @override
  String get buyerPriceLowToHigh => 'दाम: कम से ज़्यादा';

  @override
  String get buyerHoursOfCraftLabel => 'श्रम के घंटे';

  @override
  String get buyerResetFilters => 'सभी फ़िल्टर हटाएँ';

  @override
  String get buyerQuantityRequired => 'कितनी मात्रा चाहिए:';

  @override
  String get buyerSavedToBookmarks => 'आपके संग्रह में सहेजा गया';

  @override
  String get buyerRemovedFromSaved => 'संग्रह से हटाया गया';

  @override
  String get buyer100Direct => '100% सीधा';

  @override
  String get buyerMaterialCost => 'सामान और ढुलाई की लागत:';

  @override
  String get buyerPackagingOverhead => 'पैकिंग और क्लस्टर खर्च:';

  @override
  String get buyerDirectFairPrice => 'सीधा उचित दाम:';

  @override
  String get buyerMoreFromCluster => 'इसी क्लस्टर के और शिल्प';

  @override
  String get buyerSendEnquiry => 'सीधी पूछताछ भेजें';

  @override
  String get buyerEnquiryNote => 'बिना कमीशन और बिचौलिये के सीधी बातचीत।';

  @override
  String get buyerEnquiryHint => 'कारीगर के लिए नाप, सवाल या जानकारी लिखें...';

  @override
  String get buyerYourMessage => 'आपका संदेश:';

  @override
  String get buyerAcceptedByArtisan => 'कारीगर ने स्वीकार किया';

  @override
  String get buyerAwaitingReply => 'जवाब का इंतज़ार';

  @override
  String get buyerAccepted => 'स्वीकृत';

  @override
  String get buyerSent => 'भेजा गया';

  @override
  String get buyerTapForDetails => 'जानकारी और कॉल के लिए दबाएँ';

  @override
  String get buyerBulkAndCustomRfqs => 'थोक और विशेष माँग';

  @override
  String get buyerRfqForm => 'दाम पूछने का फ़ॉर्म';

  @override
  String get buyerBudgetBracket => 'बजट सीमा (₹):';

  @override
  String get buyerNewRfq => 'नई माँग';

  @override
  String get buyerNoActiveRfqs => 'कोई सक्रिय माँग नहीं';

  @override
  String get buyerQuotationsReceived => 'दाम मिल गए';

  @override
  String get buyerActiveSourcing => 'चल रही खोज';

  @override
  String get buyerQuantity => 'मात्रा';

  @override
  String get buyerDeadline => 'अंतिम तिथि';

  @override
  String get buyerBudget => 'बजट';

  @override
  String get buyerCraftHeritage => 'शिल्प विरासत';

  @override
  String get buyerHandmadeLive => 'हाथ से बना';

  @override
  String get buyerDirectFairRating => 'सीधी उचित रेटिंग';

  @override
  String get buyerHeritageStory => 'विरासत की कहानी';

  @override
  String get buyerVoiceNote => 'आवाज़ में';

  @override
  String get buyerAudioPaused => 'आवाज़ रोक दी गई।';

  @override
  String get buyerProfileTitle => 'खरीदार प्रोफ़ाइल';

  @override
  String get buyerSwitchRole => 'भूमिका बदलें';

  @override
  String buyerYearsPractice(int years) {
    return '$years वर्ष';
  }

  @override
  String buyerHoursCraft(int hours) {
    return '$hours घंटे श्रम';
  }

  @override
  String buyerHoursOfCraftCount(int hours) {
    return '$hours घंटे का श्रम';
  }

  @override
  String buyerFairWageLine(int hours, int rate) {
    return 'उचित मज़दूरी ($hours घंटे × ₹$rate):';
  }

  @override
  String buyerDirectEnquiryTo(String name) {
    return '$name को सीधी पूछताछ';
  }

  @override
  String buyerPcs(int count) {
    return '$count नग';
  }

  @override
  String get buyerHeritageSubtitle =>
      'पारदर्शी उचित मज़दूरी, सीधे जीआई-टैग वाले ग्रामीण क्लस्टरों से।';

  @override
  String get buyerArtisanHeritageStory => 'कारीगर की विरासत की कहानी';

  @override
  String get buyerListenVoiceNote => 'कारीगर की आवाज़ सुनें';

  @override
  String get buyerListeningVoiceNote => 'आवाज़ सुनी जा रही है';

  @override
  String get buyerViewActiveRfqs => 'चल रही माँगें देखें';

  @override
  String get buyerCreateNewRfq => 'नई माँग बनाएँ';

  @override
  String get buyerCancelViewRfqs => 'रद्द करें और चल रही माँगें देखें';

  @override
  String get buyerEmailLabel => 'ईमेल:';

  @override
  String get buyerGstinVerified => 'जीएसटीआईएन सत्यापित:';

  @override
  String buyerRoleSourcing(String role) {
    return 'भूमिका: $role खरीद';
  }

  @override
  String get buyerSentEnquiries => 'भेजी गई पूछताछ';

  @override
  String get profileNotSignedIn => 'आप साइन इन नहीं हैं।';

  @override
  String get profileLoadFailed =>
      'आपकी प्रोफ़ाइल नहीं खुली। इंटरनेट जाँचें और फिर कोशिश करें।';

  @override
  String get profileIncomplete =>
      'आपकी प्रोफ़ाइल अभी बनी नहीं है। पंजीकरण पूरा करें।';

  @override
  String get profileNoStoryYet => 'आपने अभी अपनी कहानी नहीं जोड़ी है।';

  @override
  String get profileProductsListed => 'सूचीबद्ध सामान';

  @override
  String get profileRating => 'रेटिंग';

  @override
  String get profileIdentity => 'पहचान दस्तावेज़';

  @override
  String get profileIdentityNote =>
      'आपकी सुरक्षा के लिए केवल दस्तावेज़ का प्रकार सहेजा जाता है, नंबर कभी नहीं।';

  @override
  String get profileIdGstin => 'जीएसटीआईएन दिया गया';

  @override
  String get profileIdPan => 'पैन दिया गया';

  @override
  String get profileIdAadhaar => 'आधार / पहचान कार्ड दिया गया';

  @override
  String get profileIdNone => 'कोई पहचान दस्तावेज़ नहीं';

  @override
  String get infoTitle => 'इस ऐप के बारे में';

  @override
  String get infoSubtitle => 'यह क्या करता है और क्या नहीं';

  @override
  String get infoWhatThisIs => 'पथ-शिल्प क्या है';

  @override
  String get infoWhatThisIsBody =>
      'एक ऐसा साधन जो एक तस्वीर और बोले गए एक वाक्य से पूरी, उचित दाम वाली सूची बना देता है — बिना इंटरनेट भी। यह सूची बनाने का साधन है, दुकान नहीं।';

  @override
  String get infoHowPricing => 'आपका दाम कैसे बनता है';

  @override
  String get infoHowPricingBody =>
      'सामान + (घंटे × उचित मज़दूरी) + खर्च। कम से कम दाम वह है जिससे नीचे आपको नुकसान होगा। आप उससे ऊपर कोई भी दाम चुन सकते हैं, और पक्का करने के बाद वह कभी नहीं बदलेगा।';

  @override
  String get infoOffline => 'बिना इंटरनेट काम करना';

  @override
  String get infoOfflineBody =>
      'सामान जोड़ने का हर चरण बिना इंटरनेट काम करता है। आपका काम इस फ़ोन में सुरक्षित रहता है। इंटरनेट आने पर यह अपने आप भेजा जाता है, तस्वीर और शब्द बेहतर होते हैं — और आपका पक्का किया हुआ दाम वैसा ही रहता है।';

  @override
  String get infoPrivacy => 'आपकी निजता';

  @override
  String get infoPrivacyBody =>
      'हम केवल यह सहेजते हैं कि आपके पास कौन सा दस्तावेज़ है — नंबर कभी नहीं। कोई आधार या पैन नंबर कहीं नहीं रखा जाता। न कोई लोकेशन ट्रैकिंग, न कोई एनालिटिक्स। आप अपना सामान और तस्वीरें कभी भी हटा सकते हैं।';

  @override
  String get infoNotYet => 'यह ऐप अभी क्या नहीं करता';

  @override
  String get infoNotYetBody =>
      'इसमें कोई भुगतान या खरीद-प्रक्रिया नहीं है। खरीदार आपको पूछताछ भेजते हैं और आप उनसे सीधे सौदा तय करते हैं। जेम और ओएनडीसी पर प्रकाशन अभी केवल दिखावे के लिए है। यहाँ आपसे कोई कमीशन नहीं लिया जाता।';

  @override
  String get infoBuyerWhat => 'आप यहाँ क्या कर सकते हैं';

  @override
  String get infoBuyerWhatBody =>
      'शिल्प देखें, हर दाम कैसे बना यह जानें, कारीगर की कहानी पढ़ें, और उन्हें पूछताछ या थोक माँग भेजें। आप सीधे कारीगर से बात करते हैं।';

  @override
  String get infoBuyerNoCheckout => 'अभी खरीद-प्रक्रिया नहीं है';

  @override
  String get infoBuyerNoCheckoutBody =>
      'आज आप ऐप में भुगतान नहीं कर सकते। यहाँ का शिल्प ऑर्डर पर बनता है, इसलिए कारीगर भुगतान से पहले सामान और हफ़्तों की मेहनत लगाता है — इसके लिए एस्क्रो चाहिए ताकि उनके साथ न्याय हो। तब तक, पूछताछ आपको सीधे कारीगर से जोड़ती है।';

  @override
  String get infoFairTrade => 'दाम अलग क्यों दिखते हैं';

  @override
  String get infoFairTradeBody =>
      'हर दाम में कारीगर की सामान लागत और ₹150 प्रति घंटे की उचित मज़दूरी दिखती है। कुछ भी छिपा नहीं है और कोई बिचौलिया मुनाफ़ा नहीं जोड़ा जाता।';

  @override
  String get buyerActiveQuotations => 'चल रही माँगें';

  @override
  String get buyerNoActiveRfqsBody =>
      'कारीगरों तक सीधे पहुँचने के लिए पहली माँग बनाएँ।';

  @override
  String get buyerRfqLoadFailed => 'आपकी माँगें नहीं खुलीं। इंटरनेट जाँचें।';

  @override
  String get artisanRfqTitle => 'थोक माँगें';

  @override
  String get artisanRfqSubtitle => 'आपके शिल्प के लिए खरीदारों की माँगें';

  @override
  String get artisanRfqRespond => 'मैं यह बना सकता/सकती हूँ';

  @override
  String get artisanRfqResponded => 'आपने यह बनाने की पेशकश की है';

  @override
  String get artisanRfqSent => 'खरीदार को बता दिया गया है।';

  @override
  String get artisanRfqFailed => 'भेज नहीं पाए। इंटरनेट आने पर फिर कोशिश करें।';

  @override
  String get artisanRfqEmpty => 'अभी कोई थोक माँग नहीं';

  @override
  String get artisanRfqEmptyNoCraft =>
      'मिलती-जुलती माँगें देखने के लिए अपनी प्रोफ़ाइल में शिल्प जोड़ें।';

  @override
  String get artisanRfqLoadFailed => 'माँगें नहीं खुलीं। इंटरनेट जाँचें।';

  @override
  String get artisanTabEnquiries => 'पूछताछ';

  @override
  String get artisanTabRfqs => 'थोक माँगें';

  @override
  String artisanRfqEmptyBody(String craft) {
    return '$craft खोजने वाले खरीदार यहाँ दिखेंगे।';
  }

  @override
  String artisanRfqOtherResponses(int count) {
    return 'अब तक $count कारीगरों ने पेशकश की है';
  }

  @override
  String get errorVerificationExpired =>
      'यह कोड समाप्त हो गया है। नया कोड मँगाएँ।';

  @override
  String get errorNotSignedIn => 'आप साइन इन नहीं हैं। फिर से साइन इन करें।';

  @override
  String get profileIdDocOnFile => 'दस्तावेज़ की तस्वीर सुरक्षित है';

  @override
  String get profileIdDocMissing => 'दस्तावेज़ की तस्वीर नहीं जोड़ी गई';

  @override
  String get reviewEnhancingPhoto => 'फ़ोटो साफ़ की जा रही है…';

  @override
  String get reviewBackgroundRemoved => 'पृष्ठभूमि हटा दी गई';

  @override
  String get ttsListen => 'सुनें';

  @override
  String get ttsStop => 'रोकें';

  @override
  String get ttsUnavailable =>
      'इस फ़ोन में इस भाषा के लिए कोई आवाज़ उपलब्ध नहीं है।';

  @override
  String get rfqHeroTitle => 'ग्रामीण क्लस्टरों से सीधी खरीद';

  @override
  String get rfqHeroBody =>
      'बिना किसी बिचौलिये के कस्टम विशिष्टताएँ, थोक ऑर्डर या कॉर्पोरेट उपहार की माँग भेजें।';

  @override
  String get rfqSelectCraft => 'शिल्प श्रेणी चुनें';

  @override
  String get rfqTargetCluster => 'लक्षित क्लस्टर / क्षेत्र';

  @override
  String get rfqAllClusters => 'सभी क्लस्टर';

  @override
  String get rfqQuantityLabel => 'ऑर्डर मात्रा';

  @override
  String rfqPieces(int count) {
    return '$count नग';
  }

  @override
  String get rfqDeadlineLabel => 'डिलीवरी की अंतिम तिथि';

  @override
  String get rfqChooseDate => 'तिथि चुनें';

  @override
  String get rfqDeadlineNotSet => 'तय नहीं';

  @override
  String get rfqSpecsLabel => 'विशिष्टताएँ और अनुकूलन विवरण';

  @override
  String get rfqSpecsHint =>
      'रंग, माप, आकृतियाँ या पैकेजिंग की ज़रूरतें बताएँ…';

  @override
  String get rfqMatchNote =>
      'इस शिल्प के कारीगर आपकी माँग देखेंगे और बनाने की पेशकश कर सकेंगे।';

  @override
  String get rfqBroadcast => 'कारीगरों को अनुरोध भेजें';

  @override
  String get rfqNotesRequired => 'भेजने से पहले अपनी ज़रूरत बताएँ।';

  @override
  String get rfqSignInRequired =>
      'अनुरोध भेजने हेतु खरीदार के रूप में साइन इन करें।';

  @override
  String get rfqSent =>
      'अनुरोध भेजा गया। इस शिल्प के कारीगर अब उत्तर दे सकते हैं।';

  @override
  String get rfqSendFailed =>
      'अनुरोध नहीं भेजा जा सका। कनेक्शन जाँचकर पुनः प्रयास करें।';

  @override
  String get rfqStatusActive => 'सक्रिय खरीद';

  @override
  String get rfqStatusMatched => 'कोटेशन प्राप्त';

  @override
  String rfqPcs(int count) {
    return '$count नग';
  }

  @override
  String rfqRespondedCount(int count) {
    return '$count कारीगर यह बना सकते हैं';
  }

  @override
  String get languagePickerLabel => 'भाषा';

  @override
  String get publishLive => 'प्रकाशित। अब खरीदार इस शिल्प को देख सकते हैं।';

  @override
  String get publishKeptDraft =>
      'सर्वर से संपर्क नहीं हो सका। इसी फ़ोन में सहेजा गया - प्रकाशित करने हेतु दोबारा खोलें।';

  @override
  String get publishNoProfile =>
      'शिल्प प्रकाशित करने से पहले अपना कारीगर पंजीकरण पूरा करें।';

  @override
  String get publishNotSignedIn =>
      'प्रकाशित करने हेतु कारीगर के रूप में साइन इन करें।';

  @override
  String get productsEmptyBody =>
      'अपना पहला शिल्प फ़ोटो करने हेतु + बटन दबाएँ।';

  @override
  String get productsLoadFailed => 'आपके शिल्प लोड नहीं हो सके';

  @override
  String get enquiriesEmptyBody =>
      'जब कोई खरीदार आपके शिल्प के बारे में पूछेगा, वह यहाँ दिखेगा।';

  @override
  String get enquiriesLoadFailed => 'आपकी पूछताछ लोड नहीं हो सकी';

  @override
  String enquiryQuantity(int count) {
    return 'मात्रा: $count';
  }

  @override
  String enquiryFrom(String name) {
    return '$name की ओर से';
  }

  @override
  String get profileVerification => 'सत्यापन';

  @override
  String get profileUnverified => 'लंबित';

  @override
  String get rfqQueuedOffline =>
      'सहेजा गया। ऑनलाइन होते ही आपका अनुरोध कारीगरों तक पहुँच जाएगा।';

  @override
  String get productChangePrice => 'मूल्य बदलें';

  @override
  String get productPriceUpdated => 'मूल्य बदल दिया गया।';

  @override
  String get productActionFailed =>
      'यह पूरा नहीं हो सका। कनेक्शन जाँचकर पुनः प्रयास करें।';

  @override
  String get productUnlist => 'दुकान से हटाएँ';

  @override
  String get productRelist => 'दुकान में वापस लगाएँ';

  @override
  String get productUnlisted =>
      'दुकान से हटा दिया गया। अब खरीदार इसे नहीं देख सकते।';

  @override
  String get productRelisted => 'दुकान में वापस लगा दिया गया।';

  @override
  String get productListed => 'खरीदारों को दिख रहा है';

  @override
  String get productNotListed => 'खरीदारों से छिपा है';

  @override
  String get productDelete => 'मिटाएँ';

  @override
  String get productDeleteTitle => 'यह शिल्प मिटाएँ?';

  @override
  String get productDeleteBody =>
      'यह सूची हमेशा के लिए हट जाएगी। इसे वापस नहीं लाया जा सकता।';

  @override
  String get productMaterialCost => 'आपने सामग्री पर खर्च किया';

  @override
  String get productHoursOfWork => 'आपने कितने घंटे काम किया';

  @override
  String productLabourAtFairWage(int rate) {
    return '₹$rate/घंटा की दर से आपकी मेहनत';
  }

  @override
  String get productDescription => 'विवरण';

  @override
  String get profileSettingUp => 'आपकी खरीदार प्रोफ़ाइल तैयार की जा रही है…';

  @override
  String get profileSignInPrompt =>
      'अपनी प्रोफ़ाइल, सहेजे गए शिल्प और पूछताछ देखने हेतु खरीदार के रूप में साइन इन करें।';

  @override
  String get regListenInstructions => 'निर्देश सुनें';

  @override
  String get regListenInstructionsBody => 'यह चरण सुनने के लिए दबाएँ';

  @override
  String get regListenGuidance => 'चरण का मार्गदर्शन सुनें';

  @override
  String get commonContinue => 'आगे बढ़ें';

  @override
  String get regSubmit => 'पंजीकरण जमा करें';

  @override
  String get regStepLocation => 'स्थान और क्लस्टर';

  @override
  String get regStepCraft => 'शिल्प विशेषज्ञता';

  @override
  String get regStepStory => 'विरासत की कहानी';

  @override
  String get regSelectIdDoc => 'पहचान दस्तावेज़ चुनें';

  @override
  String get regAuthenticatedId => 'सत्यापित पहचान संख्या';

  @override
  String get regPrivacyGuarantee =>
      'गोपनीयता की गारंटी: हम आपकी पहचान सरकारी अभिलेखों से जाँचते हैं और केवल सत्यापन की स्थिति सहेजते हैं। आपका आधार या पैन नंबर कभी सार्वजनिक नहीं किया जाता, न बेचा जाता है।';

  @override
  String get regBadgeAadhaarTitle => 'आधार सत्यापित कारीगर';

  @override
  String get regBadgeAadhaarSub => 'भारतीय विशिष्ट पहचान प्राधिकरण';

  @override
  String get regBadgePanTitle => 'पैन सत्यापित';

  @override
  String get regBadgePanSub => 'आयकर विभाग, भारत सरकार';

  @override
  String get regBadgeGstinTitle => 'सक्रिय जीएसटीआईएन करदाता सत्यापित';

  @override
  String get regBadgeGstinSub => 'वस्तु एवं सेवा कर नेटवर्क';

  @override
  String get regSpeakDocNumber => 'दस्तावेज़ संख्या बोलें';

  @override
  String get regRescanVlm => 'फिर से स्कैन करें';

  @override
  String get commonGallery => 'गैलरी';

  @override
  String get regCameraFailed => 'कैमरा या गैलरी नहीं खुल सकी।';

  @override
  String get regStoryTitle => 'शिल्प विरासत की कहानी';

  @override
  String get regDictateStory => 'आवाज़ से कहानी बोलें';

  @override
  String get regProvenanceNote =>
      'आपकी प्रोफ़ाइल की क्लस्टर उत्पत्ति जाँची जाएगी। सत्यापन के बाद आपके शिल्प पर आधिकारिक जीआई या सत्यापित कारीगर बैज दिखेगा।';

  @override
  String get commonSpeakInput => 'बोलकर भरें';

  @override
  String get voiceTapMic => 'बोलने के लिए माइक दबाएँ';

  @override
  String get voiceSpeakClearly => 'अपनी बोली में स्पष्ट बोलें…';

  @override
  String get commonVoiceReadout => 'आवाज़ में सुनें';

  @override
  String get artisanAddCraft => 'शिल्प जोड़ें';

  @override
  String get artisanVoiceSearch => 'आवाज़ से खोजें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonClear => 'साफ़ करें';

  @override
  String get productListenPricing => 'मूल्य का विवरण सुनें';

  @override
  String get profileListenVerification => 'सत्यापन सुनें';
}
