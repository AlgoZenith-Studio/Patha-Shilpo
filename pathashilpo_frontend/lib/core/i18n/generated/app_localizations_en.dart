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
      'A code has been sent by SMS. It may take a few seconds to arrive.';

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

  @override
  String get buyerTagline => 'Offline-first rural artisan direct trade';

  @override
  String get buyerFairTrade => 'Fair-Trade';

  @override
  String get buyerBulkRfq => 'Bulk RFQ';

  @override
  String get buyerViewStorefront => 'View Storefront';

  @override
  String get buyerAllCrafts => 'All Crafts';

  @override
  String get buyerDirectConnect => 'DIRECT ARTISAN CONNECT';

  @override
  String get buyerHeritageTreasures => 'Heritage Handcrafted Treasures';

  @override
  String get buyerSearchHint => 'Search by craft, GI tag or cluster...';

  @override
  String get buyerGiTaggedOnly => 'GI Tagged Only';

  @override
  String get buyerCurated => 'Curated';

  @override
  String get buyerPriceLowToHigh => 'Price: Low to High';

  @override
  String get buyerHoursOfCraftLabel => 'Hours of Craft';

  @override
  String get buyerResetFilters => 'Reset All Filters';

  @override
  String get buyerQuantityRequired => 'Quantity Required:';

  @override
  String get buyerSavedToBookmarks => 'Saved to your bookmarks';

  @override
  String get buyerRemovedFromSaved => 'Removed from saved';

  @override
  String get buyer100Direct => '100% Direct';

  @override
  String get buyerMaterialCost => 'Material & Sourcing Cost:';

  @override
  String get buyerPackagingOverhead => 'Packaging & Cluster Overhead:';

  @override
  String get buyerDirectFairPrice => 'Direct Fair Trade Price:';

  @override
  String get buyerMoreFromCluster => 'More Crafts from this Cluster';

  @override
  String get buyerSendEnquiry => 'Send Direct Enquiry';

  @override
  String get buyerEnquiryNote =>
      'Direct communication, with no commission or middleman.';

  @override
  String get buyerEnquiryHint =>
      'Add notes, dimensions or questions for the artisan...';

  @override
  String get buyerYourMessage => 'Your message:';

  @override
  String get buyerAcceptedByArtisan => 'Accepted by artisan';

  @override
  String get buyerAwaitingReply => 'Awaiting reply';

  @override
  String get buyerAccepted => 'Accepted';

  @override
  String get buyerSent => 'Sent';

  @override
  String get buyerTapForDetails => 'Tap for details and call';

  @override
  String get buyerBulkAndCustomRfqs => 'Bulk & Custom RFQs';

  @override
  String get buyerRfqForm => 'Request for Quote Form';

  @override
  String get buyerBudgetBracket => 'Budget Bracket (₹):';

  @override
  String get buyerNewRfq => 'New RFQ';

  @override
  String get buyerNoActiveRfqs => 'No Active RFQs';

  @override
  String get buyerQuotationsReceived => 'Quotations Received';

  @override
  String get buyerActiveSourcing => 'Active Sourcing';

  @override
  String get buyerQuantity => 'Quantity';

  @override
  String get buyerDeadline => 'Deadline';

  @override
  String get buyerBudget => 'Budget';

  @override
  String get buyerCraftHeritage => 'Craft Heritage';

  @override
  String get buyerHandmadeLive => 'Handmade Live';

  @override
  String get buyerDirectFairRating => 'Direct Fair Rating';

  @override
  String get buyerHeritageStory => 'Heritage Story';

  @override
  String get buyerVoiceNote => 'Voice Note';

  @override
  String get buyerAudioPaused => 'Audio story paused.';

  @override
  String get buyerProfileTitle => 'Buyer Profile';

  @override
  String get buyerSwitchRole => 'Switch Role';

  @override
  String buyerYearsPractice(int years) {
    return '$years Yrs';
  }

  @override
  String buyerHoursCraft(int hours) {
    return '${hours}h craft';
  }

  @override
  String buyerHoursOfCraftCount(int hours) {
    return '$hours Hours of Craft';
  }

  @override
  String buyerFairWageLine(int hours, int rate) {
    return 'Fair Artisan Wage (${hours}h @ ₹$rate/hr):';
  }

  @override
  String buyerDirectEnquiryTo(String name) {
    return 'Direct Enquiry to $name';
  }

  @override
  String buyerPcs(int count) {
    return '$count pcs';
  }

  @override
  String get buyerHeritageSubtitle =>
      'Transparent fair-wage pricing, direct from GI-tagged rural clusters.';

  @override
  String get buyerArtisanHeritageStory => 'The Artisan\'s Heritage Story';

  @override
  String get buyerListenVoiceNote => 'Listen to the artisan\'s voice note';

  @override
  String get buyerListeningVoiceNote => 'Listening to the voice note';

  @override
  String get buyerViewActiveRfqs => 'View Active RFQs';

  @override
  String get buyerCreateNewRfq => 'Create New RFQ';

  @override
  String get buyerCancelViewRfqs => 'Cancel and view active RFQs';

  @override
  String get buyerEmailLabel => 'Email:';

  @override
  String get buyerGstinVerified => 'GSTIN Verified:';

  @override
  String buyerRoleSourcing(String role) {
    return 'ROLE: $role SOURCING';
  }

  @override
  String get buyerSentEnquiries => 'Sent Enquiries';

  @override
  String get profileNotSignedIn => 'You are not signed in.';

  @override
  String get profileLoadFailed =>
      'Could not load your profile. Check your connection and try again.';

  @override
  String get profileIncomplete =>
      'Your profile is not set up yet. Complete registration to see it here.';

  @override
  String get profileNoStoryYet => 'You have not added your story yet.';

  @override
  String get profileProductsListed => 'Products listed';

  @override
  String get profileRating => 'Rating';

  @override
  String get profileIdentity => 'Identity document';

  @override
  String get profileIdentityNote =>
      'For your safety, only the document type is stored - never the number itself.';

  @override
  String get profileIdGstin => 'GSTIN provided';

  @override
  String get profileIdPan => 'PAN provided';

  @override
  String get profileIdAadhaar => 'Aadhaar / Pehchan card provided';

  @override
  String get profileIdNone => 'No identity document on file';

  @override
  String get infoTitle => 'About this app';

  @override
  String get infoSubtitle => 'What it does, and what it does not';

  @override
  String get infoWhatThisIs => 'What Pathashilpa is';

  @override
  String get infoWhatThisIsBody =>
      'A tool that turns a photograph and a spoken sentence into a complete, fairly priced product listing - even with no internet. It is the layer that creates the listing, not a shop.';

  @override
  String get infoHowPricing => 'How your price is calculated';

  @override
  String get infoHowPricingBody =>
      'Materials + (hours x fair wage) + overhead. The floor is the least you should ever accept - below it you lose money. You can always choose your own price above it, and once you confirm, it never changes.';

  @override
  String get infoOffline => 'Working without internet';

  @override
  String get infoOfflineBody =>
      'Every step of adding a product works offline. Your draft is saved on this phone and marked \'Offline Draft\'. When you reconnect it uploads on its own, the photo and words improve - and your confirmed price stays exactly the same.';

  @override
  String get infoPrivacy => 'Your privacy';

  @override
  String get infoPrivacyBody =>
      'We store which identity document you hold, never the number itself. No Aadhaar or PAN number is saved anywhere. There is no location tracking and no analytics. You can delete your products and their photos at any time.';

  @override
  String get infoNotYet => 'What this app does not do yet';

  @override
  String get infoNotYetBody =>
      'There is no payment or checkout. Buyers send you an enquiry and you arrange the sale directly with them. GeM and ONDC publishing is shown as a status only. Nothing here takes a commission from you.';

  @override
  String get infoBuyerWhat => 'What you can do here';

  @override
  String get infoBuyerWhatBody =>
      'Browse crafts, see exactly how each price was built, read the maker\'s story, and send them an enquiry or a bulk quote request. You deal with the artisan directly.';

  @override
  String get infoBuyerNoCheckout => 'There is no checkout - yet';

  @override
  String get infoBuyerNoCheckoutBody =>
      'You cannot pay in the app today. Craft here is made to order, so the artisan commits materials and weeks of work before payment - that needs escrow to be fair to them. Until then, enquiries connect you directly with the maker.';

  @override
  String get infoFairTrade => 'Why the prices look different';

  @override
  String get infoFairTradeBody =>
      'Every price shows the artisan\'s material cost and their hours at a fair wage of Rs 150/hour. Nothing is hidden and no middleman margin is added.';

  @override
  String get buyerActiveQuotations => 'Active Quotations';

  @override
  String get buyerNoActiveRfqsBody =>
      'Create your first quote request to reach master artisans directly.';

  @override
  String get buyerRfqLoadFailed =>
      'Could not load your requests. Check your connection.';

  @override
  String get artisanRfqTitle => 'Bulk requests';

  @override
  String get artisanRfqSubtitle => 'Buyers looking for work in your craft';

  @override
  String get artisanRfqRespond => 'I can make this';

  @override
  String get artisanRfqResponded => 'You have offered to make this';

  @override
  String get artisanRfqSent => 'The buyer has been told you can make this.';

  @override
  String get artisanRfqFailed =>
      'Could not send. Try again when you have signal.';

  @override
  String get artisanRfqEmpty => 'No bulk requests right now';

  @override
  String get artisanRfqEmptyNoCraft =>
      'Add your craft to your profile to see matching requests.';

  @override
  String get artisanRfqLoadFailed =>
      'Could not load requests. Check your connection.';

  @override
  String get artisanTabEnquiries => 'Enquiries';

  @override
  String get artisanTabRfqs => 'Bulk requests';

  @override
  String artisanRfqEmptyBody(String craft) {
    return 'Buyers looking for $craft will appear here.';
  }

  @override
  String artisanRfqOtherResponses(int count) {
    return '$count artisan(s) have offered so far';
  }

  @override
  String get errorVerificationExpired =>
      'That code has expired. Please request a new one.';

  @override
  String get errorNotSignedIn => 'You are not signed in. Please sign in again.';
}
