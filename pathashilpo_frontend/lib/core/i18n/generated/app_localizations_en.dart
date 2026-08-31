// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pathashilpa';

  @override
  String get appTagline => 'Your craft. Your price. Your name.';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonStay => 'Stay';

  @override
  String get commonLeave => 'Leave';

  @override
  String get commonAccept => 'Accept';

  @override
  String get commonDecline => 'Decline';

  @override
  String get commonSignOut => 'Sign out';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonNotFound => 'That screen does not exist.';

  @override
  String get commonSampleData =>
      'Sample data — real content arrives once the database is connected.';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authPhoneTitle => 'Your phone number';

  @override
  String get authPhoneHint => '00000 00000';

  @override
  String get authPhoneInvalid => 'That number does not look right.';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authEnterCode => 'Enter code';

  @override
  String get authOtpTitle => 'Enter the six-digit code';

  @override
  String authSentTo(String phone) {
    return 'Sent to $phone';
  }

  @override
  String get authOtpInvalid => 'That code is not right.';

  @override
  String get authVerify => 'Verify';

  @override
  String get authDemoNotice =>
      'Demo build: any six digits will work. Phone verification is not connected yet.';

  @override
  String get roleQuestion => 'What brings you here?';

  @override
  String get roleIMakeThings => 'I make things';

  @override
  String get roleIWantToBuy => 'I want to buy';

  @override
  String get roleChooseOnce => 'You can only choose once.';

  @override
  String get navHome => 'Home';

  @override
  String get navProducts => 'Products';

  @override
  String get navEnquiries => 'Enquiries';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAdd => 'Add';

  @override
  String get navExplore => 'Explore';

  @override
  String get navRfq => 'RFQ';

  @override
  String get homeGreeting => 'Namaste';

  @override
  String get homeWelcome => 'Welcome back';

  @override
  String get homeAddPromptTitle => 'Add a product in 90 seconds';

  @override
  String get homeAddPromptBody =>
      'Photograph it, speak about it, done — works without internet.';

  @override
  String get homeYourProducts => 'Your products';

  @override
  String get productsTitle => 'Your products';

  @override
  String get productsEmpty =>
      'No products yet. Tap Add to create your first listing.';

  @override
  String get enquiriesTitle => 'Enquiries';

  @override
  String enquiriesQuantity(int count) {
    return '$count pcs';
  }

  @override
  String get enquiriesEmpty => 'No enquiries yet.';

  @override
  String get profileYourStory => 'Your story';

  @override
  String profileYearsOfPractice(int years) {
    return '$years years of practice';
  }

  @override
  String get profileVerified => 'Verified';

  @override
  String get profileGiTag => 'GI Tag';

  @override
  String get profileHandloom => 'Handloom';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageBody => 'This controls every screen in the app.';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get addStepPhoto => 'Photo';

  @override
  String get addStepSpeak => 'Speak';

  @override
  String get addStepCosts => 'Costs';

  @override
  String get addStepReview => 'Review';

  @override
  String get addLeaveTitle => 'Leave without publishing?';

  @override
  String get addLeaveBody =>
      'Your draft is saved on this phone. You can finish it later.';

  @override
  String get addSavedOffline => 'Saved as an offline draft';

  @override
  String get photoTitle => 'Photograph your craft';

  @override
  String get photoNone => 'No photo yet';

  @override
  String get photoGallery => 'Gallery';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoRetake => 'Retake';

  @override
  String get photoGood => 'Photo looks good';

  @override
  String get photoPoor => 'Photo looks unclear — take it again';

  @override
  String get photoCameraUnavailable =>
      'Camera is not available here. Choose from gallery instead.';

  @override
  String get photoOpenFailed => 'Could not open that photo. Try another.';

  @override
  String get voiceTitle => 'Tell us about it';

  @override
  String get voiceSubtitle => 'Speak in your own language.';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceTapToSpeak => 'Tap to speak';

  @override
  String get voiceUnavailableTitle => 'Speech is not available on this device';

  @override
  String get voiceUnavailableBody =>
      'Fill in the details below instead — your listing will still work.';

  @override
  String get voiceTypeInstead => 'Or describe it here';

  @override
  String get voiceTypeHint => 'e.g. blue silk chanderi saree, woven by hand';

  @override
  String get voiceOpenSettings => 'Open app settings';

  @override
  String get costsTitle => 'What did it cost you?';

  @override
  String get costsMaterial => 'Material cost';

  @override
  String get costsHours => 'Hours of work';

  @override
  String get costsHoursSuffix => 'hrs';

  @override
  String get costsSeePrice => 'See my price';

  @override
  String get costsMaterials => 'Materials';

  @override
  String costsYourLabour(int hours, int rate) {
    return 'Your labour · $hours × ₹$rate';
  }

  @override
  String get costsFairWageNote =>
      'Your time is counted at a fair wage — never at zero.';

  @override
  String get reviewTitle => 'Check and publish';

  @override
  String get reviewOfflineDraft => 'Offline Draft';

  @override
  String get reviewWrittenByAi => 'Written by AI from your description';

  @override
  String get reviewWrittenOffline =>
      'Written offline from your description — it will improve when you reconnect';

  @override
  String get reviewYourPrice => 'Your price';

  @override
  String get reviewYouWillSellAt => 'You will sell at';

  @override
  String reviewPriceFloorNote(int floor) {
    return 'You may choose any price down to the floor of ₹$floor. Below that you would lose money.';
  }

  @override
  String get reviewPublish => 'Publish';

  @override
  String get reviewPriceLocked => 'Your price will not change after this.';

  @override
  String get priceFloor => 'Floor';

  @override
  String get priceSuggested => 'Suggested';

  @override
  String get priceMaximum => 'Maximum';

  @override
  String priceReasoning(int materials, int hours, int rate, int labour) {
    return 'Materials ₹$materials plus $hours hours at the ₹$rate fair wage (₹$labour), with overhead. You will not earn less than the floor.';
  }

  @override
  String get syncSavedOnPhone => 'Saved on this phone';

  @override
  String get syncQueued => 'Waiting to sync';

  @override
  String get syncSyncing => 'Syncing';

  @override
  String get syncUpgraded => 'Improved';

  @override
  String get syncLive => 'Live';

  @override
  String get buyerShellTitle => 'Buyer';

  @override
  String get buyerNotInWorkstream =>
      'The buyer role is being built separately.';

  @override
  String get buyerNotInWorkstreamBody =>
      'Both roles ship in one app. This build covers the artisan side.';
}
