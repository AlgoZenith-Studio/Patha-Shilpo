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
      'এটি নমুনা অ্যাপ: যেকোনো ছয় অঙ্ক কাজ করবে। ফোন যাচাই এখনও যুক্ত হয়নি।';

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
}
