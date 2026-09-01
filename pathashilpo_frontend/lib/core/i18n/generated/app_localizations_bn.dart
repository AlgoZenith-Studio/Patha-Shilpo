// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'পাথ-শিল্প';

  @override
  String get appTagline => 'আপনার শিল্প। আপনার দাম। আপনার নাম।';

  @override
  String get commonNext => 'পরবর্তী';

  @override
  String get commonBack => 'পিছনে';

  @override
  String get commonCancel => 'বাতিল';

  @override
  String get commonConfirm => 'নিশ্চিত করুন';

  @override
  String get commonSave => 'সংরক্ষণ';

  @override
  String get commonRetry => 'আবার চেষ্টা করুন';

  @override
  String get commonStay => 'এখানেই থাকুন';

  @override
  String get commonLeave => 'বেরিয়ে যান';

  @override
  String get commonAccept => 'গ্রহণ করুন';

  @override
  String get commonDecline => 'প্রত্যাখ্যান';

  @override
  String get commonSignOut => 'বেরিয়ে যান';

  @override
  String get commonSettings => 'সেটিংস';

  @override
  String get commonLanguage => 'ভাষা';

  @override
  String get commonNotFound => 'এই পাতাটি নেই।';

  @override
  String get commonSampleData =>
      'নমুনা তথ্য — ডেটাবেস যুক্ত হলে আসল তথ্য আসবে।';

  @override
  String get authSignIn => 'প্রবেশ করুন';

  @override
  String get authPhoneTitle => 'আপনার ফোন নম্বর';

  @override
  String get authPhoneHint => '00000 00000';

  @override
  String get authPhoneInvalid => 'এই নম্বরটি সঠিক মনে হচ্ছে না।';

  @override
  String get authSendCode => 'কোড পাঠান';

  @override
  String get authEnterCode => 'কোড দিন';

  @override
  String get authOtpTitle => 'ছয় অঙ্কের কোড দিন';

  @override
  String authSentTo(String phone) {
    return '$phone এ পাঠানো হয়েছে';
  }

  @override
  String get authOtpInvalid => 'এই কোডটি সঠিক নয়।';

  @override
  String get authVerify => 'যাচাই করুন';

  @override
  String get authDemoNotice =>
      'এসএমএসে কোড পাঠানো হয়েছে। আসতে কয়েক সেকেন্ড লাগতে পারে।';

  @override
  String get roleQuestion => 'আপনি কেন এসেছেন?';

  @override
  String get roleIMakeThings => 'আমি তৈরি করি';

  @override
  String get roleIWantToBuy => 'আমি কিনতে চাই';

  @override
  String get roleChooseOnce => 'এই পছন্দ একবারই করা যাবে।';

  @override
  String get navHome => 'বাড়ি';

  @override
  String get navProducts => 'পণ্য';

  @override
  String get navEnquiries => 'জিজ্ঞাসা';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get navAdd => 'যোগ করুন';

  @override
  String get navExplore => 'দেখুন';

  @override
  String get navRfq => 'দাম জিজ্ঞাসা';

  @override
  String get homeGreeting => 'নমস্কার';

  @override
  String get homeWelcome => 'স্বাগতম';

  @override
  String get homeAddPromptTitle => '৯০ সেকেন্ডে পণ্য যোগ করুন';

  @override
  String get homeAddPromptBody =>
      'ছবি তুলুন, বলুন, হয়ে গেল — ইন্টারনেট ছাড়াও কাজ করে।';

  @override
  String get homeYourProducts => 'আপনার পণ্য';

  @override
  String get productsTitle => 'আপনার পণ্য';

  @override
  String get productsEmpty =>
      'এখনও কোনো পণ্য নেই। প্রথম তালিকা তৈরি করতে যোগ করুন চাপুন।';

  @override
  String get enquiriesTitle => 'জিজ্ঞাসা';

  @override
  String enquiriesQuantity(int count) {
    return '$count টি';
  }

  @override
  String get enquiriesEmpty => 'এখনও কোনো জিজ্ঞাসা নেই।';

  @override
  String get profileYourStory => 'আপনার গল্প';

  @override
  String profileYearsOfPractice(int years) {
    return '$years বছরের অভিজ্ঞতা';
  }

  @override
  String get profileVerified => 'যাচাইকৃত';

  @override
  String get profileGiTag => 'জিআই ট্যাগ';

  @override
  String get profileHandloom => 'তাঁত';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsLanguageBody => 'এটি পুরো অ্যাপের ভাষা বদলে দেয়।';

  @override
  String get settingsAbout => 'অ্যাপ সম্পর্কে';

  @override
  String settingsVersion(String version) {
    return 'সংস্করণ $version';
  }

  @override
  String get addStepPhoto => 'ছবি';

  @override
  String get addStepSpeak => 'বলুন';

  @override
  String get addStepCosts => 'খরচ';

  @override
  String get addStepReview => 'যাচাই';

  @override
  String get addLeaveTitle => 'প্রকাশ না করে বেরিয়ে যাবেন?';

  @override
  String get addLeaveBody =>
      'আপনার কাজ এই ফোনে সংরক্ষিত আছে। পরে শেষ করতে পারবেন।';

  @override
  String get addSavedOffline => 'ইন্টারনেট ছাড়া সংরক্ষিত';

  @override
  String get photoTitle => 'আপনার শিল্পের ছবি তুলুন';

  @override
  String get photoNone => 'এখনও কোনো ছবি নেই';

  @override
  String get photoGallery => 'গ্যালারি';

  @override
  String get photoCamera => 'ক্যামেরা';

  @override
  String get photoRetake => 'আবার তুলুন';

  @override
  String get photoGood => 'ছবিটি ভালো';

  @override
  String get photoPoor => 'ছবি পরিষ্কার নয় — আবার তুলুন';

  @override
  String get photoCameraUnavailable =>
      'এখানে ক্যামেরা নেই। গ্যালারি থেকে বেছে নিন।';

  @override
  String get photoOpenFailed => 'এই ছবিটি খোলেনি। অন্যটি বেছে নিন।';

  @override
  String get voiceTitle => 'এটি সম্পর্কে বলুন';

  @override
  String get voiceSubtitle => 'আপনার নিজের ভাষায় বলুন।';

  @override
  String get voiceListening => 'শুনছি…';

  @override
  String get voiceTapToSpeak => 'বলতে চাপুন';

  @override
  String get voiceUnavailableTitle => 'এই ফোনে কথা থেকে লেখা যায় না';

  @override
  String get voiceUnavailableBody =>
      'নিচে তথ্য দিন — আপনার তালিকা তবুও তৈরি হবে।';

  @override
  String get voiceTypeInstead => 'অথবা এখানে লিখুন';

  @override
  String get voiceTypeHint => 'যেমন: নীল রেশমি চান্দেরি শাড়ি, হাতে বোনা';

  @override
  String get voiceOpenSettings => 'অ্যাপ সেটিংস খুলুন';

  @override
  String get costsTitle => 'এতে কত খরচ হয়েছে?';

  @override
  String get costsMaterial => 'উপকরণের খরচ';

  @override
  String get costsHours => 'কত ঘণ্টা লেগেছে';

  @override
  String get costsHoursSuffix => 'ঘণ্টা';

  @override
  String get costsSeePrice => 'আমার দাম দেখুন';

  @override
  String get costsMaterials => 'উপকরণ';

  @override
  String costsYourLabour(int hours, int rate) {
    return 'আপনার পরিশ্রম · $hours × ₹$rate';
  }

  @override
  String get costsFairWageNote =>
      'আপনার সময়ের পূর্ণ মূল্য ধরা হয় — কখনও শূন্য নয়।';

  @override
  String get reviewTitle => 'যাচাই করে প্রকাশ করুন';

  @override
  String get reviewOfflineDraft => 'ইন্টারনেট ছাড়া সংরক্ষিত';

  @override
  String get reviewWrittenByAi => 'আপনার বর্ণনা থেকে এআই লিখেছে';

  @override
  String get reviewWrittenOffline =>
      'ইন্টারনেট ছাড়া লেখা — সংযোগ পেলে উন্নত হবে';

  @override
  String get reviewYourPrice => 'আপনার দাম';

  @override
  String get reviewYouWillSellAt => 'আপনি এই দামে বিক্রি করবেন';

  @override
  String reviewPriceFloorNote(int floor) {
    return 'আপনি ₹$floor পর্যন্ত যেকোনো দাম বেছে নিতে পারেন। এর কম হলে ক্ষতি হবে।';
  }

  @override
  String get reviewPublish => 'প্রকাশ করুন';

  @override
  String get reviewPriceLocked => 'এরপর আপনার দাম বদলাবে না।';

  @override
  String get priceFloor => 'সর্বনিম্ন';

  @override
  String get priceSuggested => 'প্রস্তাবিত';

  @override
  String get priceMaximum => 'সর্বোচ্চ';

  @override
  String priceReasoning(int materials, int hours, int rate, int labour) {
    return 'উপকরণ ₹$materials এবং $hours ঘণ্টার পরিশ্রম ঘণ্টাপ্রতি ₹$rate হিসাবে (₹$labour)। আপনি সর্বনিম্ন দামের কম পাবেন না।';
  }

  @override
  String get syncSavedOnPhone => 'এই ফোনে সংরক্ষিত';

  @override
  String get syncQueued => 'পাঠানোর অপেক্ষায়';

  @override
  String get syncSyncing => 'পাঠানো হচ্ছে';

  @override
  String get syncUpgraded => 'উন্নত করা হয়েছে';

  @override
  String get syncLive => 'প্রকাশিত';

  @override
  String get buyerShellTitle => 'ক্রেতা';

  @override
  String get buyerNotInWorkstream => 'ক্রেতার অংশ আলাদাভাবে তৈরি হচ্ছে।';

  @override
  String get buyerNotInWorkstreamBody =>
      'দুটি অংশই একই অ্যাপে আসবে। এই বিল্ডটি কারিগরের জন্য।';

  @override
  String get buyerTagline =>
      'ইন্টারনেট ছাড়াও গ্রামীণ কারিগরের সঙ্গে সরাসরি বাণিজ্য';

  @override
  String get buyerFairTrade => 'ন্যায্য বাণিজ্য';

  @override
  String get buyerBulkRfq => 'পাইকারি চাহিদা';

  @override
  String get buyerViewStorefront => 'দোকান দেখুন';

  @override
  String get buyerAllCrafts => 'সব শিল্প';

  @override
  String get buyerDirectConnect => 'কারিগরের সঙ্গে সরাসরি যোগাযোগ';

  @override
  String get buyerHeritageTreasures => 'ঐতিহ্যবাহী হস্তশিল্প';

  @override
  String get buyerSearchHint =>
      'শিল্প, জিআই ট্যাগ বা ক্লাস্টার দিয়ে খুঁজুন...';

  @override
  String get buyerGiTaggedOnly => 'শুধু জিআই ট্যাগ';

  @override
  String get buyerCurated => 'নির্বাচিত';

  @override
  String get buyerPriceLowToHigh => 'দাম: কম থেকে বেশি';

  @override
  String get buyerHoursOfCraftLabel => 'শ্রমের ঘণ্টা';

  @override
  String get buyerResetFilters => 'সব ফিল্টার সরান';

  @override
  String get buyerQuantityRequired => 'কত পরিমাণ দরকার:';

  @override
  String get buyerSavedToBookmarks => 'আপনার সংগ্রহে সংরক্ষিত';

  @override
  String get buyerRemovedFromSaved => 'সংগ্রহ থেকে সরানো হয়েছে';

  @override
  String get buyer100Direct => '১০০% সরাসরি';

  @override
  String get buyerMaterialCost => 'উপকরণ ও সংগ্রহের খরচ:';

  @override
  String get buyerPackagingOverhead => 'প্যাকিং ও ক্লাস্টার খরচ:';

  @override
  String get buyerDirectFairPrice => 'সরাসরি ন্যায্য দাম:';

  @override
  String get buyerMoreFromCluster => 'এই ক্লাস্টারের আরও শিল্প';

  @override
  String get buyerSendEnquiry => 'সরাসরি জিজ্ঞাসা পাঠান';

  @override
  String get buyerEnquiryNote =>
      'কমিশন বা মধ্যস্বত্বভোগী ছাড়াই সরাসরি যোগাযোগ।';

  @override
  String get buyerEnquiryHint => 'কারিগরের জন্য মাপ, প্রশ্ন বা তথ্য লিখুন...';

  @override
  String get buyerYourMessage => 'আপনার বার্তা:';

  @override
  String get buyerAcceptedByArtisan => 'কারিগর গ্রহণ করেছেন';

  @override
  String get buyerAwaitingReply => 'উত্তরের অপেক্ষায়';

  @override
  String get buyerAccepted => 'গৃহীত';

  @override
  String get buyerSent => 'পাঠানো হয়েছে';

  @override
  String get buyerTapForDetails => 'বিস্তারিত ও কলের জন্য চাপুন';

  @override
  String get buyerBulkAndCustomRfqs => 'পাইকারি ও বিশেষ চাহিদা';

  @override
  String get buyerRfqForm => 'দাম জিজ্ঞাসার ফর্ম';

  @override
  String get buyerBudgetBracket => 'বাজেট সীমা (₹):';

  @override
  String get buyerNewRfq => 'নতুন চাহিদা';

  @override
  String get buyerNoActiveRfqs => 'কোনো সক্রিয় চাহিদা নেই';

  @override
  String get buyerQuotationsReceived => 'দাম পাওয়া গেছে';

  @override
  String get buyerActiveSourcing => 'চলমান অনুসন্ধান';

  @override
  String get buyerQuantity => 'পরিমাণ';

  @override
  String get buyerDeadline => 'শেষ তারিখ';

  @override
  String get buyerBudget => 'বাজেট';

  @override
  String get buyerCraftHeritage => 'শিল্প ঐতিহ্য';

  @override
  String get buyerHandmadeLive => 'হাতে তৈরি';

  @override
  String get buyerDirectFairRating => 'সরাসরি ন্যায্য রেটিং';

  @override
  String get buyerHeritageStory => 'ঐতিহ্যের গল্প';

  @override
  String get buyerVoiceNote => 'কণ্ঠবার্তা';

  @override
  String get buyerAudioPaused => 'অডিও থামানো হয়েছে।';

  @override
  String get buyerProfileTitle => 'ক্রেতা প্রোফাইল';

  @override
  String get buyerSwitchRole => 'ভূমিকা বদলান';

  @override
  String buyerYearsPractice(int years) {
    return '$years বছর';
  }

  @override
  String buyerHoursCraft(int hours) {
    return '$hours ঘণ্টা শ্রম';
  }

  @override
  String buyerHoursOfCraftCount(int hours) {
    return '$hours ঘণ্টার শ্রম';
  }

  @override
  String buyerFairWageLine(int hours, int rate) {
    return 'ন্যায্য মজুরি ($hours ঘণ্টা × ₹$rate):';
  }

  @override
  String buyerDirectEnquiryTo(String name) {
    return '$name কে সরাসরি জিজ্ঞাসা';
  }

  @override
  String buyerPcs(int count) {
    return '$count টি';
  }

  @override
  String get buyerHeritageSubtitle =>
      'স্বচ্ছ ন্যায্য মজুরি, সরাসরি জিআই-ট্যাগযুক্ত গ্রামীণ ক্লাস্টার থেকে।';

  @override
  String get buyerArtisanHeritageStory => 'কারিগরের ঐতিহ্যের গল্প';

  @override
  String get buyerListenVoiceNote => 'কারিগরের কণ্ঠবার্তা শুনুন';

  @override
  String get buyerListeningVoiceNote => 'কণ্ঠবার্তা শোনা হচ্ছে';

  @override
  String get buyerViewActiveRfqs => 'চলমান চাহিদা দেখুন';

  @override
  String get buyerCreateNewRfq => 'নতুন চাহিদা তৈরি করুন';

  @override
  String get buyerCancelViewRfqs => 'বাতিল করে চলমান চাহিদা দেখুন';

  @override
  String get buyerEmailLabel => 'ইমেইল:';

  @override
  String get buyerGstinVerified => 'জিএসটিআইএন যাচাইকৃত:';

  @override
  String buyerRoleSourcing(String role) {
    return 'ভূমিকা: $role সংগ্রহ';
  }

  @override
  String get buyerSentEnquiries => 'পাঠানো জিজ্ঞাসা';

  @override
  String get profileNotSignedIn => 'আপনি সাইন ইন করেননি।';

  @override
  String get profileLoadFailed =>
      'আপনার প্রোফাইল খোলেনি। সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get profileIncomplete =>
      'আপনার প্রোফাইল এখনও তৈরি হয়নি। নিবন্ধন সম্পূর্ণ করুন।';

  @override
  String get profileNoStoryYet => 'আপনি এখনও আপনার গল্প যোগ করেননি।';

  @override
  String get profileProductsListed => 'তালিকাভুক্ত পণ্য';

  @override
  String get profileRating => 'রেটিং';

  @override
  String get profileIdentity => 'পরিচয় নথি';

  @override
  String get profileIdentityNote =>
      'আপনার নিরাপত্তার জন্য কেবল নথির ধরন সংরক্ষিত হয়, নম্বর কখনও নয়।';

  @override
  String get profileIdGstin => 'জিএসটিআইএন দেওয়া হয়েছে';

  @override
  String get profileIdPan => 'প্যান দেওয়া হয়েছে';

  @override
  String get profileIdAadhaar => 'আধার / পরিচয়পত্র দেওয়া হয়েছে';

  @override
  String get profileIdNone => 'কোনো পরিচয় নথি নেই';

  @override
  String get infoTitle => 'এই অ্যাপ সম্পর্কে';

  @override
  String get infoSubtitle => 'এটি কী করে এবং কী করে না';

  @override
  String get infoWhatThisIs => 'পাথ-শিল্প কী';

  @override
  String get infoWhatThisIsBody =>
      'একটি সরঞ্জাম যা একটি ছবি ও একটি কথা থেকে সম্পূর্ণ, ন্যায্য দামের তালিকা তৈরি করে — ইন্টারনেট ছাড়াও। এটি তালিকা তৈরির স্তর, দোকান নয়।';

  @override
  String get infoHowPricing => 'আপনার দাম কীভাবে হিসাব হয়';

  @override
  String get infoHowPricingBody =>
      'উপকরণ + (ঘণ্টা × ন্যায্য মজুরি) + খরচ। সর্বনিম্ন দামের নিচে গেলে আপনার ক্ষতি। আপনি তার উপরে যেকোনো দাম বেছে নিতে পারেন, এবং নিশ্চিত করার পর তা আর বদলায় না।';

  @override
  String get infoOffline => 'ইন্টারনেট ছাড়া কাজ';

  @override
  String get infoOfflineBody =>
      'পণ্য যোগ করার প্রতিটি ধাপ ইন্টারনেট ছাড়া কাজ করে। আপনার খসড়া এই ফোনে সংরক্ষিত থাকে। সংযোগ ফিরলে নিজে থেকেই পাঠানো হয়, ছবি ও লেখা উন্নত হয় — আর আপনার নিশ্চিত করা দাম একই থাকে।';

  @override
  String get infoPrivacy => 'আপনার গোপনীয়তা';

  @override
  String get infoPrivacyBody =>
      'আমরা কেবল সংরক্ষণ করি আপনার কোন নথি আছে — নম্বর কখনও নয়। কোনো আধার বা প্যান নম্বর কোথাও রাখা হয় না। কোনো লোকেশন ট্র্যাকিং বা অ্যানালিটিক্স নেই। আপনি যেকোনো সময় আপনার পণ্য ও ছবি মুছে ফেলতে পারেন।';

  @override
  String get infoNotYet => 'এই অ্যাপ এখনও যা করে না';

  @override
  String get infoNotYetBody =>
      'এখানে কোনো পেমেন্ট বা চেকআউট নেই। ক্রেতারা আপনাকে জিজ্ঞাসা পাঠান এবং আপনি সরাসরি তাঁদের সঙ্গে বিক্রি ঠিক করেন। GeM ও ONDC প্রকাশ কেবল স্ট্যাটাস হিসেবে দেখানো হয়। এখানে আপনার কাছ থেকে কোনো কমিশন নেওয়া হয় না।';

  @override
  String get infoBuyerWhat => 'আপনি এখানে কী করতে পারেন';

  @override
  String get infoBuyerWhatBody =>
      'শিল্প দেখুন, প্রতিটি দাম কীভাবে হয়েছে জানুন, কারিগরের গল্প পড়ুন, এবং তাঁদের জিজ্ঞাসা বা পাইকারি চাহিদা পাঠান। আপনি সরাসরি কারিগরের সঙ্গে লেনদেন করেন।';

  @override
  String get infoBuyerNoCheckout => 'এখনও চেকআউট নেই';

  @override
  String get infoBuyerNoCheckoutBody =>
      'আজ আপনি অ্যাপে পেমেন্ট করতে পারবেন না। এখানকার শিল্প অর্ডারে তৈরি হয়, তাই কারিগর পেমেন্টের আগেই উপকরণ ও সপ্তাহের শ্রম দেন — এর জন্য এসক্রো দরকার যাতে তাঁদের প্রতি ন্যায় হয়। ততক্ষণ, জিজ্ঞাসা আপনাকে সরাসরি কারিগরের সঙ্গে যুক্ত করে।';

  @override
  String get infoFairTrade => 'দাম আলাদা কেন দেখায়';

  @override
  String get infoFairTradeBody =>
      'প্রতিটি দামে কারিগরের উপকরণ খরচ ও ঘণ্টাপ্রতি ₹১৫০ ন্যায্য মজুরি দেখানো হয়। কিছুই লুকানো নেই এবং কোনো মধ্যস্বত্বভোগীর লাভ যোগ করা হয় না।';

  @override
  String get buyerActiveQuotations => 'চলমান চাহিদা';

  @override
  String get buyerNoActiveRfqsBody =>
      'কারিগরের কাছে সরাসরি পৌঁছাতে প্রথম চাহিদা তৈরি করুন।';

  @override
  String get buyerRfqLoadFailed => 'আপনার চাহিদা খোলেনি। সংযোগ দেখুন।';

  @override
  String get artisanRfqTitle => 'পাইকারি চাহিদা';

  @override
  String get artisanRfqSubtitle => 'আপনার শিল্পের জন্য ক্রেতাদের চাহিদা';

  @override
  String get artisanRfqRespond => 'আমি এটি বানাতে পারি';

  @override
  String get artisanRfqResponded => 'আপনি এটি বানানোর প্রস্তাব দিয়েছেন';

  @override
  String get artisanRfqSent => 'ক্রেতাকে জানানো হয়েছে।';

  @override
  String get artisanRfqFailed => 'পাঠানো যায়নি। সংযোগ পেলে আবার চেষ্টা করুন।';

  @override
  String get artisanRfqEmpty => 'এখন কোনো পাইকারি চাহিদা নেই';

  @override
  String get artisanRfqEmptyNoCraft =>
      'মিল থাকা চাহিদা দেখতে প্রোফাইলে আপনার শিল্প যোগ করুন।';

  @override
  String get artisanRfqLoadFailed => 'চাহিদা খোলেনি। সংযোগ দেখুন।';

  @override
  String get artisanTabEnquiries => 'জিজ্ঞাসা';

  @override
  String get artisanTabRfqs => 'পাইকারি চাহিদা';

  @override
  String artisanRfqEmptyBody(String craft) {
    return '$craft খুঁজছেন এমন ক্রেতারা এখানে দেখাবেন।';
  }

  @override
  String artisanRfqOtherResponses(int count) {
    return 'এখন পর্যন্ত $count জন কারিগর প্রস্তাব দিয়েছেন';
  }

  @override
  String get errorVerificationExpired => 'এই কোডের মেয়াদ শেষ। নতুন কোড চান।';

  @override
  String get errorNotSignedIn => 'আপনি সাইন ইন করেননি। আবার সাইন ইন করুন।';
}
