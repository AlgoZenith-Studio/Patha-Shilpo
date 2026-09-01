import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pathashilpa'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your craft. Your price. Your name.'**
  String get appTagline;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get commonStay;

  /// No description provided for @commonLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get commonLeave;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get commonDecline;

  /// No description provided for @commonSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get commonSignOut;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get commonLanguage;

  /// No description provided for @commonNotFound.
  ///
  /// In en, this message translates to:
  /// **'That screen does not exist.'**
  String get commonNotFound;

  /// No description provided for @commonSampleData.
  ///
  /// In en, this message translates to:
  /// **'Sample data — real content arrives once the database is connected.'**
  String get commonSampleData;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'00000 00000'**
  String get authPhoneHint;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'That number does not look right.'**
  String get authPhoneInvalid;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get authEnterCode;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit code'**
  String get authOtpTitle;

  /// No description provided for @authSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {phone}'**
  String authSentTo(String phone);

  /// No description provided for @authOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not right.'**
  String get authOtpInvalid;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'A code has been sent by SMS. It may take a few seconds to arrive.'**
  String get authDemoNotice;

  /// No description provided for @roleQuestion.
  ///
  /// In en, this message translates to:
  /// **'What brings you here?'**
  String get roleQuestion;

  /// No description provided for @roleIMakeThings.
  ///
  /// In en, this message translates to:
  /// **'I make things'**
  String get roleIMakeThings;

  /// No description provided for @roleIWantToBuy.
  ///
  /// In en, this message translates to:
  /// **'I want to buy'**
  String get roleIWantToBuy;

  /// No description provided for @roleChooseOnce.
  ///
  /// In en, this message translates to:
  /// **'You can only choose once.'**
  String get roleChooseOnce;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Enquiries'**
  String get navEnquiries;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navRfq.
  ///
  /// In en, this message translates to:
  /// **'RFQ'**
  String get navRfq;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste'**
  String get homeGreeting;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcome;

  /// No description provided for @homeAddPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a product in 90 seconds'**
  String get homeAddPromptTitle;

  /// No description provided for @homeAddPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Photograph it, speak about it, done — works without internet.'**
  String get homeAddPromptBody;

  /// No description provided for @homeYourProducts.
  ///
  /// In en, this message translates to:
  /// **'Your products'**
  String get homeYourProducts;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your products'**
  String get productsTitle;

  /// No description provided for @productsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products yet. Tap Add to create your first listing.'**
  String get productsEmpty;

  /// No description provided for @enquiriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Enquiries'**
  String get enquiriesTitle;

  /// No description provided for @enquiriesQuantity.
  ///
  /// In en, this message translates to:
  /// **'{count} pcs'**
  String enquiriesQuantity(int count);

  /// No description provided for @enquiriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No enquiries yet.'**
  String get enquiriesEmpty;

  /// No description provided for @profileYourStory.
  ///
  /// In en, this message translates to:
  /// **'Your story'**
  String get profileYourStory;

  /// No description provided for @profileYearsOfPractice.
  ///
  /// In en, this message translates to:
  /// **'{years} years of practice'**
  String profileYearsOfPractice(int years);

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileVerified;

  /// No description provided for @profileGiTag.
  ///
  /// In en, this message translates to:
  /// **'GI Tag'**
  String get profileGiTag;

  /// No description provided for @profileHandloom.
  ///
  /// In en, this message translates to:
  /// **'Handloom'**
  String get profileHandloom;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageBody.
  ///
  /// In en, this message translates to:
  /// **'This controls every screen in the app.'**
  String get settingsLanguageBody;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @addStepPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get addStepPhoto;

  /// No description provided for @addStepSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get addStepSpeak;

  /// No description provided for @addStepCosts.
  ///
  /// In en, this message translates to:
  /// **'Costs'**
  String get addStepCosts;

  /// No description provided for @addStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get addStepReview;

  /// No description provided for @addLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without publishing?'**
  String get addLeaveTitle;

  /// No description provided for @addLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your draft is saved on this phone. You can finish it later.'**
  String get addLeaveBody;

  /// No description provided for @addSavedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved as an offline draft'**
  String get addSavedOffline;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photograph your craft'**
  String get photoTitle;

  /// No description provided for @photoNone.
  ///
  /// In en, this message translates to:
  /// **'No photo yet'**
  String get photoNone;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get photoGallery;

  /// No description provided for @photoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get photoCamera;

  /// No description provided for @photoRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get photoRetake;

  /// No description provided for @photoGood.
  ///
  /// In en, this message translates to:
  /// **'Photo looks good'**
  String get photoGood;

  /// No description provided for @photoPoor.
  ///
  /// In en, this message translates to:
  /// **'Photo looks unclear — take it again'**
  String get photoPoor;

  /// No description provided for @photoCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera is not available here. Choose from gallery instead.'**
  String get photoCameraUnavailable;

  /// No description provided for @photoOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open that photo. Try another.'**
  String get photoOpenFailed;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about it'**
  String get voiceTitle;

  /// No description provided for @voiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak in your own language.'**
  String get voiceSubtitle;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// No description provided for @voiceTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voiceTapToSpeak;

  /// No description provided for @voiceUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Speech is not available on this device'**
  String get voiceUnavailableTitle;

  /// No description provided for @voiceUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below instead — your listing will still work.'**
  String get voiceUnavailableBody;

  /// No description provided for @voiceTypeInstead.
  ///
  /// In en, this message translates to:
  /// **'Or describe it here'**
  String get voiceTypeInstead;

  /// No description provided for @voiceTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. blue silk chanderi saree, woven by hand'**
  String get voiceTypeHint;

  /// No description provided for @voiceOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get voiceOpenSettings;

  /// No description provided for @costsTitle.
  ///
  /// In en, this message translates to:
  /// **'What did it cost you?'**
  String get costsTitle;

  /// No description provided for @costsMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material cost'**
  String get costsMaterial;

  /// No description provided for @costsHours.
  ///
  /// In en, this message translates to:
  /// **'Hours of work'**
  String get costsHours;

  /// No description provided for @costsHoursSuffix.
  ///
  /// In en, this message translates to:
  /// **'hrs'**
  String get costsHoursSuffix;

  /// No description provided for @costsSeePrice.
  ///
  /// In en, this message translates to:
  /// **'See my price'**
  String get costsSeePrice;

  /// No description provided for @costsMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get costsMaterials;

  /// No description provided for @costsYourLabour.
  ///
  /// In en, this message translates to:
  /// **'Your labour · {hours} × ₹{rate}'**
  String costsYourLabour(int hours, int rate);

  /// No description provided for @costsFairWageNote.
  ///
  /// In en, this message translates to:
  /// **'Your time is counted at a fair wage — never at zero.'**
  String get costsFairWageNote;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Check and publish'**
  String get reviewTitle;

  /// No description provided for @reviewOfflineDraft.
  ///
  /// In en, this message translates to:
  /// **'Offline Draft'**
  String get reviewOfflineDraft;

  /// No description provided for @reviewWrittenByAi.
  ///
  /// In en, this message translates to:
  /// **'Written by AI from your description'**
  String get reviewWrittenByAi;

  /// No description provided for @reviewWrittenOffline.
  ///
  /// In en, this message translates to:
  /// **'Written offline from your description — it will improve when you reconnect'**
  String get reviewWrittenOffline;

  /// No description provided for @reviewYourPrice.
  ///
  /// In en, this message translates to:
  /// **'Your price'**
  String get reviewYourPrice;

  /// No description provided for @reviewYouWillSellAt.
  ///
  /// In en, this message translates to:
  /// **'You will sell at'**
  String get reviewYouWillSellAt;

  /// No description provided for @reviewPriceFloorNote.
  ///
  /// In en, this message translates to:
  /// **'You may choose any price down to the floor of ₹{floor}. Below that you would lose money.'**
  String reviewPriceFloorNote(int floor);

  /// No description provided for @reviewPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get reviewPublish;

  /// No description provided for @reviewPriceLocked.
  ///
  /// In en, this message translates to:
  /// **'Your price will not change after this.'**
  String get reviewPriceLocked;

  /// No description provided for @priceFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get priceFloor;

  /// No description provided for @priceSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get priceSuggested;

  /// No description provided for @priceMaximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get priceMaximum;

  /// No description provided for @priceReasoning.
  ///
  /// In en, this message translates to:
  /// **'Materials ₹{materials} plus {hours} hours at the ₹{rate} fair wage (₹{labour}), with overhead. You will not earn less than the floor.'**
  String priceReasoning(int materials, int hours, int rate, int labour);

  /// No description provided for @syncSavedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone'**
  String get syncSavedOnPhone;

  /// No description provided for @syncQueued.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get syncQueued;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncSyncing;

  /// No description provided for @syncUpgraded.
  ///
  /// In en, this message translates to:
  /// **'Improved'**
  String get syncUpgraded;

  /// No description provided for @syncLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get syncLive;

  /// No description provided for @buyerShellTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerShellTitle;

  /// No description provided for @buyerNotInWorkstream.
  ///
  /// In en, this message translates to:
  /// **'The buyer role is being built separately.'**
  String get buyerNotInWorkstream;

  /// No description provided for @buyerNotInWorkstreamBody.
  ///
  /// In en, this message translates to:
  /// **'Both roles ship in one app. This build covers the artisan side.'**
  String get buyerNotInWorkstreamBody;

  /// No description provided for @buyerTagline.
  ///
  /// In en, this message translates to:
  /// **'Offline-first rural artisan direct trade'**
  String get buyerTagline;

  /// No description provided for @buyerFairTrade.
  ///
  /// In en, this message translates to:
  /// **'Fair-Trade'**
  String get buyerFairTrade;

  /// No description provided for @buyerBulkRfq.
  ///
  /// In en, this message translates to:
  /// **'Bulk RFQ'**
  String get buyerBulkRfq;

  /// No description provided for @buyerViewStorefront.
  ///
  /// In en, this message translates to:
  /// **'View Storefront'**
  String get buyerViewStorefront;

  /// No description provided for @buyerAllCrafts.
  ///
  /// In en, this message translates to:
  /// **'All Crafts'**
  String get buyerAllCrafts;

  /// No description provided for @buyerDirectConnect.
  ///
  /// In en, this message translates to:
  /// **'DIRECT ARTISAN CONNECT'**
  String get buyerDirectConnect;

  /// No description provided for @buyerHeritageTreasures.
  ///
  /// In en, this message translates to:
  /// **'Heritage Handcrafted Treasures'**
  String get buyerHeritageTreasures;

  /// No description provided for @buyerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by craft, GI tag or cluster...'**
  String get buyerSearchHint;

  /// No description provided for @buyerGiTaggedOnly.
  ///
  /// In en, this message translates to:
  /// **'GI Tagged Only'**
  String get buyerGiTaggedOnly;

  /// No description provided for @buyerCurated.
  ///
  /// In en, this message translates to:
  /// **'Curated'**
  String get buyerCurated;

  /// No description provided for @buyerPriceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get buyerPriceLowToHigh;

  /// No description provided for @buyerHoursOfCraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours of Craft'**
  String get buyerHoursOfCraftLabel;

  /// No description provided for @buyerResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset All Filters'**
  String get buyerResetFilters;

  /// No description provided for @buyerQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity Required:'**
  String get buyerQuantityRequired;

  /// No description provided for @buyerSavedToBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Saved to your bookmarks'**
  String get buyerSavedToBookmarks;

  /// No description provided for @buyerRemovedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get buyerRemovedFromSaved;

  /// No description provided for @buyer100Direct.
  ///
  /// In en, this message translates to:
  /// **'100% Direct'**
  String get buyer100Direct;

  /// No description provided for @buyerMaterialCost.
  ///
  /// In en, this message translates to:
  /// **'Material & Sourcing Cost:'**
  String get buyerMaterialCost;

  /// No description provided for @buyerPackagingOverhead.
  ///
  /// In en, this message translates to:
  /// **'Packaging & Cluster Overhead:'**
  String get buyerPackagingOverhead;

  /// No description provided for @buyerDirectFairPrice.
  ///
  /// In en, this message translates to:
  /// **'Direct Fair Trade Price:'**
  String get buyerDirectFairPrice;

  /// No description provided for @buyerMoreFromCluster.
  ///
  /// In en, this message translates to:
  /// **'More Crafts from this Cluster'**
  String get buyerMoreFromCluster;

  /// No description provided for @buyerSendEnquiry.
  ///
  /// In en, this message translates to:
  /// **'Send Direct Enquiry'**
  String get buyerSendEnquiry;

  /// No description provided for @buyerEnquiryNote.
  ///
  /// In en, this message translates to:
  /// **'Direct communication, with no commission or middleman.'**
  String get buyerEnquiryNote;

  /// No description provided for @buyerEnquiryHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes, dimensions or questions for the artisan...'**
  String get buyerEnquiryHint;

  /// No description provided for @buyerYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message:'**
  String get buyerYourMessage;

  /// No description provided for @buyerAcceptedByArtisan.
  ///
  /// In en, this message translates to:
  /// **'Accepted by artisan'**
  String get buyerAcceptedByArtisan;

  /// No description provided for @buyerAwaitingReply.
  ///
  /// In en, this message translates to:
  /// **'Awaiting reply'**
  String get buyerAwaitingReply;

  /// No description provided for @buyerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get buyerAccepted;

  /// No description provided for @buyerSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get buyerSent;

  /// No description provided for @buyerTapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details and call'**
  String get buyerTapForDetails;

  /// No description provided for @buyerBulkAndCustomRfqs.
  ///
  /// In en, this message translates to:
  /// **'Bulk & Custom RFQs'**
  String get buyerBulkAndCustomRfqs;

  /// No description provided for @buyerRfqForm.
  ///
  /// In en, this message translates to:
  /// **'Request for Quote Form'**
  String get buyerRfqForm;

  /// No description provided for @buyerBudgetBracket.
  ///
  /// In en, this message translates to:
  /// **'Budget Bracket (₹):'**
  String get buyerBudgetBracket;

  /// No description provided for @buyerNewRfq.
  ///
  /// In en, this message translates to:
  /// **'New RFQ'**
  String get buyerNewRfq;

  /// No description provided for @buyerNoActiveRfqs.
  ///
  /// In en, this message translates to:
  /// **'No Active RFQs'**
  String get buyerNoActiveRfqs;

  /// No description provided for @buyerQuotationsReceived.
  ///
  /// In en, this message translates to:
  /// **'Quotations Received'**
  String get buyerQuotationsReceived;

  /// No description provided for @buyerActiveSourcing.
  ///
  /// In en, this message translates to:
  /// **'Active Sourcing'**
  String get buyerActiveSourcing;

  /// No description provided for @buyerQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get buyerQuantity;

  /// No description provided for @buyerDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get buyerDeadline;

  /// No description provided for @buyerBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get buyerBudget;

  /// No description provided for @buyerCraftHeritage.
  ///
  /// In en, this message translates to:
  /// **'Craft Heritage'**
  String get buyerCraftHeritage;

  /// No description provided for @buyerHandmadeLive.
  ///
  /// In en, this message translates to:
  /// **'Handmade Live'**
  String get buyerHandmadeLive;

  /// No description provided for @buyerDirectFairRating.
  ///
  /// In en, this message translates to:
  /// **'Direct Fair Rating'**
  String get buyerDirectFairRating;

  /// No description provided for @buyerHeritageStory.
  ///
  /// In en, this message translates to:
  /// **'Heritage Story'**
  String get buyerHeritageStory;

  /// No description provided for @buyerVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice Note'**
  String get buyerVoiceNote;

  /// No description provided for @buyerAudioPaused.
  ///
  /// In en, this message translates to:
  /// **'Audio story paused.'**
  String get buyerAudioPaused;

  /// No description provided for @buyerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer Profile'**
  String get buyerProfileTitle;

  /// No description provided for @buyerSwitchRole.
  ///
  /// In en, this message translates to:
  /// **'Switch Role'**
  String get buyerSwitchRole;

  /// No description provided for @buyerYearsPractice.
  ///
  /// In en, this message translates to:
  /// **'{years} Yrs'**
  String buyerYearsPractice(int years);

  /// No description provided for @buyerHoursCraft.
  ///
  /// In en, this message translates to:
  /// **'{hours}h craft'**
  String buyerHoursCraft(int hours);

  /// No description provided for @buyerHoursOfCraftCount.
  ///
  /// In en, this message translates to:
  /// **'{hours} Hours of Craft'**
  String buyerHoursOfCraftCount(int hours);

  /// No description provided for @buyerFairWageLine.
  ///
  /// In en, this message translates to:
  /// **'Fair Artisan Wage ({hours}h @ ₹{rate}/hr):'**
  String buyerFairWageLine(int hours, int rate);

  /// No description provided for @buyerDirectEnquiryTo.
  ///
  /// In en, this message translates to:
  /// **'Direct Enquiry to {name}'**
  String buyerDirectEnquiryTo(String name);

  /// No description provided for @buyerPcs.
  ///
  /// In en, this message translates to:
  /// **'{count} pcs'**
  String buyerPcs(int count);

  /// No description provided for @buyerHeritageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent fair-wage pricing, direct from GI-tagged rural clusters.'**
  String get buyerHeritageSubtitle;

  /// No description provided for @buyerArtisanHeritageStory.
  ///
  /// In en, this message translates to:
  /// **'The Artisan\'s Heritage Story'**
  String get buyerArtisanHeritageStory;

  /// No description provided for @buyerListenVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Listen to the artisan\'s voice note'**
  String get buyerListenVoiceNote;

  /// No description provided for @buyerListeningVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Listening to the voice note'**
  String get buyerListeningVoiceNote;

  /// No description provided for @buyerViewActiveRfqs.
  ///
  /// In en, this message translates to:
  /// **'View Active RFQs'**
  String get buyerViewActiveRfqs;

  /// No description provided for @buyerCreateNewRfq.
  ///
  /// In en, this message translates to:
  /// **'Create New RFQ'**
  String get buyerCreateNewRfq;

  /// No description provided for @buyerCancelViewRfqs.
  ///
  /// In en, this message translates to:
  /// **'Cancel and view active RFQs'**
  String get buyerCancelViewRfqs;

  /// No description provided for @buyerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get buyerEmailLabel;

  /// No description provided for @buyerGstinVerified.
  ///
  /// In en, this message translates to:
  /// **'GSTIN Verified:'**
  String get buyerGstinVerified;

  /// No description provided for @buyerRoleSourcing.
  ///
  /// In en, this message translates to:
  /// **'ROLE: {role} SOURCING'**
  String buyerRoleSourcing(String role);

  /// No description provided for @buyerSentEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Sent Enquiries'**
  String get buyerSentEnquiries;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in.'**
  String get profileNotSignedIn;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile. Check your connection and try again.'**
  String get profileLoadFailed;

  /// No description provided for @profileIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Your profile is not set up yet. Complete registration to see it here.'**
  String get profileIncomplete;

  /// No description provided for @profileNoStoryYet.
  ///
  /// In en, this message translates to:
  /// **'You have not added your story yet.'**
  String get profileNoStoryYet;

  /// No description provided for @profileProductsListed.
  ///
  /// In en, this message translates to:
  /// **'Products listed'**
  String get profileProductsListed;

  /// No description provided for @profileRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get profileRating;

  /// No description provided for @profileIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity document'**
  String get profileIdentity;

  /// No description provided for @profileIdentityNote.
  ///
  /// In en, this message translates to:
  /// **'For your safety, only the document type is stored - never the number itself.'**
  String get profileIdentityNote;

  /// No description provided for @profileIdGstin.
  ///
  /// In en, this message translates to:
  /// **'GSTIN provided'**
  String get profileIdGstin;

  /// No description provided for @profileIdPan.
  ///
  /// In en, this message translates to:
  /// **'PAN provided'**
  String get profileIdPan;

  /// No description provided for @profileIdAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar / Pehchan card provided'**
  String get profileIdAadhaar;

  /// No description provided for @profileIdNone.
  ///
  /// In en, this message translates to:
  /// **'No identity document on file'**
  String get profileIdNone;

  /// No description provided for @infoTitle.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get infoTitle;

  /// No description provided for @infoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What it does, and what it does not'**
  String get infoSubtitle;

  /// No description provided for @infoWhatThisIs.
  ///
  /// In en, this message translates to:
  /// **'What Pathashilpa is'**
  String get infoWhatThisIs;

  /// No description provided for @infoWhatThisIsBody.
  ///
  /// In en, this message translates to:
  /// **'A tool that turns a photograph and a spoken sentence into a complete, fairly priced product listing - even with no internet. It is the layer that creates the listing, not a shop.'**
  String get infoWhatThisIsBody;

  /// No description provided for @infoHowPricing.
  ///
  /// In en, this message translates to:
  /// **'How your price is calculated'**
  String get infoHowPricing;

  /// No description provided for @infoHowPricingBody.
  ///
  /// In en, this message translates to:
  /// **'Materials + (hours x fair wage) + overhead. The floor is the least you should ever accept - below it you lose money. You can always choose your own price above it, and once you confirm, it never changes.'**
  String get infoHowPricingBody;

  /// No description provided for @infoOffline.
  ///
  /// In en, this message translates to:
  /// **'Working without internet'**
  String get infoOffline;

  /// No description provided for @infoOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Every step of adding a product works offline. Your draft is saved on this phone and marked \'Offline Draft\'. When you reconnect it uploads on its own, the photo and words improve - and your confirmed price stays exactly the same.'**
  String get infoOfflineBody;

  /// No description provided for @infoPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get infoPrivacy;

  /// No description provided for @infoPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'We store which identity document you hold, never the number itself. No Aadhaar or PAN number is saved anywhere. There is no location tracking and no analytics. You can delete your products and their photos at any time.'**
  String get infoPrivacyBody;

  /// No description provided for @infoNotYet.
  ///
  /// In en, this message translates to:
  /// **'What this app does not do yet'**
  String get infoNotYet;

  /// No description provided for @infoNotYetBody.
  ///
  /// In en, this message translates to:
  /// **'There is no payment or checkout. Buyers send you an enquiry and you arrange the sale directly with them. GeM and ONDC publishing is shown as a status only. Nothing here takes a commission from you.'**
  String get infoNotYetBody;

  /// No description provided for @infoBuyerWhat.
  ///
  /// In en, this message translates to:
  /// **'What you can do here'**
  String get infoBuyerWhat;

  /// No description provided for @infoBuyerWhatBody.
  ///
  /// In en, this message translates to:
  /// **'Browse crafts, see exactly how each price was built, read the maker\'s story, and send them an enquiry or a bulk quote request. You deal with the artisan directly.'**
  String get infoBuyerWhatBody;

  /// No description provided for @infoBuyerNoCheckout.
  ///
  /// In en, this message translates to:
  /// **'There is no checkout - yet'**
  String get infoBuyerNoCheckout;

  /// No description provided for @infoBuyerNoCheckoutBody.
  ///
  /// In en, this message translates to:
  /// **'You cannot pay in the app today. Craft here is made to order, so the artisan commits materials and weeks of work before payment - that needs escrow to be fair to them. Until then, enquiries connect you directly with the maker.'**
  String get infoBuyerNoCheckoutBody;

  /// No description provided for @infoFairTrade.
  ///
  /// In en, this message translates to:
  /// **'Why the prices look different'**
  String get infoFairTrade;

  /// No description provided for @infoFairTradeBody.
  ///
  /// In en, this message translates to:
  /// **'Every price shows the artisan\'s material cost and their hours at a fair wage of Rs 150/hour. Nothing is hidden and no middleman margin is added.'**
  String get infoFairTradeBody;

  /// No description provided for @buyerActiveQuotations.
  ///
  /// In en, this message translates to:
  /// **'Active Quotations'**
  String get buyerActiveQuotations;

  /// No description provided for @buyerNoActiveRfqsBody.
  ///
  /// In en, this message translates to:
  /// **'Create your first quote request to reach master artisans directly.'**
  String get buyerNoActiveRfqsBody;

  /// No description provided for @buyerRfqLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your requests. Check your connection.'**
  String get buyerRfqLoadFailed;

  /// No description provided for @artisanRfqTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk requests'**
  String get artisanRfqTitle;

  /// No description provided for @artisanRfqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buyers looking for work in your craft'**
  String get artisanRfqSubtitle;

  /// No description provided for @artisanRfqRespond.
  ///
  /// In en, this message translates to:
  /// **'I can make this'**
  String get artisanRfqRespond;

  /// No description provided for @artisanRfqResponded.
  ///
  /// In en, this message translates to:
  /// **'You have offered to make this'**
  String get artisanRfqResponded;

  /// No description provided for @artisanRfqSent.
  ///
  /// In en, this message translates to:
  /// **'The buyer has been told you can make this.'**
  String get artisanRfqSent;

  /// No description provided for @artisanRfqFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send. Try again when you have signal.'**
  String get artisanRfqFailed;

  /// No description provided for @artisanRfqEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bulk requests right now'**
  String get artisanRfqEmpty;

  /// No description provided for @artisanRfqEmptyNoCraft.
  ///
  /// In en, this message translates to:
  /// **'Add your craft to your profile to see matching requests.'**
  String get artisanRfqEmptyNoCraft;

  /// No description provided for @artisanRfqLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load requests. Check your connection.'**
  String get artisanRfqLoadFailed;

  /// No description provided for @artisanTabEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Enquiries'**
  String get artisanTabEnquiries;

  /// No description provided for @artisanTabRfqs.
  ///
  /// In en, this message translates to:
  /// **'Bulk requests'**
  String get artisanTabRfqs;

  /// No description provided for @artisanRfqEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Buyers looking for {craft} will appear here.'**
  String artisanRfqEmptyBody(String craft);

  /// No description provided for @artisanRfqOtherResponses.
  ///
  /// In en, this message translates to:
  /// **'{count} artisan(s) have offered so far'**
  String artisanRfqOtherResponses(int count);

  /// No description provided for @errorVerificationExpired.
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Please request a new one.'**
  String get errorVerificationExpired;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in. Please sign in again.'**
  String get errorNotSignedIn;

  /// No description provided for @profileIdDocOnFile.
  ///
  /// In en, this message translates to:
  /// **'Document photo on file'**
  String get profileIdDocOnFile;

  /// No description provided for @profileIdDocMissing.
  ///
  /// In en, this message translates to:
  /// **'No document photo added'**
  String get profileIdDocMissing;

  /// No description provided for @reviewEnhancingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Cleaning up the photo…'**
  String get reviewEnhancingPhoto;

  /// No description provided for @reviewBackgroundRemoved.
  ///
  /// In en, this message translates to:
  /// **'Background removed'**
  String get reviewBackgroundRemoved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
