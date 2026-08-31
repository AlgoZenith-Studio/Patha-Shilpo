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
      'यह नमूना ऐप है: कोई भी छह अंक चलेंगे। फ़ोन जाँच अभी नहीं जुड़ी है।';

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
}
