import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_mn.dart';
import 'app_localizations_mo.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('ja'),
    Locale('mn'),
    Locale('ro'),
    Locale('zh')
  ];

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get hintEmail;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get hintPassword;

  /// No description provided for @hintUserName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get hintUserName;

  /// No description provided for @textForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get textForgotPassword;

  /// No description provided for @hintEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid E-mail address.'**
  String get hintEmailInvalid;

  /// No description provided for @hintVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code.'**
  String get hintVerificationCode;

  /// No description provided for @hintFeedback.
  ///
  /// In en, this message translates to:
  /// **'Please enter a detailed description of the issue.'**
  String get hintFeedback;

  /// No description provided for @textButtonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get textButtonConfirm;

  /// No description provided for @textButtonGoPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get textButtonGoPremium;

  /// No description provided for @textButtonUpgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to a premium user now'**
  String get textButtonUpgradeNow;

  /// No description provided for @textButtonRestorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get textButtonRestorePurchase;

  /// No description provided for @textButtonMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get textButtonMaybeLater;

  /// No description provided for @textRegisterNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Account'**
  String get textRegisterNewAccount;

  /// No description provided for @textButtonOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get textButtonOK;

  /// No description provided for @textButtonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get textButtonContinue;

  /// No description provided for @textButtonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get textButtonNext;

  /// No description provided for @textButtonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get textButtonDone;

  /// No description provided for @textButtonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get textButtonSubmit;

  /// No description provided for @textButtonLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get textButtonLogin;

  /// No description provided for @textButtonSignUp.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get textButtonSignUp;

  /// No description provided for @textButtonDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get textButtonDeleteAccount;

  /// No description provided for @textButtonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get textButtonSend;

  /// No description provided for @textButtonAgree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get textButtonAgree;

  /// No description provided for @textButtonAgreeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Agree and Continue'**
  String get textButtonAgreeAndContinue;

  /// No description provided for @textButtonDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get textButtonDecline;

  /// No description provided for @textButtonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get textButtonCancel;

  /// No description provided for @textButtonVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get textButtonVerify;

  /// No description provided for @textButtonGetVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get textButtonGetVerificationCode;

  /// No description provided for @textWechatNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Wechat not installed'**
  String get textWechatNotInstalled;

  /// No description provided for @textTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get textTotalPrice;

  /// No description provided for @hintTranslationResult.
  ///
  /// In en, this message translates to:
  /// **'Translation is ready.'**
  String get hintTranslationResult;

  /// No description provided for @hintTranslating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get hintTranslating;

  /// No description provided for @hintTranslationInput.
  ///
  /// In en, this message translates to:
  /// **'Enter text to begin translation!'**
  String get hintTranslationInput;

  /// No description provided for @titleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// No description provided for @titleMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get titleMine;

  /// No description provided for @titleMembership.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get titleMembership;

  /// No description provided for @titleMembershipRight.
  ///
  /// In en, this message translates to:
  /// **'Membership Rights'**
  String get titleMembershipRight;

  /// No description provided for @titleUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get titleUserInfo;

  /// No description provided for @titleMessages.
  ///
  /// In en, this message translates to:
  /// **'System Messages'**
  String get titleMessages;

  /// No description provided for @titleFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get titleFaq;

  /// No description provided for @titleFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get titleFeedback;

  /// No description provided for @titlePhrasebook.
  ///
  /// In en, this message translates to:
  /// **'Phrase Book'**
  String get titlePhrasebook;

  /// No description provided for @titleChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get titleChangePassword;

  /// No description provided for @titleDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get titleDeleteAccount;

  /// No description provided for @titleResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get titleResetPassword;

  /// No description provided for @titleRegisterAccount.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get titleRegisterAccount;

  /// No description provided for @titleLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get titleLogin;

  /// No description provided for @textAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get textAnd;

  /// No description provided for @textLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get textLanguage;

  /// No description provided for @textTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance Mode'**
  String get textTheme;

  /// No description provided for @textThemeAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get textThemeAutomatic;

  /// No description provided for @textThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'When the option is opened, the APP will automatically select the appearance mode according to the system settings.'**
  String get textThemeDescription;

  /// No description provided for @textThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get textThemeDark;

  /// No description provided for @textThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get textThemeLight;

  /// No description provided for @textUserAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get textUserAgreement;

  /// No description provided for @textPrivacyStatement.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get textPrivacyStatement;

  /// No description provided for @textFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get textFaq;

  /// No description provided for @textFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get textFeedback;

  /// No description provided for @textSelectFeedbackType.
  ///
  /// In en, this message translates to:
  /// **'Please select the feedback type.'**
  String get textSelectFeedbackType;

  /// No description provided for @textLoginPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Please register or login'**
  String get textLoginPlaceholder;

  /// No description provided for @textHitory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get textHitory;

  /// No description provided for @textClearHitory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get textClearHitory;

  /// No description provided for @textClearHitoryMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all history?'**
  String get textClearHitoryMsg;

  /// No description provided for @textNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get textNoHistory;

  /// No description provided for @textFavourite.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get textFavourite;

  /// No description provided for @textNoFavourites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get textNoFavourites;

  /// No description provided for @textListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get textListEmpty;

  /// No description provided for @textMessageListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No system messages yet'**
  String get textMessageListEmpty;

  /// No description provided for @textUpgradePremiumNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to a premium user now'**
  String get textUpgradePremiumNow;

  /// No description provided for @textButtonUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get textButtonUpgrade;

  /// No description provided for @textTranslatorPro.
  ///
  /// In en, this message translates to:
  /// **'Translator Pro'**
  String get textTranslatorPro;

  /// No description provided for @textPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get textPurchaseHistory;

  /// No description provided for @textMembershipAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'Read and agree to the '**
  String get textMembershipAgreementPrefix;

  /// No description provided for @textMembershipAgreement.
  ///
  /// In en, this message translates to:
  /// **'Membership Agreement'**
  String get textMembershipAgreement;

  /// No description provided for @textMembershipAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get textMembershipAgreementSuffix;

  /// No description provided for @textMembershipExpirePrefix.
  ///
  /// In en, this message translates to:
  /// **'Expires: '**
  String get textMembershipExpirePrefix;

  /// No description provided for @textMembershipExpireSuffix.
  ///
  /// In en, this message translates to:
  /// **''**
  String get textMembershipExpireSuffix;

  /// No description provided for @textNotMembership.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to a member and enjoy more features!'**
  String get textNotMembership;

  /// No description provided for @textAppIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Abiya Translator is an intelligent translation app that supports bidirectional translation between Simplified Chinese, Mongolian, English, Japanese, and Cyrillic. It provides users with high-precision translation services, suitable for communication scenarios in these five languages.'**
  String get textAppIntroduction;

  /// No description provided for @textAgreementDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Please read and agree to our User Agreement and Privacy Policy to continue using our application. By clicking \"Agree\", you agree to our terms.'**
  String get textAgreementDialogContent;

  /// No description provided for @textFullDocumentOfPrefix.
  ///
  /// In en, this message translates to:
  /// **'Please read the complete '**
  String get textFullDocumentOfPrefix;

  /// No description provided for @textReadFullDocumentOfSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get textReadFullDocumentOfSuffix;

  /// No description provided for @textSelectLanagueFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select the language you would like to use:'**
  String get textSelectLanagueFirst;

  /// No description provided for @textNotSupportedYet.
  ///
  /// In en, this message translates to:
  /// **'Not supported yet'**
  String get textNotSupportedYet;

  /// No description provided for @textSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language:'**
  String get textSelectLanguage;

  /// No description provided for @textSelectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method:'**
  String get textSelectPaymentMethod;

  /// No description provided for @textUserName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get textUserName;

  /// No description provided for @textMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get textMobile;

  /// No description provided for @textWechat.
  ///
  /// In en, this message translates to:
  /// **'Wechat'**
  String get textWechat;

  /// No description provided for @textWechatPay.
  ///
  /// In en, this message translates to:
  /// **'Wechat Pay'**
  String get textWechatPay;

  /// No description provided for @textAlipay.
  ///
  /// In en, this message translates to:
  /// **'Alipay'**
  String get textAlipay;

  /// No description provided for @textGooglePay.
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get textGooglePay;

  /// No description provided for @textDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get textDeleteAccount;

  /// No description provided for @textLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get textLogout;

  /// No description provided for @textNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Not Bound'**
  String get textNotLinked;

  /// No description provided for @textSignInAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By clicking the \"Registration\" button, I agree to\n'**
  String get textSignInAgreementPrefix;

  /// No description provided for @textSignInAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get textSignInAgreementSuffix;

  /// No description provided for @textFirstUseAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By clicking the \"Continue\" button, I agree to\n'**
  String get textFirstUseAgreementPrefix;

  /// No description provided for @textFirstUseAgreementSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get textFirstUseAgreementSuffix;

  /// No description provided for @textVerificationCodeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get textVerificationCodeEmpty;

  /// No description provided for @textChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get textChangePassword;

  /// No description provided for @textPasswordLengthNotEnough.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 6 characters long'**
  String get textPasswordLengthNotEnough;

  /// No description provided for @textPasswordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get textPasswordInvalid;

  /// No description provided for @alertAccountDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get alertAccountDeletionTitle;

  /// No description provided for @alertAccountDeletionMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? Once deleted, your account cannot be recovered, and all data associated with the account, including history, favorites, and membership privileges, will be permanently deleted. Please confirm if you wish to proceed.'**
  String get alertAccountDeletionMsg;

  /// No description provided for @alertLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get alertLogoutTitle;

  /// No description provided for @alertLogoutMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? After logging out, you can still log back in using your email and password.'**
  String get alertLogoutMsg;

  /// No description provided for @alertInsufficientFreeAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Free quota is running out.'**
  String get alertInsufficientFreeAmountTitle;

  /// No description provided for @alertFreeAmountUsedUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Free quota has been used up.'**
  String get alertFreeAmountUsedUpTitle;

  /// No description provided for @alertEmptyString.
  ///
  /// In en, this message translates to:
  /// **'Please enter the text you want to translate!'**
  String get alertEmptyString;

  /// No description provided for @alertLoginExpireTitle.
  ///
  /// In en, this message translates to:
  /// **'Login expired'**
  String get alertLoginExpireTitle;

  /// No description provided for @alertLoginExpireMsg.
  ///
  /// In en, this message translates to:
  /// **'Your login has expired, please log in again.'**
  String get alertLoginExpireMsg;

  /// No description provided for @alertLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Enhance your experience'**
  String get alertLoginTitle;

  /// No description provided for @alertLoginMsg.
  ///
  /// In en, this message translates to:
  /// **'Before purchasing a membership, please log in or register an account. Log in now?'**
  String get alertLoginMsg;

  /// No description provided for @alertLoginMsgIos.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account to sync your data and access premium features on all supported platforms. Do you want to proceed now?'**
  String get alertLoginMsgIos;

  /// No description provided for @alertCheckMembershipAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership Agreement'**
  String get alertCheckMembershipAgreementTitle;

  /// No description provided for @alertCheckMembershipAgreement.
  ///
  /// In en, this message translates to:
  /// **'Please read and agree to the membership agreement'**
  String get alertCheckMembershipAgreement;

  /// No description provided for @alertCheckAgreementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get alertCheckAgreementTitle;

  /// No description provided for @alertCheckAgreement.
  ///
  /// In en, this message translates to:
  /// **'Before you start using Abiya Translator, please agree to our User Agreement and Privacy Policy.'**
  String get alertCheckAgreement;

  /// No description provided for @alertInputPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get alertInputPasswordTitle;

  /// No description provided for @alertInputPasswordMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password to continue'**
  String get alertInputPasswordMsg;

  /// No description provided for @alertAccountDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get alertAccountDeletedTitle;

  /// No description provided for @alertAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted, thank you for using Abiya translator.'**
  String get alertAccountDeleted;

  /// No description provided for @alertTitleCancelRegister.
  ///
  /// In en, this message translates to:
  /// **'Cancel registration'**
  String get alertTitleCancelRegister;

  /// No description provided for @alertContentCancelRegister.
  ///
  /// In en, this message translates to:
  /// **'You can create an account in just one step. Are you sure you want to cancel your account registration?'**
  String get alertContentCancelRegister;

  /// No description provided for @toastTextCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied successfully'**
  String get toastTextCopied;

  /// No description provided for @toastPleaseSelectFeedbackType.
  ///
  /// In en, this message translates to:
  /// **'Please select the feedback type'**
  String get toastPleaseSelectFeedbackType;

  /// No description provided for @toastFeedbackSuccessfullySent.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get toastFeedbackSuccessfullySent;

  /// No description provided for @toastFeedbackContentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a detailed description of the issue.'**
  String get toastFeedbackContentEmpty;

  /// No description provided for @toastDeleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get toastDeleteAccountSuccess;

  /// No description provided for @toastChangePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get toastChangePasswordSuccess;

  /// No description provided for @toastPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully.'**
  String get toastPasswordResetSuccess;

  /// No description provided for @toastAlipayNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Alipay not installed.'**
  String get toastAlipayNotInstalled;

  /// No description provided for @textVersion.
  ///
  /// In en, this message translates to:
  /// **'Version:'**
  String get textVersion;

  /// No description provided for @textCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Inner Mongolia Abiya Technology Co.,Ltd.'**
  String get textCompanyName;

  /// No description provided for @textCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright©2025'**
  String get textCopyright;

  /// No description provided for @textMembershipRightTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get textMembershipRightTranslation;

  /// No description provided for @textMembershipRightHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get textMembershipRightHistory;

  /// No description provided for @textMembershipRightFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get textMembershipRightFavourites;

  /// No description provided for @textMembershipRightTranslationDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited use'**
  String get textMembershipRightTranslationDesc;

  /// No description provided for @textMembershipRightHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited use'**
  String get textMembershipRightHistoryDesc;

  /// No description provided for @textMembershipRightFavouritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited use'**
  String get textMembershipRightFavouritesDesc;

  /// No description provided for @textMembershipRightBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get textMembershipRightBasic;

  /// No description provided for @textMembershipRightPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get textMembershipRightPremium;

  /// No description provided for @textMembershipRightBasicDesc.
  ///
  /// In en, this message translates to:
  /// **'Users can use Abiya Translator for free, but only with limited features.'**
  String get textMembershipRightBasicDesc;

  /// No description provided for @textMembershipRightPremiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all the features and advantages of Abiya Translator.'**
  String get textMembershipRightPremiumDesc;

  /// No description provided for @textMembershipRightPhrasebook.
  ///
  /// In en, this message translates to:
  /// **'Phrasebook'**
  String get textMembershipRightPhrasebook;

  /// No description provided for @textMembershipRightPhrasebookDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited use'**
  String get textMembershipRightPhrasebookDesc;

  /// No description provided for @textMembershipRightRights.
  ///
  /// In en, this message translates to:
  /// **'Rights'**
  String get textMembershipRightRights;

  /// No description provided for @alertTitleNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported yet'**
  String get alertTitleNotSupported;

  /// No description provided for @alertMsgMongolianTranslationNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Sorry, traditional Mongolian translation is not supported at the moment, we are working hard on its development.'**
  String get alertMsgMongolianTranslationNotSupported;

  /// No description provided for @alertMsgJapaneseTranslationNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Sorry, Japanese translation is not supported at the moment, we are working hard on its development.'**
  String get alertMsgJapaneseTranslationNotSupported;

  /// No description provided for @alertMsgMongolianUINotSupported.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the app\'s language does not currently support Traditional Mongolian, we are working hard on its development.'**
  String get alertMsgMongolianUINotSupported;

  /// No description provided for @alertModelNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Sorry, translation between these two languages ​​is not currently supported, and we are working hard on research and development.'**
  String get alertModelNotSupported;

  /// No description provided for @textProfessionSelection.
  ///
  /// In en, this message translates to:
  /// **'Profession Selection'**
  String get textProfessionSelection;

  /// No description provided for @hintSelectProfession.
  ///
  /// In en, this message translates to:
  /// **'Please select your profession:'**
  String get hintSelectProfession;

  /// No description provided for @toastProfessionSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profession set successfully.'**
  String get toastProfessionSetSuccess;

  /// No description provided for @textSubscriptionAutoRenewGoogle.
  ///
  /// In en, this message translates to:
  /// **'Automatic renewal, cancel anytime.\nManage your subscription in your Google Play account.'**
  String get textSubscriptionAutoRenewGoogle;

  /// No description provided for @textSubscriptionAutoRenewApple.
  ///
  /// In en, this message translates to:
  /// **'Automatic renewal, cancel anytime.\nManage your subscription in your Apple ID account settings.'**
  String get textSubscriptionAutoRenewApple;

  /// No description provided for @textSubscriptionTerms.
  ///
  /// In en, this message translates to:
  /// **'Subscription Description'**
  String get textSubscriptionTerms;

  /// No description provided for @textGooglePlayProductUnavailable.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are not available on this device. Estimated prices may be shown.'**
  String get textGooglePlayProductUnavailable;
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
      <String>['en', 'ja', 'mn', 'ro', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'mn':
      return AppLocalizationsMn();
    case 'ro':
      return AppLocalizationsRo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
