import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Finder'**
  String get appName;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get commonDiscard;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpen;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get commonReport;

  /// No description provided for @commonBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get commonBlock;

  /// No description provided for @commonUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get commonUnblock;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get commonSending;

  /// No description provided for @commonUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get commonUploading;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get commonViewProfile;

  /// No description provided for @commonMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get commonMoreOptions;

  /// No description provided for @commonLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get commonLogOut;

  /// No description provided for @commonLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get commonLost;

  /// No description provided for @commonFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get commonFound;

  /// No description provided for @commonReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get commonReturned;

  /// No description provided for @commonMarkAsReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark as returned'**
  String get commonMarkAsReturned;

  /// No description provided for @commonMarkedAsReturned.
  ///
  /// In en, this message translates to:
  /// **'Marked as returned.'**
  String get commonMarkedAsReturned;

  /// No description provided for @commonReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get commonReopen;

  /// No description provided for @commonPosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get commonPosts;

  /// No description provided for @commonMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get commonMessages;

  /// No description provided for @commonNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get commonNotifications;

  /// No description provided for @commonProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get commonProfile;

  /// No description provided for @commonHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get commonHome;

  /// No description provided for @commonLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get commonLocation;

  /// No description provided for @commonLocationNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get commonLocationNotSpecified;

  /// No description provided for @commonFinderUser.
  ///
  /// In en, this message translates to:
  /// **'Finder User'**
  String get commonFinderUser;

  /// No description provided for @commonYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commonYou;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. {detail}'**
  String commonUploadFailed(String detail);

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get commonCopied;

  /// No description provided for @commonJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get commonJustNow;

  /// No description provided for @commonMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String commonMinutesAgo(int count);

  /// No description provided for @commonHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String commonHoursAgo(int count);

  /// No description provided for @commonDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String commonDaysAgo(int count);

  /// No description provided for @commonWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String commonWeeksAgo(int count);

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonMonthShort.
  ///
  /// In en, this message translates to:
  /// **'{month, select, 1{Jan} 2{Feb} 3{Mar} 4{Apr} 5{May} 6{Jun} 7{Jul} 8{Aug} 9{Sep} 10{Oct} 11{Nov} 12{Dec} other{}}'**
  String commonMonthShort(String month);

  /// No description provided for @commonWeekdayShort.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{Mon} 2{Tue} 3{Wed} 4{Thu} 5{Fri} 6{Sat} 7{Sun} other{}}'**
  String commonWeekdayShort(String day);

  /// No description provided for @commonDayMonth.
  ///
  /// In en, this message translates to:
  /// **'{day} {month}'**
  String commonDayMonth(int day, String month);

  /// No description provided for @commonDayMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{day} {month} {year}'**
  String commonDayMonthYear(int day, String month, int year);

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language Finder uses'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Use phone language'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageKurdish.
  ///
  /// In en, this message translates to:
  /// **'کوردی'**
  String get languageKurdish;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language updated.'**
  String get languageChanged;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue finding what matters.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccountPrompt;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authPasswordMin6;

  /// No description provided for @authSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report and track lost & found items with the community.'**
  String get authSignupSubtitle;

  /// No description provided for @authEmailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get authEmailAddressLabel;

  /// No description provided for @authEmailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'yourname@example.com'**
  String get authEmailAddressHint;

  /// No description provided for @authNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get authNameLabel;

  /// No description provided for @authNameHint.
  ///
  /// In en, this message translates to:
  /// **'How should we call you?'**
  String get authNameHint;

  /// No description provided for @authPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhoneLabel;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 234 567 8900'**
  String get authPhoneHint;

  /// No description provided for @authSignupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get authSignupPasswordHint;

  /// No description provided for @authPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters with a letter and a number.'**
  String get authPasswordRule;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authOrSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get authOrSignUpWith;

  /// No description provided for @authSignUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get authSignUpWithGoogle;

  /// No description provided for @authHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccountPrompt;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// No description provided for @authForgotInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get authForgotInvalidEmail;

  /// No description provided for @authForgotCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent! Check your inbox or console logs.'**
  String get authForgotCodeSent;

  /// No description provided for @authForgotCodeResent.
  ///
  /// In en, this message translates to:
  /// **'New verification code sent! Check your inbox or console logs.'**
  String get authForgotCodeResent;

  /// No description provided for @authForgotEnterNumericCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit numeric verification code'**
  String get authForgotEnterNumericCode;

  /// No description provided for @authForgotCodeVerified.
  ///
  /// In en, this message translates to:
  /// **'Code verified successfully!'**
  String get authForgotCodeVerified;

  /// No description provided for @authForgotPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authForgotPasswordsMismatch;

  /// No description provided for @authForgotPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully! Please log in.'**
  String get authForgotPasswordUpdated;

  /// No description provided for @authForgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get authForgotTitle;

  /// No description provided for @authForgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a 6-digit verification code.'**
  String get authForgotSubtitle;

  /// No description provided for @authForgotCheckInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get authForgotCheckInboxTitle;

  /// No description provided for @authForgotCheckInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to {email}.'**
  String authForgotCheckInboxSubtitle(String email);

  /// No description provided for @authForgotNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get authForgotNewPasswordTitle;

  /// No description provided for @authForgotNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a secure new password for your account.'**
  String get authForgotNewPasswordSubtitle;

  /// No description provided for @authForgotSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get authForgotSendCode;

  /// No description provided for @authForgotCancelAndLogIn.
  ///
  /// In en, this message translates to:
  /// **'Cancel and log in'**
  String get authForgotCancelAndLogIn;

  /// No description provided for @authVerificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authVerificationCodeLabel;

  /// No description provided for @authVerificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get authVerificationCodeHint;

  /// No description provided for @authVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get authVerifyCode;

  /// No description provided for @authChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get authChangeEmail;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPasswordLabel;

  /// No description provided for @authNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get authNewPasswordHint;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Retype new password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPassword;

  /// No description provided for @authStartOver.
  ///
  /// In en, this message translates to:
  /// **'Start over / change email'**
  String get authStartOver;

  /// No description provided for @authVerifyEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit verification code.'**
  String get authVerifyEnterCode;

  /// No description provided for @authVerifiedWelcome.
  ///
  /// In en, this message translates to:
  /// **'Account verified. Welcome to Finder!'**
  String get authVerifiedWelcome;

  /// No description provided for @authVerifyCodeResent.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent to your email.'**
  String get authVerifyCodeResent;

  /// No description provided for @authVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyTitle;

  /// No description provided for @authVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit verification code to your registered email address. Enter it below to activate your account.'**
  String get authVerifySubtitle;

  /// No description provided for @authVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify account'**
  String get authVerifyAccount;

  /// No description provided for @authGoogleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled by the user.'**
  String get authGoogleCancelled;

  /// No description provided for @authGoogleTokenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve Google ID token.'**
  String get authGoogleTokenFailed;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get authSessionExpired;

  /// No description provided for @authSocialSemantic.
  ///
  /// In en, this message translates to:
  /// **'Continue with social account'**
  String get authSocialSemantic;

  /// No description provided for @authLegalAgreePrefix.
  ///
  /// In en, this message translates to:
  /// **'By creating an account you agree to the '**
  String get authLegalAgreePrefix;

  /// No description provided for @authLegalAgreeAnd.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get authLegalAgreeAnd;

  /// No description provided for @authLegalAgreeSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get authLegalAgreeSuffix;

  /// No description provided for @onboardLostTitle.
  ///
  /// In en, this message translates to:
  /// **'Lost something? Post it in a minute'**
  String get onboardLostTitle;

  /// No description provided for @onboardLostDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a photo, where and when you lost it. Finder shows it to people nearby and alerts you the moment something matches.'**
  String get onboardLostDescription;

  /// No description provided for @onboardFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Found something? Help it get home'**
  String get onboardFoundTitle;

  /// No description provided for @onboardFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Post what you found. A person reviews every post, and the app matches it with people searching, in their own language.'**
  String get onboardFoundDescription;

  /// No description provided for @onboardConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat, verify, hand it back safely'**
  String get onboardConnectTitle;

  /// No description provided for @onboardConnectDescription.
  ///
  /// In en, this message translates to:
  /// **'Message inside the app, ask for a detail only the owner knows, and meet in a public place. Help & Support walks you through every step.'**
  String get onboardConnectDescription;

  /// No description provided for @onboardGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardGetStarted;

  /// No description provided for @legalOpenWebVersion.
  ///
  /// In en, this message translates to:
  /// **'Open web version'**
  String get legalOpenWebVersion;

  /// No description provided for @legalCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String legalCouldNotOpen(String url);

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated 13 September 2026'**
  String get legalUpdated;

  /// No description provided for @legalPrivacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Finder helps people report lost and found items and get in touch with each other. This policy explains what data the app collects, why, and what control you have over it.'**
  String get legalPrivacyIntro;

  /// No description provided for @legalPrivacy1Heading.
  ///
  /// In en, this message translates to:
  /// **'1. Data we collect'**
  String get legalPrivacy1Heading;

  /// No description provided for @legalPrivacy1Body1.
  ///
  /// In en, this message translates to:
  /// **'Account data: e-mail, password (stored as a salted hash), name, nickname and optionally phone, city and occupation.'**
  String get legalPrivacy1Body1;

  /// No description provided for @legalPrivacy1Body2.
  ///
  /// In en, this message translates to:
  /// **'Posts: title, description, category, location text, date and photos you attach.'**
  String get legalPrivacy1Body2;

  /// No description provided for @legalPrivacy1Body3.
  ///
  /// In en, this message translates to:
  /// **'Messages: the text and photos you exchange with other members.'**
  String get legalPrivacy1Body3;

  /// No description provided for @legalPrivacy1Body4.
  ///
  /// In en, this message translates to:
  /// **'Identity verification (optional): photos of an identity document and a selfie, used only to grant the verified badge.'**
  String get legalPrivacy1Body4;

  /// No description provided for @legalPrivacy1Body5.
  ///
  /// In en, this message translates to:
  /// **'Technical data: request logs (IP address, endpoint, time) kept for security, plus anonymous crash reports and usage statistics (which screens are used, never the content of posts or messages).'**
  String get legalPrivacy1Body5;

  /// No description provided for @legalPrivacy1Body6.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in: we receive your e-mail, name and profile picture from Google.'**
  String get legalPrivacy1Body6;

  /// No description provided for @legalPrivacy2Heading.
  ///
  /// In en, this message translates to:
  /// **'2. How we use it'**
  String get legalPrivacy2Heading;

  /// No description provided for @legalPrivacy2Body1.
  ///
  /// In en, this message translates to:
  /// **'To run the service: show posts, deliver messages and notifications, and let members contact each other. To keep the community safe: reports, blocks and identity verification. To send transactional e-mails such as verification codes and password resets. Product news is only sent if you opt in.'**
  String get legalPrivacy2Body1;

  /// No description provided for @legalPrivacy2Body2.
  ///
  /// In en, this message translates to:
  /// **'We do not sell personal data and we do not show third-party advertising.'**
  String get legalPrivacy2Body2;

  /// No description provided for @legalPrivacy3Heading.
  ///
  /// In en, this message translates to:
  /// **'3. What other members can see'**
  String get legalPrivacy3Heading;

  /// No description provided for @legalPrivacy3Body.
  ///
  /// In en, this message translates to:
  /// **'Your name, photo and posts are visible to signed-in members. Your phone number is hidden unless you turn on sharing in Privacy & safety. Your e-mail address is never shown to other members. Members you block cannot see your posts or message you.'**
  String get legalPrivacy3Body;

  /// No description provided for @legalPrivacy4Heading.
  ///
  /// In en, this message translates to:
  /// **'4. Where data is stored'**
  String get legalPrivacy4Heading;

  /// No description provided for @legalPrivacy4Body.
  ///
  /// In en, this message translates to:
  /// **'Data is stored on our hosting provider\'s servers and photos on Cloudinary, both under their own data-processing terms. Data is transmitted over HTTPS.'**
  String get legalPrivacy4Body;

  /// No description provided for @legalPrivacy5Heading.
  ///
  /// In en, this message translates to:
  /// **'5. How long we keep it'**
  String get legalPrivacy5Heading;

  /// No description provided for @legalPrivacy5Body.
  ///
  /// In en, this message translates to:
  /// **'Account data is kept while your account exists. Verification documents are deleted once a decision has been made, and no later than 90 days after upload. Request logs are kept for 30 days.'**
  String get legalPrivacy5Body;

  /// No description provided for @legalPrivacy6Heading.
  ///
  /// In en, this message translates to:
  /// **'6. Your rights'**
  String get legalPrivacy6Heading;

  /// No description provided for @legalPrivacy6Body1.
  ///
  /// In en, this message translates to:
  /// **'Access and correction: edit your profile in the app at any time.'**
  String get legalPrivacy6Body1;

  /// No description provided for @legalPrivacy6Body2.
  ///
  /// In en, this message translates to:
  /// **'Deletion: delete your account from Privacy & safety → Delete account. Your posts, conversations, settings and profile are removed immediately; backups expire within 30 days.'**
  String get legalPrivacy6Body2;

  /// No description provided for @legalPrivacy6Body3.
  ///
  /// In en, this message translates to:
  /// **'Portability and questions: write to privacy@finder.app.'**
  String get legalPrivacy6Body3;

  /// No description provided for @legalPrivacy7Heading.
  ///
  /// In en, this message translates to:
  /// **'7. Children'**
  String get legalPrivacy7Heading;

  /// No description provided for @legalPrivacy7Body.
  ///
  /// In en, this message translates to:
  /// **'Finder is not intended for children under 16. We remove accounts we learn belong to children.'**
  String get legalPrivacy7Body;

  /// No description provided for @legalPrivacy8Heading.
  ///
  /// In en, this message translates to:
  /// **'8. Changes'**
  String get legalPrivacy8Heading;

  /// No description provided for @legalPrivacy8Body.
  ///
  /// In en, this message translates to:
  /// **'We will announce material changes in the app before they take effect. The date at the top shows when this policy was last revised.'**
  String get legalPrivacy8Body;

  /// No description provided for @legalTermsIntro.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or using Finder you agree to these terms. If you do not agree, do not use the service.'**
  String get legalTermsIntro;

  /// No description provided for @legalTerms1Heading.
  ///
  /// In en, this message translates to:
  /// **'1. The service'**
  String get legalTerms1Heading;

  /// No description provided for @legalTerms1Body.
  ///
  /// In en, this message translates to:
  /// **'Finder is a community notice board for lost and found items. We provide the place to post and talk; we do not take part in hand-overs, do not verify that an item belongs to a member, and are not a party to any reward arrangement between members.'**
  String get legalTerms1Body;

  /// No description provided for @legalTerms2Heading.
  ///
  /// In en, this message translates to:
  /// **'2. Your account'**
  String get legalTerms2Heading;

  /// No description provided for @legalTerms2Body.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 16 years old. Keep your password private; you are responsible for activity on your account. One person, one account. Do not impersonate others.'**
  String get legalTerms2Body;

  /// No description provided for @legalTerms3Heading.
  ///
  /// In en, this message translates to:
  /// **'3. Your content'**
  String get legalTerms3Heading;

  /// No description provided for @legalTerms3Body.
  ///
  /// In en, this message translates to:
  /// **'You keep ownership of what you post. You give Finder a licence to store, display and distribute it inside the service so that other members can see it. Only post photos and information you have the right to share.'**
  String get legalTerms3Body;

  /// No description provided for @legalTerms4Heading.
  ///
  /// In en, this message translates to:
  /// **'4. Rules of conduct'**
  String get legalTerms4Heading;

  /// No description provided for @legalTerms4Body1.
  ///
  /// In en, this message translates to:
  /// **'You must not: post false reports or claim an item that is not yours; ask for payment before returning an item or use the service for scams; harass, threaten or discriminate against other members; post illegal content or content that infringes someone else\'s rights; scrape the service, probe the API or interfere with its operation.'**
  String get legalTerms4Body1;

  /// No description provided for @legalTerms4Body2.
  ///
  /// In en, this message translates to:
  /// **'We may remove content, suspend or delete accounts that break these rules, and cooperate with law enforcement where required.'**
  String get legalTerms4Body2;

  /// No description provided for @legalTerms5Heading.
  ///
  /// In en, this message translates to:
  /// **'5. Safety'**
  String get legalTerms5Heading;

  /// No description provided for @legalTerms5Body.
  ///
  /// In en, this message translates to:
  /// **'Meet in public places, bring someone with you, and never pay a reward before you have your item. Use in-app chat so you can block and report. Finder cannot guarantee the honesty of any member.'**
  String get legalTerms5Body;

  /// No description provided for @legalTerms6Heading.
  ///
  /// In en, this message translates to:
  /// **'6. Identity verification'**
  String get legalTerms6Heading;

  /// No description provided for @legalTerms6Body.
  ///
  /// In en, this message translates to:
  /// **'The verified badge means a member submitted an identity document that our team reviewed. It is not a guarantee of identity or good faith.'**
  String get legalTerms6Body;

  /// No description provided for @legalTerms7Heading.
  ///
  /// In en, this message translates to:
  /// **'7. Availability and changes'**
  String get legalTerms7Heading;

  /// No description provided for @legalTerms7Body.
  ///
  /// In en, this message translates to:
  /// **'We may change or discontinue features at any time. We try to keep the service available but do not promise uninterrupted operation.'**
  String get legalTerms7Body;

  /// No description provided for @legalTerms8Heading.
  ///
  /// In en, this message translates to:
  /// **'8. Liability'**
  String get legalTerms8Heading;

  /// No description provided for @legalTerms8Body.
  ///
  /// In en, this message translates to:
  /// **'To the extent permitted by law, Finder is provided \"as is\" and we are not liable for losses arising from your use of the service, from other members\' conduct, or from items that are not recovered.'**
  String get legalTerms8Body;

  /// No description provided for @legalTerms9Heading.
  ///
  /// In en, this message translates to:
  /// **'9. Termination'**
  String get legalTerms9Heading;

  /// No description provided for @legalTerms9Body.
  ///
  /// In en, this message translates to:
  /// **'You can delete your account at any time from Privacy & safety. We can terminate accounts that violate these terms.'**
  String get legalTerms9Body;

  /// No description provided for @legalTerms10Heading.
  ///
  /// In en, this message translates to:
  /// **'10. Contact'**
  String get legalTerms10Heading;

  /// No description provided for @legalTerms10Body.
  ///
  /// In en, this message translates to:
  /// **'Questions about these terms: support@finder.app'**
  String get legalTerms10Body;

  /// No description provided for @adminConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin console'**
  String get adminConsoleTitle;

  /// No description provided for @adminConsoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Users, posts, reports and verification'**
  String get adminConsoleSubtitle;

  /// No description provided for @adminModeration.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get adminModeration;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search, verify, suspend, promote or delete accounts'**
  String get adminUsersTileSubtitle;

  /// No description provided for @adminPostsTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every lost and found post, open or returned'**
  String get adminPostsTileSubtitle;

  /// No description provided for @adminReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminReportsTitle;

  /// No description provided for @adminReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Posts flagged by members'**
  String get adminReportsSubtitle;

  /// No description provided for @adminVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get adminVerificationTitle;

  /// No description provided for @adminVerificationTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review documents and selfies'**
  String get adminVerificationTileSubtitle;

  /// No description provided for @adminStatMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get adminStatMembers;

  /// No description provided for @adminVerifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get adminVerifiedLabel;

  /// No description provided for @adminStatOpenPosts.
  ///
  /// In en, this message translates to:
  /// **'Open posts'**
  String get adminStatOpenPosts;

  /// No description provided for @adminStatToVerify.
  ///
  /// In en, this message translates to:
  /// **'To verify'**
  String get adminStatToVerify;

  /// No description provided for @adminSuspendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get adminSuspendedLabel;

  /// No description provided for @adminStatMessages24h.
  ///
  /// In en, this message translates to:
  /// **'Messages 24h'**
  String get adminStatMessages24h;

  /// No description provided for @adminPostsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything on the feed'**
  String get adminPostsSubtitle;

  /// No description provided for @adminPostsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, description, owner'**
  String get adminPostsSearchHint;

  /// No description provided for @adminFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAll;

  /// No description provided for @adminFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminFilterOpen;

  /// No description provided for @adminFilterReported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get adminFilterReported;

  /// No description provided for @adminFilterHandled.
  ///
  /// In en, this message translates to:
  /// **'Handled'**
  String get adminFilterHandled;

  /// No description provided for @adminFilterAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get adminFilterAdmins;

  /// No description provided for @adminFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminFilterPending;

  /// No description provided for @adminFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get adminFilterApproved;

  /// No description provided for @adminFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminFilterRejected;

  /// No description provided for @adminNoPostsHere.
  ///
  /// In en, this message translates to:
  /// **'No posts here'**
  String get adminNoPostsHere;

  /// No description provided for @adminPostSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'by {owner} · {status}'**
  String adminPostSheetSubtitle(String owner, String status);

  /// No description provided for @adminStatusReturned.
  ///
  /// In en, this message translates to:
  /// **'returned'**
  String get adminStatusReturned;

  /// No description provided for @adminStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get adminStatusOpen;

  /// No description provided for @adminOpenThePost.
  ///
  /// In en, this message translates to:
  /// **'Open the post'**
  String get adminOpenThePost;

  /// No description provided for @adminReopenThePost.
  ///
  /// In en, this message translates to:
  /// **'Reopen the post'**
  String get adminReopenThePost;

  /// No description provided for @adminPostReopened.
  ///
  /// In en, this message translates to:
  /// **'Post reopened.'**
  String get adminPostReopened;

  /// No description provided for @adminRemoveThePost.
  ///
  /// In en, this message translates to:
  /// **'Remove the post'**
  String get adminRemoveThePost;

  /// No description provided for @adminRemovePostOwnerNotified.
  ///
  /// In en, this message translates to:
  /// **'The owner is notified with your reason'**
  String get adminRemovePostOwnerNotified;

  /// No description provided for @adminPostRemoved.
  ///
  /// In en, this message translates to:
  /// **'Post removed.'**
  String get adminPostRemoved;

  /// No description provided for @adminRemovePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this post?'**
  String get adminRemovePostTitle;

  /// No description provided for @adminRemovePostReasonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short reason is sent to the owner.'**
  String get adminRemovePostReasonSubtitle;

  /// No description provided for @adminReasonOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get adminReasonOptionalLabel;

  /// No description provided for @adminReasonPostHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Not a lost or found item'**
  String get adminReasonPostHint;

  /// No description provided for @adminNoOpenReports.
  ///
  /// In en, this message translates to:
  /// **'No open reports'**
  String get adminNoOpenReports;

  /// No description provided for @adminNothingHandledYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing handled yet'**
  String get adminNothingHandledYet;

  /// No description provided for @adminBadgeOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get adminBadgeOpen;

  /// No description provided for @adminBadgeHandled.
  ///
  /// In en, this message translates to:
  /// **'HANDLED'**
  String get adminBadgeHandled;

  /// No description provided for @adminNoReasonGiven.
  ///
  /// In en, this message translates to:
  /// **'No reason given'**
  String get adminNoReasonGiven;

  /// No description provided for @adminQuotedReason.
  ///
  /// In en, this message translates to:
  /// **'\"{reason}\"'**
  String adminQuotedReason(String reason);

  /// No description provided for @adminReportedBy.
  ///
  /// In en, this message translates to:
  /// **'Reported by {name} · {time}'**
  String adminReportedBy(String name, String time);

  /// No description provided for @adminPostBySuffix.
  ///
  /// In en, this message translates to:
  /// **' · post by {name}'**
  String adminPostBySuffix(String name);

  /// No description provided for @adminDismissReport.
  ///
  /// In en, this message translates to:
  /// **'Dismiss the report'**
  String get adminDismissReport;

  /// No description provided for @adminPostStaysUp.
  ///
  /// In en, this message translates to:
  /// **'The post stays up'**
  String get adminPostStaysUp;

  /// No description provided for @adminRemovePostSettles.
  ///
  /// In en, this message translates to:
  /// **'Settles every report on it; the owner is notified'**
  String get adminRemovePostSettles;

  /// No description provided for @adminRemovePostConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" and its chats are deleted. This cannot be undone.'**
  String adminRemovePostConfirmBody(String title);

  /// No description provided for @adminReportDismissed.
  ///
  /// In en, this message translates to:
  /// **'Report dismissed.'**
  String get adminReportDismissed;

  /// No description provided for @adminUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts on Finder'**
  String get adminUsersSubtitle;

  /// No description provided for @adminUsersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, nickname or e-mail'**
  String get adminUsersSearchHint;

  /// No description provided for @adminNoAccountsMatch.
  ///
  /// In en, this message translates to:
  /// **'No accounts match'**
  String get adminNoAccountsMatch;

  /// No description provided for @adminRemoveVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Remove verified badge'**
  String get adminRemoveVerifiedBadge;

  /// No description provided for @adminMarkAsVerified.
  ///
  /// In en, this message translates to:
  /// **'Mark as verified'**
  String get adminMarkAsVerified;

  /// No description provided for @adminRemoveBadgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The tick disappears from their profile and posts'**
  String get adminRemoveBadgeSubtitle;

  /// No description provided for @adminGrantBadgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grants the tick without a document review'**
  String get adminGrantBadgeSubtitle;

  /// No description provided for @adminVerifiedBadgeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Verified badge removed.'**
  String get adminVerifiedBadgeRemoved;

  /// No description provided for @adminMarkedAsVerified.
  ///
  /// In en, this message translates to:
  /// **'Marked as verified.'**
  String get adminMarkedAsVerified;

  /// No description provided for @adminRemoveAdminRole.
  ///
  /// In en, this message translates to:
  /// **'Remove admin role'**
  String get adminRemoveAdminRole;

  /// No description provided for @adminMakeAdministrator.
  ///
  /// In en, this message translates to:
  /// **'Make administrator'**
  String get adminMakeAdministrator;

  /// No description provided for @adminLoseConsoleAccess.
  ///
  /// In en, this message translates to:
  /// **'They lose access to this console'**
  String get adminLoseConsoleAccess;

  /// No description provided for @adminFullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full access to users, posts and reports'**
  String get adminFullAccess;

  /// No description provided for @adminRemoveAdminRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove admin role?'**
  String get adminRemoveAdminRoleTitle;

  /// No description provided for @adminMakeAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Make {name} an administrator?'**
  String adminMakeAdminTitle(String name);

  /// No description provided for @adminRemoveAdminBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will no longer be able to moderate Finder.'**
  String adminRemoveAdminBody(String name);

  /// No description provided for @adminMakeAdminBody.
  ///
  /// In en, this message translates to:
  /// **'Administrators can suspend or delete any account and remove any post.'**
  String get adminMakeAdminBody;

  /// No description provided for @adminRemoveRole.
  ///
  /// In en, this message translates to:
  /// **'Remove role'**
  String get adminRemoveRole;

  /// No description provided for @adminMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get adminMakeAdmin;

  /// No description provided for @adminRoleRemoved.
  ///
  /// In en, this message translates to:
  /// **'Admin role removed.'**
  String get adminRoleRemoved;

  /// No description provided for @adminNowAdmin.
  ///
  /// In en, this message translates to:
  /// **'{name} is now an admin.'**
  String adminNowAdmin(String name);

  /// No description provided for @adminLiftSuspension.
  ///
  /// In en, this message translates to:
  /// **'Lift suspension'**
  String get adminLiftSuspension;

  /// No description provided for @adminSuspendAccount.
  ///
  /// In en, this message translates to:
  /// **'Suspend account'**
  String get adminSuspendAccount;

  /// No description provided for @adminCanSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'They can sign in again'**
  String get adminCanSignInAgain;

  /// No description provided for @adminSignedOutCannotSignIn.
  ///
  /// In en, this message translates to:
  /// **'They are signed out and cannot sign in'**
  String get adminSignedOutCannotSignIn;

  /// No description provided for @adminLiftSuspensionTitle.
  ///
  /// In en, this message translates to:
  /// **'Lift the suspension?'**
  String get adminLiftSuspensionTitle;

  /// No description provided for @adminSuspendTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend {name}?'**
  String adminSuspendTitle(String name);

  /// No description provided for @adminLiftBody.
  ///
  /// In en, this message translates to:
  /// **'The account works normally again.'**
  String get adminLiftBody;

  /// No description provided for @adminSuspendBody.
  ///
  /// In en, this message translates to:
  /// **'Their posts stay visible. They lose access until you lift the suspension.'**
  String get adminSuspendBody;

  /// No description provided for @adminLift.
  ///
  /// In en, this message translates to:
  /// **'Lift'**
  String get adminLift;

  /// No description provided for @adminSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get adminSuspend;

  /// No description provided for @adminSuspensionLifted.
  ///
  /// In en, this message translates to:
  /// **'Suspension lifted.'**
  String get adminSuspensionLifted;

  /// No description provided for @adminAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account suspended.'**
  String get adminAccountSuspended;

  /// No description provided for @adminDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get adminDeleteAccount;

  /// No description provided for @adminDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes the account, its posts and chats. Cannot be undone.'**
  String get adminDeleteAccountSubtitle;

  /// No description provided for @adminDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String adminDeleteTitle(String name);

  /// No description provided for @adminDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Everything they posted and every chat they were in is erased permanently.'**
  String get adminDeleteBody;

  /// No description provided for @adminAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get adminAccountDeleted;

  /// No description provided for @adminYouSuffix.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String adminYouSuffix(String name);

  /// No description provided for @adminPostsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 post} other{{count} posts}}'**
  String adminPostsCount(int count);

  /// No description provided for @adminReportsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 report} other{{count} reports}}'**
  String adminReportsCount(int count);

  /// No description provided for @adminJoined.
  ///
  /// In en, this message translates to:
  /// **'joined {time}'**
  String adminJoined(String time);

  /// No description provided for @adminBadgeSuspended.
  ///
  /// In en, this message translates to:
  /// **'SUSPENDED'**
  String get adminBadgeSuspended;

  /// No description provided for @adminQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get adminQueueTitle;

  /// No description provided for @adminQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Identity verification requests'**
  String get adminQueueSubtitle;

  /// No description provided for @adminNothingToReview.
  ///
  /// In en, this message translates to:
  /// **'Nothing to review'**
  String get adminNothingToReview;

  /// No description provided for @adminNoRequestsHere.
  ///
  /// In en, this message translates to:
  /// **'No requests here'**
  String get adminNoRequestsHere;

  /// No description provided for @adminNewRequestsShowHere.
  ///
  /// In en, this message translates to:
  /// **'New verification requests will show up here.'**
  String get adminNewRequestsShowHere;

  /// No description provided for @adminBadgeRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get adminBadgeRejected;

  /// No description provided for @adminBadgePending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get adminBadgePending;

  /// No description provided for @adminDocIdCard.
  ///
  /// In en, this message translates to:
  /// **'Identity card'**
  String get adminDocIdCard;

  /// No description provided for @adminDocDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license'**
  String get adminDocDriversLicense;

  /// No description provided for @adminDocPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get adminDocPassport;

  /// No description provided for @adminDocDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get adminDocDocument;

  /// No description provided for @adminSubmitted.
  ///
  /// In en, this message translates to:
  /// **'{doc} · submitted {time}'**
  String adminSubmitted(String doc, String time);

  /// No description provided for @adminReviewedStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, approved{approved {time}} rejected{rejected {time}} other{{status} {time}}}'**
  String adminReviewedStatus(String status, String time);

  /// No description provided for @adminReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String adminReasonPrefix(String reason);

  /// No description provided for @adminDocumentSection.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get adminDocumentSection;

  /// No description provided for @adminStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1'**
  String get adminStep1;

  /// No description provided for @adminLiveSelfie.
  ///
  /// In en, this message translates to:
  /// **'Live selfie'**
  String get adminLiveSelfie;

  /// No description provided for @adminStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2'**
  String get adminStep2;

  /// No description provided for @adminFrontOfId.
  ///
  /// In en, this message translates to:
  /// **'Front of ID'**
  String get adminFrontOfId;

  /// No description provided for @adminPhotoPage.
  ///
  /// In en, this message translates to:
  /// **'Photo page'**
  String get adminPhotoPage;

  /// No description provided for @adminBackOfId.
  ///
  /// In en, this message translates to:
  /// **'Back of ID'**
  String get adminBackOfId;

  /// No description provided for @adminSelfieCaption.
  ///
  /// In en, this message translates to:
  /// **'Selfie taken with the front camera'**
  String get adminSelfieCaption;

  /// No description provided for @adminReviewGuidance.
  ///
  /// In en, this message translates to:
  /// **'Compare the face on the document with the selfie, check the name matches the account, and that the document is not expired or edited.'**
  String get adminReviewGuidance;

  /// No description provided for @adminTapToZoom.
  ///
  /// In en, this message translates to:
  /// **'{caption} · tap to zoom'**
  String adminTapToZoom(String caption);

  /// No description provided for @adminReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminReject;

  /// No description provided for @adminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApprove;

  /// No description provided for @adminApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve this identity?'**
  String get adminApproveTitle;

  /// No description provided for @adminApproveBody.
  ///
  /// In en, this message translates to:
  /// **'{name} gets the verified badge and a notification.'**
  String adminApproveBody(String name);

  /// No description provided for @adminIdentityApproved.
  ///
  /// In en, this message translates to:
  /// **'Identity approved.'**
  String get adminIdentityApproved;

  /// No description provided for @adminRejectRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get adminRejectRequestTitle;

  /// No description provided for @adminRejectReasonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The reason is sent to {name} so they can fix it.'**
  String adminRejectReasonSubtitle(String name);

  /// No description provided for @adminReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get adminReasonLabel;

  /// No description provided for @adminRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The selfie is too dark to compare with the document.'**
  String get adminRejectReasonHint;

  /// No description provided for @adminRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get adminRequestRejected;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get stateLoading;

  /// No description provided for @uiShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get uiShowPassword;

  /// No description provided for @uiHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get uiHidePassword;

  /// No description provided for @uiCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get uiCouldNotLoad;

  /// No description provided for @adminStatToApprove.
  ///
  /// In en, this message translates to:
  /// **'To approve'**
  String get adminStatToApprove;

  /// No description provided for @adminStatRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get adminStatRejected;

  /// No description provided for @adminFilterPendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String adminFilterPendingCount(int count);

  /// No description provided for @adminNothingToApprove.
  ///
  /// In en, this message translates to:
  /// **'Nothing to approve'**
  String get adminNothingToApprove;

  /// No description provided for @adminNothingToApproveBody.
  ///
  /// In en, this message translates to:
  /// **'New posts show up here before anyone else can see them.'**
  String get adminNothingToApproveBody;

  /// No description provided for @adminReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review this post'**
  String get adminReviewTitle;

  /// No description provided for @adminRiskLabel.
  ///
  /// In en, this message translates to:
  /// **'AI risk {score}'**
  String adminRiskLabel(int score);

  /// No description provided for @adminRiskUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI check unavailable'**
  String get adminRiskUnavailable;

  /// No description provided for @adminRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Looks fine'**
  String get adminRiskLow;

  /// No description provided for @adminRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'Check carefully'**
  String get adminRiskMedium;

  /// No description provided for @adminRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'Likely reject'**
  String get adminRiskHigh;

  /// No description provided for @adminOriginalText.
  ///
  /// In en, this message translates to:
  /// **'Original ({lang})'**
  String adminOriginalText(String lang);

  /// No description provided for @adminRejectPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this post?'**
  String get adminRejectPostTitle;

  /// No description provided for @adminRejectPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The reason is sent to the owner so they can fix it and resubmit.'**
  String get adminRejectPostSubtitle;

  /// No description provided for @adminRejectPostHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. The photo does not show the item.'**
  String get adminRejectPostHint;

  /// No description provided for @adminPostApproved.
  ///
  /// In en, this message translates to:
  /// **'Post approved. It is live now.'**
  String get adminPostApproved;

  /// No description provided for @adminPostRejected.
  ///
  /// In en, this message translates to:
  /// **'Post rejected. The owner has been told.'**
  String get adminPostRejected;

  /// No description provided for @adminStatusPending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get adminStatusPending;

  /// No description provided for @adminStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'rejected'**
  String get adminStatusRejected;

  /// No description provided for @adminStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'archived'**
  String get adminStatusExpired;

  /// No description provided for @adminAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get adminAiTitle;

  /// No description provided for @adminAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provider, model and key for translations and the pre-check'**
  String get adminAiSubtitle;

  /// No description provided for @adminAiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured. Posts are not translated or pre-checked.'**
  String get adminAiNotConfigured;

  /// No description provided for @adminAiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get adminAiKeyLabel;

  /// No description provided for @adminAiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the key from the provider\'s dashboard'**
  String get adminAiKeyHint;

  /// No description provided for @adminAiKeyBody.
  ///
  /// In en, this message translates to:
  /// **'The key is verified once, stored encrypted on the server and never shown again. It works for every user right away. Each new post costs roughly one cent on the cheapest models.'**
  String get adminAiKeyBody;

  /// No description provided for @adminAiProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get adminAiProvider;

  /// No description provided for @adminAiModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get adminAiModelLabel;

  /// No description provided for @adminAiModelHint.
  ///
  /// In en, this message translates to:
  /// **'Leave the default unless you know better'**
  String get adminAiModelHint;

  /// No description provided for @adminAiBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get adminAiBaseUrlLabel;

  /// No description provided for @adminAiBaseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://openrouter.ai/api/v1'**
  String get adminAiBaseUrlHint;

  /// No description provided for @adminAiKeyHintReplace.
  ///
  /// In en, this message translates to:
  /// **'Paste a new key to replace the saved one'**
  String get adminAiKeyHintReplace;

  /// No description provided for @adminAiSourceDb.
  ///
  /// In en, this message translates to:
  /// **'Saved from the app'**
  String get adminAiSourceDb;

  /// No description provided for @adminAiSourceEnv.
  ///
  /// In en, this message translates to:
  /// **'Set on the server'**
  String get adminAiSourceEnv;

  /// No description provided for @adminAiSourceNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get adminAiSourceNone;

  /// No description provided for @adminAiBacklog.
  ///
  /// In en, this message translates to:
  /// **'{translations} posts waiting for translation · {scores} waiting for a risk score'**
  String adminAiBacklog(int translations, int scores);

  /// No description provided for @adminAiSaved.
  ///
  /// In en, this message translates to:
  /// **'Key verified. Translating {count} posts for everyone…'**
  String adminAiSaved(int count);

  /// No description provided for @adminAiRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove key'**
  String get adminAiRemove;

  /// No description provided for @adminAiRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'New posts will stop being translated and pre-checked until a key is saved again.'**
  String get adminAiRemoveBody;

  /// No description provided for @adminAiRemoved.
  ///
  /// In en, this message translates to:
  /// **'AI settings removed.'**
  String get adminAiRemoved;

  /// No description provided for @onboardStepReport.
  ///
  /// In en, this message translates to:
  /// **'Step 1 · Report'**
  String get onboardStepReport;

  /// No description provided for @onboardStepMatch.
  ///
  /// In en, this message translates to:
  /// **'Step 2 · Match'**
  String get onboardStepMatch;

  /// No description provided for @onboardStepReturn.
  ///
  /// In en, this message translates to:
  /// **'Step 3 · Return'**
  String get onboardStepReturn;

  /// No description provided for @onboardHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardHaveAccount;

  /// No description provided for @onboardSampleLost.
  ///
  /// In en, this message translates to:
  /// **'LOST'**
  String get onboardSampleLost;

  /// No description provided for @onboardSampleFound.
  ///
  /// In en, this message translates to:
  /// **'FOUND'**
  String get onboardSampleFound;

  /// No description provided for @onboardSamplePlace.
  ///
  /// In en, this message translates to:
  /// **'Erbil · Family Mall'**
  String get onboardSamplePlace;

  /// No description provided for @onboardSampleMinute.
  ///
  /// In en, this message translates to:
  /// **'Posted in 1 min'**
  String get onboardSampleMinute;

  /// No description provided for @onboardSampleMatch.
  ///
  /// In en, this message translates to:
  /// **'92% match'**
  String get onboardSampleMatch;

  /// No description provided for @onboardSampleReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get onboardSampleReviewed;

  /// No description provided for @onboardSampleAsk.
  ///
  /// In en, this message translates to:
  /// **'What\'s engraved on the back?'**
  String get onboardSampleAsk;

  /// No description provided for @onboardSampleAnswer.
  ///
  /// In en, this message translates to:
  /// **'My initials, A.S. 😊'**
  String get onboardSampleAnswer;

  /// No description provided for @onboardSampleVerified.
  ///
  /// In en, this message translates to:
  /// **'Owner verified'**
  String get onboardSampleVerified;

  /// No description provided for @onboardSampleMeet.
  ///
  /// In en, this message translates to:
  /// **'Meet in public'**
  String get onboardSampleMeet;

  /// No description provided for @chatConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get chatConversationTitle;

  /// No description provided for @chatNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversation not found'**
  String get chatNotFoundTitle;

  /// No description provided for @chatNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a chat from a post or from Messages.'**
  String get chatNotFoundSubtitle;

  /// No description provided for @chatLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get chatLoadingMessages;

  /// No description provided for @chatSayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello to {name}'**
  String chatSayHello(String name);

  /// No description provided for @chatStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation by sending a message.'**
  String get chatStartSubtitle;

  /// No description provided for @chatAskAbout.
  ///
  /// In en, this message translates to:
  /// **'Ask about \"{item}\" or arrange a safe hand-over.'**
  String chatAskAbout(String item);

  /// No description provided for @chatDirectMessageViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Direct message · view profile'**
  String get chatDirectMessageViewProfile;

  /// No description provided for @chatDirectMessage.
  ///
  /// In en, this message translates to:
  /// **'Direct message'**
  String get chatDirectMessage;

  /// No description provided for @chatAboutItem.
  ///
  /// In en, this message translates to:
  /// **'About \"{item}\"'**
  String chatAboutItem(String item);

  /// No description provided for @chatReopenPost.
  ///
  /// In en, this message translates to:
  /// **'Reopen the post'**
  String get chatReopenPost;

  /// No description provided for @chatReopenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show it on Home again'**
  String get chatReopenSubtitle;

  /// No description provided for @chatReturnedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The item is back with its owner'**
  String get chatReturnedSubtitle;

  /// No description provided for @chatViewPost.
  ///
  /// In en, this message translates to:
  /// **'View the post'**
  String get chatViewPost;

  /// No description provided for @chatReportPost.
  ///
  /// In en, this message translates to:
  /// **'Report the post'**
  String get chatReportPost;

  /// No description provided for @chatPostReported.
  ///
  /// In en, this message translates to:
  /// **'Thanks, the post has been reported.'**
  String get chatPostReported;

  /// No description provided for @chatReopenTitle.
  ///
  /// In en, this message translates to:
  /// **'Reopen this post?'**
  String get chatReopenTitle;

  /// No description provided for @chatMarkReturnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as returned?'**
  String get chatMarkReturnedTitle;

  /// No description provided for @chatReopenBody.
  ///
  /// In en, this message translates to:
  /// **'\"{item}\" will show on Home again as an open post.'**
  String chatReopenBody(String item);

  /// No description provided for @chatMarkReturnedBody.
  ///
  /// In en, this message translates to:
  /// **'\"{item}\" leaves the Home feed but stays visible in Search. Everyone in this chat gets a note.'**
  String chatMarkReturnedBody(String item);

  /// No description provided for @chatPostReopened.
  ///
  /// In en, this message translates to:
  /// **'Post reopened.'**
  String get chatPostReopened;

  /// No description provided for @chatAutoReopened.
  ///
  /// In en, this message translates to:
  /// **'I reopened this post.'**
  String get chatAutoReopened;

  /// No description provided for @chatAutoReturned.
  ///
  /// In en, this message translates to:
  /// **'I marked this item as returned. Thank you!'**
  String get chatAutoReturned;

  /// No description provided for @chatYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get chatYourMessage;

  /// No description provided for @chatMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessage;

  /// No description provided for @chatReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatReply;

  /// No description provided for @chatCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get chatCopyText;

  /// No description provided for @chatDeleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get chatDeleteForEveryone;

  /// No description provided for @chatDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this message?'**
  String get chatDeleteTitle;

  /// No description provided for @chatDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed for everyone in this chat. This cannot be undone.'**
  String get chatDeleteBody;

  /// No description provided for @chatSendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send a photo'**
  String get chatSendPhoto;

  /// No description provided for @chatWriteReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get chatWriteReplyHint;

  /// No description provided for @chatTypeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatTypeMessageHint;

  /// No description provided for @chatMicPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access to send voice messages.'**
  String get chatMicPermission;

  /// No description provided for @chatSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSendMessage;

  /// No description provided for @chatNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get chatNotSent;

  /// No description provided for @chatYouSaid.
  ///
  /// In en, this message translates to:
  /// **'You said'**
  String get chatYouSaid;

  /// No description provided for @chatTheySaid.
  ///
  /// In en, this message translates to:
  /// **'They said'**
  String get chatTheySaid;

  /// No description provided for @chatCancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get chatCancelReply;

  /// No description provided for @chatNewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String chatNewCount(int count);

  /// No description provided for @chatLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get chatLatest;

  /// No description provided for @chatSignInToMessage.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to send messages.'**
  String get chatSignInToMessage;

  /// No description provided for @chatOwnPost.
  ///
  /// In en, this message translates to:
  /// **'This is your own post.'**
  String get chatOwnPost;

  /// No description provided for @chatOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the conversation.'**
  String get chatOpenFailed;

  /// No description provided for @chatLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load messages.'**
  String get chatLoadFailed;

  /// No description provided for @chatNotSentFailure.
  ///
  /// In en, this message translates to:
  /// **'Message not sent.'**
  String get chatNotSentFailure;

  /// No description provided for @chatNothingToRetry.
  ///
  /// In en, this message translates to:
  /// **'Nothing to retry.'**
  String get chatNothingToRetry;

  /// No description provided for @chatDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the message.'**
  String get chatDeleteFailed;

  /// No description provided for @msgDeleted.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get msgDeleted;

  /// No description provided for @msgVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get msgVoiceMessage;

  /// No description provided for @msgPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get msgPhoto;

  /// No description provided for @msgNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get msgNoMessagesYet;

  /// No description provided for @msgNewConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get msgNewConversation;

  /// No description provided for @msgNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get msgNewChat;

  /// No description provided for @msgUnreadConversations.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread conversation} other{{count} unread conversations}}'**
  String msgUnreadConversations(int count);

  /// No description provided for @msgSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat safely with owners and finders'**
  String get msgSubtitle;

  /// No description provided for @msgSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations…'**
  String get msgSearchHint;

  /// No description provided for @msgLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading conversations...'**
  String get msgLoading;

  /// No description provided for @msgNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get msgNoConversations;

  /// No description provided for @msgNoConversationsFound.
  ///
  /// In en, this message translates to:
  /// **'No conversations found'**
  String get msgNoConversationsFound;

  /// No description provided for @msgEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact an owner or finder from any post, or start a new chat.'**
  String get msgEmptySubtitle;

  /// No description provided for @msgTryAnother.
  ///
  /// In en, this message translates to:
  /// **'Try another name or keyword.'**
  String get msgTryAnother;

  /// No description provided for @notifUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notifUnreadCount(int count);

  /// No description provided for @notifCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up'**
  String get notifCaughtUp;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifMarkAllRead;

  /// No description provided for @notifLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading notifications...'**
  String get notifLoading;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will hear from us when someone messages you, your post gets activity, or an item is resolved.'**
  String get notifEmptySubtitle;

  /// No description provided for @notifUnreadSemantics.
  ///
  /// In en, this message translates to:
  /// **'Unread notification'**
  String get notifUnreadSemantics;

  /// No description provided for @notifLoadingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Loading preferences...'**
  String get notifLoadingPreferences;

  /// No description provided for @notifStayConnected.
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get notifStayConnected;

  /// No description provided for @notifStayConnectedBody.
  ///
  /// In en, this message translates to:
  /// **'Choose which moments create a notification. Changes are saved instantly.'**
  String get notifStayConnectedBody;

  /// No description provided for @notifAll.
  ///
  /// In en, this message translates to:
  /// **'All notifications'**
  String get notifAll;

  /// No description provided for @notifAllMuted.
  ///
  /// In en, this message translates to:
  /// **'Everything is muted'**
  String get notifAllMuted;

  /// No description provided for @notifAllOff.
  ///
  /// In en, this message translates to:
  /// **'Turn everything off at once'**
  String get notifAllOff;

  /// No description provided for @notifConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get notifConversations;

  /// No description provided for @notifNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get notifNewMessage;

  /// No description provided for @notifNewMessageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone writes to you about a post'**
  String get notifNewMessageSubtitle;

  /// No description provided for @notifSmartMatching.
  ///
  /// In en, this message translates to:
  /// **'Smart matching'**
  String get notifSmartMatching;

  /// No description provided for @notifItemMatch.
  ///
  /// In en, this message translates to:
  /// **'Item match alerts'**
  String get notifItemMatch;

  /// No description provided for @notifItemMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When a new post looks like something you lost or found'**
  String get notifItemMatchSubtitle;

  /// No description provided for @notifSmartBadge.
  ///
  /// In en, this message translates to:
  /// **'SMART'**
  String get notifSmartBadge;

  /// No description provided for @notifPostUpdates.
  ///
  /// In en, this message translates to:
  /// **'Post updates'**
  String get notifPostUpdates;

  /// No description provided for @notifPostUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When an item you chatted about is resolved'**
  String get notifPostUpdatesSubtitle;

  /// No description provided for @notifFromFinder.
  ///
  /// In en, this message translates to:
  /// **'From Finder'**
  String get notifFromFinder;

  /// No description provided for @notifTips.
  ///
  /// In en, this message translates to:
  /// **'Tips and news'**
  String get notifTips;

  /// No description provided for @notifTipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Occasional product updates. Off by default.'**
  String get notifTipsSubtitle;

  /// No description provided for @notifEmailCopies.
  ///
  /// In en, this message translates to:
  /// **'E-mail copies'**
  String get notifEmailCopies;

  /// No description provided for @notifEmailCopiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Also send important notifications by e-mail'**
  String get notifEmailCopiesSubtitle;

  /// No description provided for @notifFooter.
  ///
  /// In en, this message translates to:
  /// **'Notifications are delivered inside the app. Push delivery to your phone will follow the same preferences.'**
  String get notifFooter;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & safety'**
  String get privacyTitle;

  /// No description provided for @privacyBlockMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Block a member'**
  String get privacyBlockMemberTitle;

  /// No description provided for @privacyAdminCannotBlock.
  ///
  /// In en, this message translates to:
  /// **'Finder administrators cannot be blocked.'**
  String get privacyAdminCannotBlock;

  /// No description provided for @privacyDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get privacyDeleteAccountTitle;

  /// No description provided for @privacyDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your posts, conversations, saved items and profile are removed immediately. This cannot be undone.'**
  String get privacyDeleteAccountBody;

  /// No description provided for @privacyTypeDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get privacyTypeDeleteLabel;

  /// No description provided for @privacyPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get privacyPasswordLabel;

  /// No description provided for @privacyTypeDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get privacyTypeDeleteHint;

  /// No description provided for @privacyPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get privacyPasswordHint;

  /// No description provided for @privacyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get privacyDeleteAccount;

  /// No description provided for @privacyTypeDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm.'**
  String get privacyTypeDeleteError;

  /// No description provided for @privacyEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get privacyEnterPassword;

  /// No description provided for @privacyAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get privacyAccountDeleted;

  /// No description provided for @privacyLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get privacyLoadingSettings;

  /// No description provided for @privacyHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your data, your control'**
  String get privacyHeadline;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Decide what other members can see and who can reach you. Changes apply immediately.'**
  String get privacyIntro;

  /// No description provided for @privacyVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get privacyVisibility;

  /// No description provided for @privacyShowProfile.
  ///
  /// In en, this message translates to:
  /// **'Show my profile'**
  String get privacyShowProfile;

  /// No description provided for @privacyShowProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off shows only your name and photo on posts; job, phone and location stay hidden.'**
  String get privacyShowProfileSubtitle;

  /// No description provided for @privacyAllowMessages.
  ///
  /// In en, this message translates to:
  /// **'Allow direct messages'**
  String get privacyAllowMessages;

  /// No description provided for @privacyAllowMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let members start a conversation with you. Existing chats stay open.'**
  String get privacyAllowMessagesSubtitle;

  /// No description provided for @privacyShowCity.
  ///
  /// In en, this message translates to:
  /// **'Show my city'**
  String get privacyShowCity;

  /// No description provided for @privacyShowCitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shares the address from your profile with other members.'**
  String get privacyShowCitySubtitle;

  /// No description provided for @privacyHidePhone.
  ///
  /// In en, this message translates to:
  /// **'Hide my phone number'**
  String get privacyHidePhone;

  /// No description provided for @privacyHidePhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When on, members can only reach you through in-app chat.'**
  String get privacyHidePhoneSubtitle;

  /// No description provided for @privacyBlockedMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'BLOCKED MEMBERS'**
  String get privacyBlockedMembersLabel;

  /// No description provided for @privacyBlockedMembers.
  ///
  /// In en, this message translates to:
  /// **'Blocked members'**
  String get privacyBlockedMembers;

  /// No description provided for @privacyBlockedMembersBody.
  ///
  /// In en, this message translates to:
  /// **'Blocked members can\'t see your posts or message you, and you won\'t see theirs.'**
  String get privacyBlockedMembersBody;

  /// No description provided for @privacyBlockedTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String privacyBlockedTotal(int count);

  /// No description provided for @privacyLoadingBlocked.
  ///
  /// In en, this message translates to:
  /// **'Loading blocked members...'**
  String get privacyLoadingBlocked;

  /// No description provided for @privacyNoBlocked.
  ///
  /// In en, this message translates to:
  /// **'No blocked members'**
  String get privacyNoBlocked;

  /// No description provided for @privacyNoBlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Members you block will appear here.'**
  String get privacyNoBlockedSubtitle;

  /// No description provided for @privacyBlockAnother.
  ///
  /// In en, this message translates to:
  /// **'Block another member'**
  String get privacyBlockAnother;

  /// No description provided for @privacyDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account, posts and conversations.'**
  String get privacyDeleteAccountSubtitle;

  /// No description provided for @blockUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String blockUserLabel(String name);

  /// No description provided for @blockUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockUserTitle(String name);

  /// No description provided for @blockUserDone.
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked.'**
  String blockUserDone(String name);

  /// No description provided for @blockUnblocked.
  ///
  /// In en, this message translates to:
  /// **'{name} can contact you again.'**
  String blockUnblocked(String name);

  /// No description provided for @blockChatConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This conversation will disappear and neither of you can message the other. Undo it any time in Privacy & safety.'**
  String get blockChatConfirmBody;

  /// No description provided for @blockProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Neither of you can see or message the other'**
  String get blockProfileSubtitle;

  /// No description provided for @blockProfileConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Undo it any time in Privacy & safety.'**
  String get blockProfileConfirmBody;

  /// No description provided for @blockStaffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Staff accounts cannot be blocked'**
  String get blockStaffSubtitle;

  /// No description provided for @blockMemberFallback.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get blockMemberFallback;

  /// No description provided for @profileFinderMember.
  ///
  /// In en, this message translates to:
  /// **'Finder member'**
  String get profileFinderMember;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @profileStatActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileStatActive;

  /// No description provided for @profileStatResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get profileStatResolved;

  /// No description provided for @profileStatSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileStatSaved;

  /// No description provided for @profileShareLine.
  ///
  /// In en, this message translates to:
  /// **'Find me on Finder · member id {id}'**
  String profileShareLine(String id);

  /// No description provided for @profileCopied.
  ///
  /// In en, this message translates to:
  /// **'Profile details copied to clipboard.'**
  String get profileCopied;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileCopyDetails.
  ///
  /// In en, this message translates to:
  /// **'Copy profile details'**
  String get profileCopyDetails;

  /// No description provided for @profileAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Finder'**
  String get profileAboutTitle;

  /// No description provided for @profileAboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0 · Beacon design'**
  String get profileAboutVersion;

  /// No description provided for @profileAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Finder helps a community reunite lost belongings with their owners. Report what you lost or found, chat safely inside the app and mark items as resolved when they are back home.'**
  String get profileAboutBody;

  /// No description provided for @profileSafetyFirst.
  ///
  /// In en, this message translates to:
  /// **'Safety first'**
  String get profileSafetyFirst;

  /// No description provided for @profileSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'Meet in public places, never pay a reward before you have your item, and use in-app chat so you can block and report.'**
  String get profileSafetyBody;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileMyPosts.
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get profileMyPosts;

  /// No description provided for @profileMyPostsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage what you have reported'**
  String get profileMyPostsSubtitle;

  /// No description provided for @profileSavedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get profileSavedItems;

  /// No description provided for @profileSavedItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items you are keeping an eye on'**
  String get profileSavedItemsSubtitle;

  /// No description provided for @profileAdminConsole.
  ///
  /// In en, this message translates to:
  /// **'Admin console'**
  String get profileAdminConsole;

  /// No description provided for @profileAdminConsoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Users, posts, reports and verification'**
  String get profileAdminConsoleSubtitle;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get profileDarkMode;

  /// No description provided for @profileNightTheme.
  ///
  /// In en, this message translates to:
  /// **'Nightwatch theme'**
  String get profileNightTheme;

  /// No description provided for @profileDayTheme.
  ///
  /// In en, this message translates to:
  /// **'Daylight theme'**
  String get profileDayTheme;

  /// No description provided for @profileSupportLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & legal'**
  String get profileSupportLegal;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get profileTerms;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileLogOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileLogOutTitle;

  /// No description provided for @profileLogOutBody.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in at any time.'**
  String get profileLogOutBody;

  /// No description provided for @profileDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get profileDiscardTitle;

  /// No description provided for @profileDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your edits have not been saved.'**
  String get profileDiscardBody;

  /// No description provided for @profileKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get profileKeepEditing;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your profile...'**
  String get profileLoading;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileFullNameHint;

  /// No description provided for @profileNickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileNickname;

  /// No description provided for @profileNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'How friends know you'**
  String get profileNicknameHint;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 234 567 8900'**
  String get profilePhoneHint;

  /// No description provided for @profileCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileCity;

  /// No description provided for @profileCityHint.
  ///
  /// In en, this message translates to:
  /// **'City, country'**
  String get profileCityHint;

  /// No description provided for @profileJob.
  ///
  /// In en, this message translates to:
  /// **'Job / occupation'**
  String get profileJob;

  /// No description provided for @profileJobHint.
  ///
  /// In en, this message translates to:
  /// **'What do you do?'**
  String get profileJobHint;

  /// No description provided for @profileSignInEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'SIGN-IN E-MAIL'**
  String get profileSignInEmailLabel;

  /// No description provided for @profileEmailNote.
  ///
  /// In en, this message translates to:
  /// **'Your e-mail is used to sign in and cannot be changed here.'**
  String get profileEmailNote;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSaveChanges;

  /// No description provided for @profileEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get profileEnterName;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @profileLoadingOther.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get profileLoadingOther;

  /// No description provided for @profileUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'This member is not available'**
  String get profileUnavailableTitle;

  /// No description provided for @profileUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The account may have been removed, or you cannot see each other.'**
  String get profileUnavailableSubtitle;

  /// No description provided for @profileMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get profileMore;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {time}'**
  String profileMemberSince(String time);

  /// No description provided for @profilePostsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 post} other{{count} posts}}'**
  String profilePostsCount(int count);

  /// No description provided for @profileMessageFirstName.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String profileMessageFirstName(String name);

  /// No description provided for @profileItemsReported.
  ///
  /// In en, this message translates to:
  /// **'Items {name} reported'**
  String profileItemsReported(String name);

  /// No description provided for @profileNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get profileNoPosts;

  /// No description provided for @profileSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get profileSendMessage;

  /// No description provided for @profileFinderAdmin.
  ///
  /// In en, this message translates to:
  /// **'Finder administrator'**
  String get profileFinderAdmin;

  /// No description provided for @profileAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get profileAdminBadge;

  /// No description provided for @profileFindMember.
  ///
  /// In en, this message translates to:
  /// **'Find a member'**
  String get profileFindMember;

  /// No description provided for @profileSearchMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email…'**
  String get profileSearchMemberHint;

  /// No description provided for @profileSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get profileSelect;

  /// No description provided for @profileSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed.'**
  String get profileSearchFailed;

  /// No description provided for @profileSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type at least two letters of a name or e-mail address.'**
  String get profileSearchSubtitle;

  /// No description provided for @profileSearchBlockedNote.
  ///
  /// In en, this message translates to:
  /// **'Members you have blocked will not appear here.'**
  String get profileSearchBlockedNote;

  /// No description provided for @profileSearchNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No members match \"{query}\".'**
  String profileSearchNoMatch(String query);

  /// No description provided for @profileUserRowSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {action}'**
  String profileUserRowSemantics(String name, String action);

  /// No description provided for @verifyVerifiedIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verified identity'**
  String get verifyVerifiedIdentity;

  /// No description provided for @verifyGetVerified.
  ///
  /// In en, this message translates to:
  /// **'Get verified'**
  String get verifyGetVerified;

  /// No description provided for @verifyBadgeVisible.
  ///
  /// In en, this message translates to:
  /// **'Your badge is visible to the community'**
  String get verifyBadgeVisible;

  /// No description provided for @verifyBuildTrust.
  ///
  /// In en, this message translates to:
  /// **'Build trust with a verified badge'**
  String get verifyBuildTrust;

  /// No description provided for @verifyPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get verifyPassport;

  /// No description provided for @verifyIdentityCard.
  ///
  /// In en, this message translates to:
  /// **'Identity card'**
  String get verifyIdentityCard;

  /// No description provided for @verifyDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license'**
  String get verifyDriversLicense;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get verifyTitle;

  /// No description provided for @verifyApprovedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your identity is verified'**
  String get verifyApprovedSubtitle;

  /// No description provided for @verifyUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get verifyUnderReview;

  /// No description provided for @verifyNeedsNewPhotos.
  ///
  /// In en, this message translates to:
  /// **'Needs new photos'**
  String get verifyNeedsNewPhotos;

  /// No description provided for @verifyStepsComplete.
  ///
  /// In en, this message translates to:
  /// **'{count} of 3 steps complete'**
  String verifyStepsComplete(int count);

  /// No description provided for @verifyCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking your status...'**
  String get verifyCheckingStatus;

  /// No description provided for @verifyVerifiedMember.
  ///
  /// In en, this message translates to:
  /// **'Verified member'**
  String get verifyVerifiedMember;

  /// No description provided for @verifyReviewedByPerson.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by a person'**
  String get verifyReviewedByPerson;

  /// No description provided for @verifyThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for helping keep Finder trustworthy.'**
  String get verifyThanks;

  /// No description provided for @verifyHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Verified accounts help build a safer community for everyone.'**
  String get verifyHeroHeadline;

  /// No description provided for @verifyApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'Your posts and messages now show the verified badge.'**
  String get verifyApprovedBody;

  /// No description provided for @verifyHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Your photos are stored privately and only seen by the Finder team member who checks them. Review usually takes a day.'**
  String get verifyHeroBody;

  /// No description provided for @verifyHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get verifyHowItWorks;

  /// No description provided for @verifyStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Photograph your ID'**
  String get verifyStep1Title;

  /// No description provided for @verifyStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Camera or gallery. Every corner in frame, no glare.'**
  String get verifyStep1Body;

  /// No description provided for @verifyStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Take a live selfie'**
  String get verifyStep2Title;

  /// No description provided for @verifyStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Front camera only, so we know it is really you.'**
  String get verifyStep2Body;

  /// No description provided for @verifyStep3Title.
  ///
  /// In en, this message translates to:
  /// **'A person reviews it'**
  String get verifyStep3Title;

  /// No description provided for @verifyStep3Body.
  ///
  /// In en, this message translates to:
  /// **'They compare the face on the ID with your selfie and the name on your account. You get a notification either way.'**
  String get verifyStep3Body;

  /// No description provided for @verifyIdentityVerified.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get verifyIdentityVerified;

  /// No description provided for @verifyPending.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verifyPending;

  /// No description provided for @verifyPendingBadge.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get verifyPendingBadge;

  /// No description provided for @verifyVerifiedWith.
  ///
  /// In en, this message translates to:
  /// **'Verified with your {doc}.'**
  String verifyVerifiedWith(String doc);

  /// No description provided for @verifyReceived.
  ///
  /// In en, this message translates to:
  /// **'We received your {doc} {time}. A Finder team member is reviewing it; you will get a notification when it is done.'**
  String verifyReceived(String doc, String time);

  /// No description provided for @verifyNotApproved.
  ///
  /// In en, this message translates to:
  /// **'Not approved yet'**
  String get verifyNotApproved;

  /// No description provided for @verifyNeedsPhotosBadge.
  ///
  /// In en, this message translates to:
  /// **'NEEDS PHOTOS'**
  String get verifyNeedsPhotosBadge;

  /// No description provided for @verifyPhotosRejected.
  ///
  /// In en, this message translates to:
  /// **'The photos could not be verified.'**
  String get verifyPhotosRejected;

  /// No description provided for @verifyReviewedAt.
  ///
  /// In en, this message translates to:
  /// **'Reviewed {time}'**
  String verifyReviewedAt(String time);

  /// No description provided for @verifySubmitNewPhotos.
  ///
  /// In en, this message translates to:
  /// **'Submit new photos'**
  String get verifySubmitNewPhotos;

  /// No description provided for @verifyDocTypeLower.
  ///
  /// In en, this message translates to:
  /// **'{type, select, id_card{identity card} drivers_license{driver\'s license} passport{passport} other{document}}'**
  String verifyDocTypeLower(String type);

  /// No description provided for @verifyDocSelection.
  ///
  /// In en, this message translates to:
  /// **'Document selection'**
  String get verifyDocSelection;

  /// No description provided for @verifyDocSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the ID you wish to use for verification'**
  String get verifyDocSelectionSubtitle;

  /// No description provided for @verifyDocPhotos.
  ///
  /// In en, this message translates to:
  /// **'Document photos'**
  String get verifyDocPhotos;

  /// No description provided for @verifyBothSides.
  ///
  /// In en, this message translates to:
  /// **'Both sides of your ID, camera or gallery'**
  String get verifyBothSides;

  /// No description provided for @verifyPhotoPage.
  ///
  /// In en, this message translates to:
  /// **'The photo page, camera or gallery'**
  String get verifyPhotoPage;

  /// No description provided for @verifyFrontOfId.
  ///
  /// In en, this message translates to:
  /// **'Front of ID'**
  String get verifyFrontOfId;

  /// No description provided for @verifyPhotoPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo page'**
  String get verifyPhotoPageLabel;

  /// No description provided for @verifyBackOfId.
  ///
  /// In en, this message translates to:
  /// **'Back of ID'**
  String get verifyBackOfId;

  /// No description provided for @verifyLiveSelfie.
  ///
  /// In en, this message translates to:
  /// **'Live selfie'**
  String get verifyLiveSelfie;

  /// No description provided for @verifyLiveSelfieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Taken now with the front camera; gallery photos are not accepted.'**
  String get verifyLiveSelfieSubtitle;

  /// No description provided for @verifyRetakeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Retake selfie'**
  String get verifyRetakeSelfie;

  /// No description provided for @verifyTakeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie'**
  String get verifyTakeSelfie;

  /// No description provided for @verifyTip.
  ///
  /// In en, this message translates to:
  /// **'Use a well-lit area, keep the whole document in frame and remove hats or sunglasses for the selfie.'**
  String get verifyTip;

  /// No description provided for @verifyFrontOfYourId.
  ///
  /// In en, this message translates to:
  /// **'Front of your ID'**
  String get verifyFrontOfYourId;

  /// No description provided for @verifyBackOfYourId.
  ///
  /// In en, this message translates to:
  /// **'Back of your ID'**
  String get verifyBackOfYourId;

  /// No description provided for @verifyStoredPrivately.
  ///
  /// In en, this message translates to:
  /// **'Stored privately, seen only by the reviewer.'**
  String get verifyStoredPrivately;

  /// No description provided for @verifyAddDocumentFirst.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Please add your document photo first.} other{Please add your document photos first.}}'**
  String verifyAddDocumentFirst(int count);

  /// No description provided for @verifyTakeSelfieFirst.
  ///
  /// In en, this message translates to:
  /// **'Please take a selfie to finish.'**
  String get verifyTakeSelfieFirst;

  /// No description provided for @verifySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted. You will be notified once it has been reviewed.'**
  String get verifySubmitted;

  /// No description provided for @verifyStepLabel.
  ///
  /// In en, this message translates to:
  /// **'STEP {index}'**
  String verifyStepLabel(int index);

  /// No description provided for @verifySubmitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get verifySubmitForReview;

  /// No description provided for @verifyConfirmOwnership.
  ///
  /// In en, this message translates to:
  /// **'By submitting you confirm the documents are yours.'**
  String get verifyConfirmOwnership;

  /// No description provided for @verifyAddToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add your document photos and a selfie to continue.'**
  String get verifyAddToContinue;

  /// No description provided for @verifyUploadAddedSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label} added, tap to replace'**
  String verifyUploadAddedSemantics(String label);

  /// No description provided for @verifyUploadAddSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add {label}'**
  String verifyUploadAddSemantics(String label);

  /// No description provided for @verifyUploadAdded.
  ///
  /// In en, this message translates to:
  /// **'{label} added'**
  String verifyUploadAdded(String label);

  /// No description provided for @verifyTapToReplace.
  ///
  /// In en, this message translates to:
  /// **'Tap to replace'**
  String get verifyTapToReplace;

  /// No description provided for @verifyCameraOrGallery.
  ///
  /// In en, this message translates to:
  /// **'Camera or gallery'**
  String get verifyCameraOrGallery;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpTitle;

  /// No description provided for @helpHeroPrefix.
  ///
  /// In en, this message translates to:
  /// **'How can we '**
  String get helpHeroPrefix;

  /// No description provided for @helpHeroAccent.
  ///
  /// In en, this message translates to:
  /// **'support'**
  String get helpHeroAccent;

  /// No description provided for @helpHeroSuffix.
  ///
  /// In en, this message translates to:
  /// **' you today?'**
  String get helpHeroSuffix;

  /// No description provided for @helpIntro.
  ///
  /// In en, this message translates to:
  /// **'Whether you\'ve lost a treasure or found a memory, the answers below cover most questions.'**
  String get helpIntro;

  /// No description provided for @helpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search questions (e.g. \'password\')'**
  String get helpSearchHint;

  /// No description provided for @helpNoAnswers.
  ///
  /// In en, this message translates to:
  /// **'No answers match \"{query}\". Try another word or contact us below.'**
  String helpNoAnswers(String query);

  /// No description provided for @helpAnswersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 answer} other{{count} answers}}'**
  String helpAnswersCount(int count);

  /// No description provided for @helpBrowseByTopic.
  ///
  /// In en, this message translates to:
  /// **'Browse by topic'**
  String get helpBrowseByTopic;

  /// No description provided for @helpStillQuestions.
  ///
  /// In en, this message translates to:
  /// **'Still have questions?'**
  String get helpStillQuestions;

  /// No description provided for @helpEmailReply.
  ///
  /// In en, this message translates to:
  /// **'E-mail us and we reply within one working day.'**
  String get helpEmailReply;

  /// No description provided for @helpEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'E-mail support'**
  String get helpEmailSupport;

  /// No description provided for @helpEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Finder support request'**
  String get helpEmailSubject;

  /// No description provided for @helpEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Hi Finder team,\n\n'**
  String get helpEmailBody;

  /// No description provided for @helpCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy support address'**
  String get helpCopyAddress;

  /// No description provided for @helpAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'{email} copied.'**
  String helpAddressCopied(String email);

  /// No description provided for @helpTechnicalFeedback.
  ///
  /// In en, this message translates to:
  /// **'TECHNICAL FEEDBACK'**
  String get helpTechnicalFeedback;

  /// No description provided for @helpFoundGlitch.
  ///
  /// In en, this message translates to:
  /// **'Found a glitch?'**
  String get helpFoundGlitch;

  /// No description provided for @helpGlitchBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you did, what you expected and what happened instead. Screenshots help a lot.'**
  String get helpGlitchBody;

  /// No description provided for @helpReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report a technical issue'**
  String get helpReportIssue;

  /// No description provided for @helpBugSubject.
  ///
  /// In en, this message translates to:
  /// **'Finder bug report'**
  String get helpBugSubject;

  /// No description provided for @helpBugBody.
  ///
  /// In en, this message translates to:
  /// **'What I did:\n\nWhat I expected:\n\nWhat happened:\n\nDevice / platform:\n'**
  String get helpBugBody;

  /// No description provided for @helpNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No e-mail app found. {email} was copied to your clipboard.'**
  String helpNoEmailApp(String email);

  /// No description provided for @helpGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get helpGotIt;

  /// No description provided for @helpTopicAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Profile, verification and passwords'**
  String get helpTopicAccountSubtitle;

  /// No description provided for @helpFaqChangeNameQ.
  ///
  /// In en, this message translates to:
  /// **'How do I change my name or photo?'**
  String get helpFaqChangeNameQ;

  /// No description provided for @helpFaqChangeNameA.
  ///
  /// In en, this message translates to:
  /// **'Open Profile, tap \"Edit profile\", change the fields and save. The new photo shows on all your posts and messages.'**
  String get helpFaqChangeNameA;

  /// No description provided for @helpFaqForgotPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password.'**
  String get helpFaqForgotPasswordQ;

  /// No description provided for @helpFaqForgotPasswordA.
  ///
  /// In en, this message translates to:
  /// **'On the sign-in screen tap \"Forgot password?\". A reset code is sent to your e-mail; enter it together with your new password.'**
  String get helpFaqForgotPasswordA;

  /// No description provided for @helpFaqVerifiedBadgeQ.
  ///
  /// In en, this message translates to:
  /// **'What does the verified badge mean?'**
  String get helpFaqVerifiedBadgeQ;

  /// No description provided for @helpFaqVerifiedBadgeA.
  ///
  /// In en, this message translates to:
  /// **'A verified member confirmed their identity with an ID document and a selfie. Start from Profile → Get verified. Review takes about a day.'**
  String get helpFaqVerifiedBadgeA;

  /// No description provided for @helpFaqDeleteAccountQ.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get helpFaqDeleteAccountQ;

  /// No description provided for @helpFaqDeleteAccountA.
  ///
  /// In en, this message translates to:
  /// **'Go to Privacy & safety → Request data deletion. We remove your posts, conversations and profile within 30 days.'**
  String get helpFaqDeleteAccountA;

  /// No description provided for @helpTopicSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get helpTopicSafety;

  /// No description provided for @helpTopicSafetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Meet-ups and blocking'**
  String get helpTopicSafetySubtitle;

  /// No description provided for @helpFaqMeetQ.
  ///
  /// In en, this message translates to:
  /// **'Where should I meet to hand over an item?'**
  String get helpFaqMeetQ;

  /// No description provided for @helpFaqMeetA.
  ///
  /// In en, this message translates to:
  /// **'Choose a busy public place in daylight, such as a café, a police station or a shopping centre. Bring a friend if you can.'**
  String get helpFaqMeetA;

  /// No description provided for @helpFaqBotheringQ.
  ///
  /// In en, this message translates to:
  /// **'Someone is bothering me.'**
  String get helpFaqBotheringQ;

  /// No description provided for @helpFaqBotheringA.
  ///
  /// In en, this message translates to:
  /// **'Open the conversation, tap the menu in the top-right corner and choose \"Block\". They can no longer see your posts or message you. Report the post too if it looks fake.'**
  String get helpFaqBotheringA;

  /// No description provided for @helpFaqRewardQ.
  ///
  /// In en, this message translates to:
  /// **'Should I pay a reward before I get my item back?'**
  String get helpFaqRewardQ;

  /// No description provided for @helpFaqRewardA.
  ///
  /// In en, this message translates to:
  /// **'No. Never send money before you have the item in your hands. Rewards are voluntary and paid at the hand-over.'**
  String get helpFaqRewardA;

  /// No description provided for @helpTopicPosting.
  ///
  /// In en, this message translates to:
  /// **'Posting items'**
  String get helpTopicPosting;

  /// No description provided for @helpTopicPostingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Writing reports that get matches'**
  String get helpTopicPostingSubtitle;

  /// No description provided for @helpFaqGoodPostQ.
  ///
  /// In en, this message translates to:
  /// **'What makes a good post?'**
  String get helpFaqGoodPostQ;

  /// No description provided for @helpFaqGoodPostA.
  ///
  /// In en, this message translates to:
  /// **'A clear photo, a precise location, the date and time, and distinctive details (scratches, stickers, engravings). Keep serial numbers private until someone proves they own the item.'**
  String get helpFaqGoodPostA;

  /// No description provided for @helpFaqMarkReturnedQ.
  ///
  /// In en, this message translates to:
  /// **'How do I mark an item as returned?'**
  String get helpFaqMarkReturnedQ;

  /// No description provided for @helpFaqMarkReturnedA.
  ///
  /// In en, this message translates to:
  /// **'Open the post or go to My posts and choose \"Mark as resolved\". Everyone who chatted with you about it gets a notification.'**
  String get helpFaqMarkReturnedA;

  /// No description provided for @helpFaqEditPostQ.
  ///
  /// In en, this message translates to:
  /// **'Can I edit or delete a post?'**
  String get helpFaqEditPostQ;

  /// No description provided for @helpFaqEditPostA.
  ///
  /// In en, this message translates to:
  /// **'Yes. From My posts tap Edit, or open the post and use the menu in the top-right corner to edit, resolve or delete it.'**
  String get helpFaqEditPostA;

  /// No description provided for @helpTopicMessaging.
  ///
  /// In en, this message translates to:
  /// **'Messaging'**
  String get helpTopicMessaging;

  /// No description provided for @helpTopicMessagingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contacting owners and finders'**
  String get helpTopicMessagingSubtitle;

  /// No description provided for @helpFaqContactOwnerQ.
  ///
  /// In en, this message translates to:
  /// **'How do I contact the owner of a post?'**
  String get helpFaqContactOwnerQ;

  /// No description provided for @helpFaqContactOwnerA.
  ///
  /// In en, this message translates to:
  /// **'Open the post and tap \"Chat with owner\" (or \"I found this item\"). A conversation about that item opens in Messages.'**
  String get helpFaqContactOwnerA;

  /// No description provided for @helpFaqSendPhotosQ.
  ///
  /// In en, this message translates to:
  /// **'Can I send photos?'**
  String get helpFaqSendPhotosQ;

  /// No description provided for @helpFaqSendPhotosA.
  ///
  /// In en, this message translates to:
  /// **'Yes. In a conversation tap the photo button next to the message field to send a picture as proof.'**
  String get helpFaqSendPhotosA;

  /// No description provided for @helpFaqCantMessageQ.
  ///
  /// In en, this message translates to:
  /// **'Why can\'t I message someone?'**
  String get helpFaqCantMessageQ;

  /// No description provided for @helpFaqCantMessageA.
  ///
  /// In en, this message translates to:
  /// **'Either one of you blocked the other, or they turned off direct messages in their privacy settings.'**
  String get helpFaqCantMessageA;

  /// No description provided for @helpComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon.'**
  String helpComingSoon(String feature);

  /// No description provided for @helpThisFeature.
  ///
  /// In en, this message translates to:
  /// **'This feature'**
  String get helpThisFeature;

  /// No description provided for @voicePlay.
  ///
  /// In en, this message translates to:
  /// **'Play voice message'**
  String get voicePlay;

  /// No description provided for @voicePause.
  ///
  /// In en, this message translates to:
  /// **'Pause voice message'**
  String get voicePause;

  /// No description provided for @voiceHoldHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the microphone to record a voice message.'**
  String get voiceHoldHint;

  /// No description provided for @voiceHoldTap.
  ///
  /// In en, this message translates to:
  /// **'Hold to record a voice message.'**
  String get voiceHoldTap;

  /// No description provided for @voiceSlideToCancel.
  ///
  /// In en, this message translates to:
  /// **'Slide to cancel'**
  String get voiceSlideToCancel;

  /// No description provided for @voiceCancelRecording.
  ///
  /// In en, this message translates to:
  /// **'Cancel recording'**
  String get voiceCancelRecording;

  /// No description provided for @photoAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get photoAddTitle;

  /// No description provided for @photoTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get photoTakePhoto;

  /// No description provided for @photoOpenCamera.
  ///
  /// In en, this message translates to:
  /// **'Open the camera'**
  String get photoOpenCamera;

  /// No description provided for @photoChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoChooseGallery;

  /// No description provided for @photoPickExisting.
  ///
  /// In en, this message translates to:
  /// **'Pick an existing picture'**
  String get photoPickExisting;

  /// No description provided for @photoOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'This picture could not be opened.'**
  String get photoOpenFailed;

  /// No description provided for @photoPrepareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the photo. Try again.'**
  String get photoPrepareFailed;

  /// No description provided for @photoAdjustAvatar.
  ///
  /// In en, this message translates to:
  /// **'Adjust your photo'**
  String get photoAdjustAvatar;

  /// No description provided for @photoAdjustCover.
  ///
  /// In en, this message translates to:
  /// **'Adjust your cover'**
  String get photoAdjustCover;

  /// No description provided for @photoUse.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get photoUse;

  /// No description provided for @photoGestureHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom · drag to move · double-tap to zoom'**
  String get photoGestureHint;

  /// No description provided for @photoRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get photoRotate;

  /// No description provided for @photoReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get photoReset;

  /// No description provided for @photoRemoveCover.
  ///
  /// In en, this message translates to:
  /// **'Remove cover photo'**
  String get photoRemoveCover;

  /// No description provided for @photoAddCover.
  ///
  /// In en, this message translates to:
  /// **'Add a cover photo'**
  String get photoAddCover;

  /// No description provided for @photoChangeCover.
  ///
  /// In en, this message translates to:
  /// **'Change cover photo'**
  String get photoChangeCover;

  /// No description provided for @photoChangeProfile.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get photoChangeProfile;

  /// No description provided for @photoAddProfile.
  ///
  /// In en, this message translates to:
  /// **'Add profile photo'**
  String get photoAddProfile;

  /// No description provided for @photoProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get photoProfileTitle;

  /// No description provided for @photoCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover photo'**
  String get photoCoverTitle;

  /// No description provided for @photoUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo upload failed. {detail}'**
  String photoUploadFailed(String detail);

  /// No description provided for @photoFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'The selected file is empty.'**
  String get photoFileEmpty;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Please choose an image under 8 MB.'**
  String get photoTooLarge;

  /// No description provided for @photoNoFileId.
  ///
  /// In en, this message translates to:
  /// **'The server returned no file id.'**
  String get photoNoFileId;

  /// No description provided for @photoNoUrl.
  ///
  /// In en, this message translates to:
  /// **'The server returned no image URL.'**
  String get photoNoUrl;

  /// No description provided for @photoCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. Allow it in your phone settings or choose a photo from the gallery.'**
  String get photoCameraDenied;

  /// No description provided for @photoAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo access was denied. Allow it in your phone settings and try again.'**
  String get photoAccessDenied;

  /// No description provided for @photoCameraOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the camera.'**
  String get photoCameraOpenFailed;

  /// No description provided for @photoPickerOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the photo picker.'**
  String get photoPickerOpenFailed;

  /// No description provided for @pushMessagesChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'New chat messages'**
  String get pushMessagesChannelDesc;

  /// No description provided for @pushUpdatesChannel.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get pushUpdatesChannel;

  /// No description provided for @pushUpdatesChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Post and account updates'**
  String get pushUpdatesChannelDesc;

  /// No description provided for @chatTyping.
  ///
  /// In en, this message translates to:
  /// **'typing…'**
  String get chatTyping;

  /// No description provided for @chatOnline.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get chatOnline;

  /// No description provided for @chatLastSeen.
  ///
  /// In en, this message translates to:
  /// **'last seen {when}'**
  String chatLastSeen(String when);

  /// No description provided for @chatYouPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get chatYouPrefix;

  /// No description provided for @chatAddCaption.
  ///
  /// In en, this message translates to:
  /// **'Add a caption…'**
  String get chatAddCaption;

  /// No description provided for @chatLoadingOlder.
  ///
  /// In en, this message translates to:
  /// **'Loading older messages…'**
  String get chatLoadingOlder;

  /// No description provided for @voiceTapToLock.
  ///
  /// In en, this message translates to:
  /// **'Tap to record hands-free, hold to record'**
  String get voiceTapToLock;

  /// No description provided for @voiceSlideUpToLock.
  ///
  /// In en, this message translates to:
  /// **'Slide up to lock'**
  String get voiceSlideUpToLock;

  /// No description provided for @voiceSend.
  ///
  /// In en, this message translates to:
  /// **'Send voice message'**
  String get voiceSend;

  /// No description provided for @voiceDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard recording'**
  String get voiceDiscard;

  /// No description provided for @voiceSpeed.
  ///
  /// In en, this message translates to:
  /// **'{speed}×'**
  String voiceSpeed(String speed);

  /// No description provided for @chatForwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get chatForwarded;

  /// No description provided for @chatDeleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get chatDeleteForMe;

  /// No description provided for @chatForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get chatForward;

  /// No description provided for @chatForwardTo.
  ///
  /// In en, this message translates to:
  /// **'Forward to'**
  String get chatForwardTo;

  /// No description provided for @chatForwardSent.
  ///
  /// In en, this message translates to:
  /// **'Forwarded.'**
  String get chatForwardSent;

  /// No description provided for @chatUnreadMessages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread message} other{{count} unread messages}}'**
  String chatUnreadMessages(int count);

  /// No description provided for @chatOpenPhoto.
  ///
  /// In en, this message translates to:
  /// **'Open photo'**
  String get chatOpenPhoto;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Finder'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lost-and-found for your city: reviewed by people, matched for you, in your language.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Post it'**
  String get welcomeStep1Title;

  /// No description provided for @welcomeStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Lost or found, add a photo and the place. A moderator checks it before it goes live.'**
  String get welcomeStep1Body;

  /// No description provided for @welcomeStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Get matched'**
  String get welcomeStep2Title;

  /// No description provided for @welcomeStep2Body.
  ///
  /// In en, this message translates to:
  /// **'We alert you when a post matches yours and show every post in your app language.'**
  String get welcomeStep2Body;

  /// No description provided for @welcomeStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Return it safely'**
  String get welcomeStep3Title;

  /// No description provided for @welcomeStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Chat here, ask for a detail only the owner knows, and meet in a public place.'**
  String get welcomeStep3Body;

  /// No description provided for @welcomeHelpHint.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guides, including how to make sure you are talking to the real owner, are in Profile → Help & Support.'**
  String get welcomeHelpHint;

  /// No description provided for @welcomeGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get welcomeGotIt;

  /// No description provided for @welcomeOpenHelp.
  ///
  /// In en, this message translates to:
  /// **'See the guides'**
  String get welcomeOpenHelp;

  /// No description provided for @helpTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guides, safety tips and contact'**
  String get helpTileSubtitle;

  /// No description provided for @helpGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How Finder works'**
  String get helpGuideTitle;

  /// No description provided for @helpGuideStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get helpGuideStartTitle;

  /// No description provided for @helpGuideStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, profile, notifications, badges'**
  String get helpGuideStartSubtitle;

  /// No description provided for @helpGuideStart1.
  ///
  /// In en, this message translates to:
  /// **'Pick your language from the globe icon on the sign-in screen or in Profile. Every post is shown in that language.'**
  String get helpGuideStart1;

  /// No description provided for @helpGuideStart2.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile with a real name and a photo: people are more likely to return an item to someone they can recognise.'**
  String get helpGuideStart2;

  /// No description provided for @helpGuideStart3.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so you hear about matches and messages right away.'**
  String get helpGuideStart3;

  /// No description provided for @helpGuideStart4.
  ///
  /// In en, this message translates to:
  /// **'Badges: Pending means a moderator is still checking the post, Live means everyone can see it, Returned means the item is back with its owner.'**
  String get helpGuideStart4;

  /// No description provided for @helpGuideLostTitle.
  ///
  /// In en, this message translates to:
  /// **'Posting a lost item'**
  String get helpGuideLostTitle;

  /// No description provided for @helpGuideLostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What to include, what to keep back'**
  String get helpGuideLostSubtitle;

  /// No description provided for @helpGuideLost1.
  ///
  /// In en, this message translates to:
  /// **'Add a clear photo of the item, or of the same model, so people recognise it at a glance.'**
  String get helpGuideLost1;

  /// No description provided for @helpGuideLost2.
  ///
  /// In en, this message translates to:
  /// **'Give the exact place and the time you last had it. Nearby people see your post first.'**
  String get helpGuideLost2;

  /// No description provided for @helpGuideLost3.
  ///
  /// In en, this message translates to:
  /// **'Describe it, but keep one or two details to yourself (a scratch, the contents, an engraving). You will use them to check that a finder really has it.'**
  String get helpGuideLost3;

  /// No description provided for @helpGuideLost4.
  ///
  /// In en, this message translates to:
  /// **'A reward is optional. Never pay anything before the item is in your hands.'**
  String get helpGuideLost4;

  /// No description provided for @helpGuideLost5.
  ///
  /// In en, this message translates to:
  /// **'Your post shows Pending until a moderator approves it, usually within a few hours. You get a notification when it is live and whenever a found post matches.'**
  String get helpGuideLost5;

  /// No description provided for @helpGuideFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Posting a found item'**
  String get helpGuideFoundTitle;

  /// No description provided for @helpGuideFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect the owner while you look for them'**
  String get helpGuideFoundSubtitle;

  /// No description provided for @helpGuideFound1.
  ///
  /// In en, this message translates to:
  /// **'Photograph the item, but hide anything personal: names, ID numbers, bank cards, addresses, phone screens.'**
  String get helpGuideFound1;

  /// No description provided for @helpGuideFound2.
  ///
  /// In en, this message translates to:
  /// **'Do not post serial numbers, IMEI or the contents of a wallet or bag. Keep them to check claims.'**
  String get helpGuideFound2;

  /// No description provided for @helpGuideFound3.
  ///
  /// In en, this message translates to:
  /// **'Say where and when you found it and roughly where it is now. You do not have to share your home address.'**
  String get helpGuideFound3;

  /// No description provided for @helpGuideFound4.
  ///
  /// In en, this message translates to:
  /// **'Documents, passports, phones, bank cards and money: hand them to the police or the venue\'s lost-property desk as well, and say so in the post.'**
  String get helpGuideFound4;

  /// No description provided for @helpGuideFound5.
  ///
  /// In en, this message translates to:
  /// **'Once approved, the app matches your post with people searching for it and alerts them, in their own language.'**
  String get helpGuideFound5;

  /// No description provided for @helpGuideMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'When you get a match or a message'**
  String get helpGuideMatchTitle;

  /// No description provided for @helpGuideMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What to do next'**
  String get helpGuideMatchSubtitle;

  /// No description provided for @helpGuideMatch1.
  ///
  /// In en, this message translates to:
  /// **'Open the matching post and compare the photo, place and time with yours.'**
  String get helpGuideMatch1;

  /// No description provided for @helpGuideMatch2.
  ///
  /// In en, this message translates to:
  /// **'Reply inside the app chat. Keep your phone number and address private until you have met.'**
  String get helpGuideMatch2;

  /// No description provided for @helpGuideMatch3.
  ///
  /// In en, this message translates to:
  /// **'If you found the item, ask the claimant for a detail that is not in the post before you agree to meet.'**
  String get helpGuideMatch3;

  /// No description provided for @helpGuideMatch4.
  ///
  /// In en, this message translates to:
  /// **'Not the right item? Just say so politely. Someone who pressures you, asks for money or pushes to move to another app is a red flag: block and report them.'**
  String get helpGuideMatch4;

  /// No description provided for @helpGuideVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Making sure it is the real owner'**
  String get helpGuideVerifyTitle;

  /// No description provided for @helpGuideVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple checks that stop false claims'**
  String get helpGuideVerifySubtitle;

  /// No description provided for @helpGuideVerify1.
  ///
  /// In en, this message translates to:
  /// **'Ask for something only the owner would know: what is inside, a scratch or sticker, the lock-screen photo, an engraving, the exact colour of a strap.'**
  String get helpGuideVerify1;

  /// No description provided for @helpGuideVerify2.
  ///
  /// In en, this message translates to:
  /// **'Ask for a photo of the item from before it was lost, or a receipt, the box, or a serial number you can compare.'**
  String get helpGuideVerify2;

  /// No description provided for @helpGuideVerify3.
  ///
  /// In en, this message translates to:
  /// **'For phones: the owner can call the number or unlock it in front of you. For keys: they can name the car or open the door.'**
  String get helpGuideVerify3;

  /// No description provided for @helpGuideVerify4.
  ///
  /// In en, this message translates to:
  /// **'For documents and bank cards, hand them over only to the person named on them, with a matching ID, or to the issuing office or police.'**
  String get helpGuideVerify4;

  /// No description provided for @helpGuideVerify5.
  ///
  /// In en, this message translates to:
  /// **'Never send a deposit, transfer money or share bank details to \"release\" an item. Finder never asks for payments.'**
  String get helpGuideVerify5;

  /// No description provided for @helpGuideVerify6.
  ///
  /// In en, this message translates to:
  /// **'Still unsure? Ask to meet at a police station, or report the conversation and let a moderator look at it.'**
  String get helpGuideVerify6;

  /// No description provided for @helpGuideMeetTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting safely'**
  String get helpGuideMeetTitle;

  /// No description provided for @helpGuideMeetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The hand-over'**
  String get helpGuideMeetSubtitle;

  /// No description provided for @helpGuideMeet1.
  ///
  /// In en, this message translates to:
  /// **'Meet in a busy public place in daylight: a mall, a café, a police station or a lost-property desk.'**
  String get helpGuideMeet1;

  /// No description provided for @helpGuideMeet2.
  ///
  /// In en, this message translates to:
  /// **'Bring a friend or tell someone where you are going and when you expect to be back.'**
  String get helpGuideMeet2;

  /// No description provided for @helpGuideMeet3.
  ///
  /// In en, this message translates to:
  /// **'Do not get into a car or go to a private home for a hand-over.'**
  String get helpGuideMeet3;

  /// No description provided for @helpGuideMeet4.
  ///
  /// In en, this message translates to:
  /// **'Give a reward only after you have the item, and only if you offered one. Nobody can demand it.'**
  String get helpGuideMeet4;

  /// No description provided for @helpGuideMeet5.
  ///
  /// In en, this message translates to:
  /// **'Afterwards, mark the post as Returned so the alert stops and others can celebrate with you.'**
  String get helpGuideMeet5;

  /// No description provided for @helpGuideReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting a problem'**
  String get helpGuideReportTitle;

  /// No description provided for @helpGuideReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Posts, people, bugs'**
  String get helpGuideReportSubtitle;

  /// No description provided for @helpGuideReport1.
  ///
  /// In en, this message translates to:
  /// **'Report a post from its menu and pick a reason. A moderator reviews it and can remove it or warn the author.'**
  String get helpGuideReport1;

  /// No description provided for @helpGuideReport2.
  ///
  /// In en, this message translates to:
  /// **'Block a user from their profile or the chat to stop their messages. They are not told.'**
  String get helpGuideReport2;

  /// No description provided for @helpGuideReport3.
  ///
  /// In en, this message translates to:
  /// **'Every new post is checked by a moderator, with an AI pre-check for scams, ads and inappropriate images. Approved posts can still be reported.'**
  String get helpGuideReport3;

  /// No description provided for @helpGuideReport4.
  ///
  /// In en, this message translates to:
  /// **'Something broken? Use \"Report an issue\" below. Urgent safety matters: contact the police first.'**
  String get helpGuideReport4;

  /// No description provided for @navPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get navPost;

  /// No description provided for @navTab.
  ///
  /// In en, this message translates to:
  /// **'{label} tab'**
  String navTab(String label);

  /// No description provided for @categoryAllItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get categoryAllItems;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get categoryNearby;

  /// No description provided for @categoryRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get categoryRecent;

  /// No description provided for @categoryWithReward.
  ///
  /// In en, this message translates to:
  /// **'With Reward'**
  String get categoryWithReward;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryWatchesJewelry.
  ///
  /// In en, this message translates to:
  /// **'Watches & Jewelry'**
  String get categoryWatchesJewelry;

  /// No description provided for @categoryWalletsBags.
  ///
  /// In en, this message translates to:
  /// **'Wallets & Bags'**
  String get categoryWalletsBags;

  /// No description provided for @categoryKeys.
  ///
  /// In en, this message translates to:
  /// **'Keys'**
  String get categoryKeys;

  /// No description provided for @categoryPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get categoryPets;

  /// No description provided for @categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// No description provided for @categoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocuments;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @categoryWallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get categoryWallets;

  /// No description provided for @categoryBags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get categoryBags;

  /// No description provided for @categoryWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get categoryWallet;

  /// No description provided for @categoryJewelry.
  ///
  /// In en, this message translates to:
  /// **'Jewelry'**
  String get categoryJewelry;

  /// No description provided for @categoryOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get categoryOthers;

  /// No description provided for @categoryVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get categoryVisibilityPublic;

  /// No description provided for @categoryVisibilityFriendsOnly.
  ///
  /// In en, this message translates to:
  /// **'Friends Only'**
  String get categoryVisibilityFriendsOnly;

  /// No description provided for @categoryVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get categoryVisibilityPrivate;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterTitle;

  /// No description provided for @filterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Narrow down what you are looking for'**
  String get filterSubtitle;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filterApply;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city or area'**
  String get filterLocationHint;

  /// No description provided for @filterDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get filterDateRange;

  /// No description provided for @filterFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterFrom;

  /// No description provided for @filterTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterTo;

  /// No description provided for @filterSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get filterSelectDate;

  /// No description provided for @filterRewardOffered.
  ///
  /// In en, this message translates to:
  /// **'Reward offered'**
  String get filterRewardOffered;

  /// No description provided for @filterRewardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only posts that offer a reward'**
  String get filterRewardSubtitle;

  /// No description provided for @filterVerifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified users only'**
  String get filterVerifiedOnly;

  /// No description provided for @filterVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Posted by identity-verified members'**
  String get filterVerifiedSubtitle;

  /// No description provided for @filterSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSortBy;

  /// No description provided for @filterMostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most Recent'**
  String get filterMostRecent;

  /// No description provided for @filterNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest to Me'**
  String get filterNearest;

  /// No description provided for @filterAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get filterAnyTime;

  /// No description provided for @filterLast24h.
  ///
  /// In en, this message translates to:
  /// **'Last 24h'**
  String get filterLast24h;

  /// No description provided for @filterLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get filterLastWeek;

  /// No description provided for @filterLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get filterLastMonth;

  /// No description provided for @filterDate.
  ///
  /// In en, this message translates to:
  /// **'{day} {month}, {year}'**
  String filterDate(int day, String month, int year);

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find lost and found items near you'**
  String get searchSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items, places…'**
  String get searchHint;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get searchClearFilters;

  /// No description provided for @searchResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get searchResetFilters;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching items found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or adjust your filters.'**
  String get searchNoResultsSubtitle;

  /// No description provided for @homeReportLost.
  ///
  /// In en, this message translates to:
  /// **'Report lost'**
  String get homeReportLost;

  /// No description provided for @homeReportLostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask the community'**
  String get homeReportLostSubtitle;

  /// No description provided for @homeReportFound.
  ///
  /// In en, this message translates to:
  /// **'Report found'**
  String get homeReportFound;

  /// No description provided for @homeReportFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return it home'**
  String get homeReportFoundSubtitle;

  /// No description provided for @homeLoadingPosts.
  ///
  /// In en, this message translates to:
  /// **'Loading posts...'**
  String get homeLoadingPosts;

  /// No description provided for @homeNoLostItems.
  ///
  /// In en, this message translates to:
  /// **'No lost items'**
  String get homeNoLostItems;

  /// No description provided for @homeNoFoundItems.
  ///
  /// In en, this message translates to:
  /// **'No found items'**
  String get homeNoFoundItems;

  /// No description provided for @homeNoPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get homeNoPostsYet;

  /// No description provided for @homeCreateFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Create the first post to get started.'**
  String get homeCreateFirstPost;

  /// No description provided for @homeTrySwitchingAll.
  ///
  /// In en, this message translates to:
  /// **'Try switching to All Items.'**
  String get homeTrySwitchingAll;

  /// No description provided for @homeOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get homeOpenProfile;

  /// No description provided for @homeContactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact Owner'**
  String get homeContactOwner;

  /// No description provided for @homeContactFinder.
  ///
  /// In en, this message translates to:
  /// **'Contact Finder'**
  String get homeContactFinder;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @homeGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get homeGuest;

  /// No description provided for @homeNotificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'Notifications, {count} unread'**
  String homeNotificationsUnread(int count);

  /// No description provided for @mapPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick a location'**
  String get mapPickLocation;

  /// No description provided for @mapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a place or address'**
  String get mapSearchHint;

  /// No description provided for @mapSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get mapSearching;

  /// No description provided for @mapMoveToPlacePin.
  ///
  /// In en, this message translates to:
  /// **'Move the map to place the pin'**
  String get mapMoveToPlacePin;

  /// No description provided for @mapUseMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get mapUseMyLocation;

  /// No description provided for @mapFindingAddress.
  ///
  /// In en, this message translates to:
  /// **'Finding the address…'**
  String get mapFindingAddress;

  /// No description provided for @mapUseThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get mapUseThisLocation;

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'Map data © OpenStreetMap contributors'**
  String get mapAttribution;

  /// No description provided for @mapErrGpsOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services (GPS) to use your current location.'**
  String get mapErrGpsOff;

  /// No description provided for @mapErrBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked. Allow it in your phone settings to use your current location.'**
  String get mapErrBlocked;

  /// No description provided for @mapErrDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was not granted.'**
  String get mapErrDenied;

  /// No description provided for @mapErrNoFix.
  ///
  /// In en, this message translates to:
  /// **'Could not get a GPS fix. Move somewhere with a clearer view of the sky and try again.'**
  String get mapErrNoFix;

  /// No description provided for @shareKindTitle.
  ///
  /// In en, this message translates to:
  /// **'{kind}: {title}'**
  String shareKindTitle(String kind, String title);

  /// No description provided for @shareFindMe.
  ///
  /// In en, this message translates to:
  /// **'Find me on Finder · member id {id}'**
  String shareFindMe(String id);

  /// No description provided for @shareProfileSubject.
  ///
  /// In en, this message translates to:
  /// **'{name} on Finder'**
  String shareProfileSubject(String name);

  /// No description provided for @postItemDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get postItemDetailsTitle;

  /// No description provided for @postItemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item details'**
  String get postItemDetails;

  /// No description provided for @postNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided yet.'**
  String get postNoDescription;

  /// No description provided for @postReward.
  ///
  /// In en, this message translates to:
  /// **'REWARD'**
  String get postReward;

  /// No description provided for @postRewardAmount.
  ///
  /// In en, this message translates to:
  /// **'REWARD {amount}'**
  String postRewardAmount(String amount);

  /// No description provided for @postIFoundThis.
  ///
  /// In en, this message translates to:
  /// **'I found this item'**
  String get postIFoundThis;

  /// No description provided for @postThisIsMine.
  ///
  /// In en, this message translates to:
  /// **'This is mine'**
  String get postThisIsMine;

  /// No description provided for @postReturnedOwnerNote.
  ///
  /// In en, this message translates to:
  /// **'Marked as returned. It no longer shows on Home, but stays in Search so people can see the outcome.'**
  String get postReturnedOwnerNote;

  /// No description provided for @postRemoveFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get postRemoveFromSaved;

  /// No description provided for @postSaveItem.
  ///
  /// In en, this message translates to:
  /// **'Save item'**
  String get postSaveItem;

  /// No description provided for @postMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get postMoreActions;

  /// No description provided for @postLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get postLinkCopied;

  /// No description provided for @postDetailsCopied.
  ///
  /// In en, this message translates to:
  /// **'Item details copied to clipboard.'**
  String get postDetailsCopied;

  /// No description provided for @postSavedToList.
  ///
  /// In en, this message translates to:
  /// **'Saved to your list.'**
  String get postSavedToList;

  /// No description provided for @postRemovedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved items.'**
  String get postRemovedFromSaved;

  /// No description provided for @postManageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage post'**
  String get postManageSheetTitle;

  /// No description provided for @postMoreSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get postMoreSheetTitle;

  /// No description provided for @postShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send the photo and a link to anyone'**
  String get postShareSubtitle;

  /// No description provided for @postCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get postCopyLink;

  /// No description provided for @postEditPost.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get postEditPost;

  /// No description provided for @postReopenPost.
  ///
  /// In en, this message translates to:
  /// **'Reopen post'**
  String get postReopenPost;

  /// No description provided for @postDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get postDeletePost;

  /// No description provided for @postReportPost.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get postReportPost;

  /// No description provided for @postBlockThisMember.
  ///
  /// In en, this message translates to:
  /// **'Block this member'**
  String get postBlockThisMember;

  /// No description provided for @postBlockMember.
  ///
  /// In en, this message translates to:
  /// **'Block member'**
  String get postBlockMember;

  /// No description provided for @postActiveAgain.
  ///
  /// In en, this message translates to:
  /// **'Post is active again.'**
  String get postActiveAgain;

  /// No description provided for @postDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete post?'**
  String get postDeleteTitle;

  /// No description provided for @postDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed for everyone. This cannot be undone.'**
  String postDeleteBody(String title);

  /// No description provided for @postDeleteBodyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This cannot be undone.'**
  String postDeleteBodyConfirm(String title);

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted.'**
  String get postDeleted;

  /// No description provided for @postReportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or scam'**
  String get postReportReasonSpam;

  /// No description provided for @postReportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get postReportReasonInappropriate;

  /// No description provided for @postReportReasonMisleading.
  ///
  /// In en, this message translates to:
  /// **'Wrong or misleading information'**
  String get postReportReasonMisleading;

  /// No description provided for @postReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get postReportReasonOther;

  /// No description provided for @postReportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this post'**
  String get postReportSheetTitle;

  /// No description provided for @postReportSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what is wrong. Reports are reviewed by the team.'**
  String get postReportSheetSubtitle;

  /// No description provided for @postReported.
  ///
  /// In en, this message translates to:
  /// **'Thanks, the post has been reported.'**
  String get postReported;

  /// No description provided for @postThisMember.
  ///
  /// In en, this message translates to:
  /// **'this member'**
  String get postThisMember;

  /// No description provided for @postBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String postBlockTitle(String name);

  /// No description provided for @postBlockBody.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see each other\'s posts or messages. You can undo this in Privacy & safety.'**
  String get postBlockBody;

  /// No description provided for @postBlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked.'**
  String postBlocked(String name);

  /// No description provided for @postCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get postCategory;

  /// No description provided for @postLostOn.
  ///
  /// In en, this message translates to:
  /// **'Lost on'**
  String get postLostOn;

  /// No description provided for @postFoundOn.
  ///
  /// In en, this message translates to:
  /// **'Found on'**
  String get postFoundOn;

  /// No description provided for @postOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get postOpenInMaps;

  /// No description provided for @postCouldNotOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Could not open a maps app.'**
  String get postCouldNotOpenMaps;

  /// No description provided for @postNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get postNotProvided;

  /// No description provided for @postPostedByOwner.
  ///
  /// In en, this message translates to:
  /// **'POSTED BY THE OWNER'**
  String get postPostedByOwner;

  /// No description provided for @postPostedByFinder.
  ///
  /// In en, this message translates to:
  /// **'POSTED BY THE FINDER'**
  String get postPostedByFinder;

  /// No description provided for @postLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get postLoadingProfile;

  /// No description provided for @postProfileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Profile not available'**
  String get postProfileNotAvailable;

  /// No description provided for @postVerifiedMember.
  ///
  /// In en, this message translates to:
  /// **'Verified member'**
  String get postVerifiedMember;

  /// No description provided for @postMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String postMemberSince(String date);

  /// No description provided for @postPostsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 post} other{{count} posts}}'**
  String postPostsCount(int count);

  /// No description provided for @postMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String postMonthYear(String month, int year);

  /// No description provided for @postPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get postPhone;

  /// No description provided for @postCouldNotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not open the phone dialer.'**
  String get postCouldNotOpenDialer;

  /// No description provided for @postChatWithOwner.
  ///
  /// In en, this message translates to:
  /// **'Chat with owner'**
  String get postChatWithOwner;

  /// No description provided for @postChatWithFinder.
  ///
  /// In en, this message translates to:
  /// **'Chat with finder'**
  String get postChatWithFinder;

  /// No description provided for @postCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get postCall;

  /// No description provided for @postPhoneNotShared.
  ///
  /// In en, this message translates to:
  /// **'Phone number not shared. In-app chat is the safest way to coordinate.'**
  String get postPhoneNotShared;

  /// No description provided for @postOwnerActions.
  ///
  /// In en, this message translates to:
  /// **'OWNER ACTIONS'**
  String get postOwnerActions;

  /// No description provided for @postSafety.
  ///
  /// In en, this message translates to:
  /// **'SAFETY'**
  String get postSafety;

  /// No description provided for @postPossibleMatches.
  ///
  /// In en, this message translates to:
  /// **'Possible matches'**
  String get postPossibleMatches;

  /// No description provided for @postMatchesEyebrowLost.
  ///
  /// In en, this message translates to:
  /// **'Found items that look like yours'**
  String get postMatchesEyebrowLost;

  /// No description provided for @postMatchesEyebrowFound.
  ///
  /// In en, this message translates to:
  /// **'Lost items that look like this one'**
  String get postMatchesEyebrowFound;

  /// No description provided for @postNoMatchesLost.
  ///
  /// In en, this message translates to:
  /// **'No matches yet. We keep comparing new found posts with this one and notify you the moment something looks alike.'**
  String get postNoMatchesLost;

  /// No description provided for @postNoMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches yet. We keep comparing new lost posts with this one and notify you the moment something looks alike.'**
  String get postNoMatchesFound;

  /// No description provided for @postSimilarItems.
  ///
  /// In en, this message translates to:
  /// **'Similar items'**
  String get postSimilarItems;

  /// No description provided for @postSimilarEyebrowLost.
  ///
  /// In en, this message translates to:
  /// **'Found items in this category'**
  String get postSimilarEyebrowLost;

  /// No description provided for @postSimilarEyebrowFound.
  ///
  /// In en, this message translates to:
  /// **'Lost items in this category'**
  String get postSimilarEyebrowFound;

  /// No description provided for @postViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get postViewAll;

  /// No description provided for @postLoadingSimilar.
  ///
  /// In en, this message translates to:
  /// **'Loading similar items...'**
  String get postLoadingSimilar;

  /// No description provided for @postNoSimilarTitle.
  ///
  /// In en, this message translates to:
  /// **'No similar items yet'**
  String get postNoSimilarTitle;

  /// No description provided for @postNoSimilarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check back later for matches nearby.'**
  String get postNoSimilarSubtitle;

  /// No description provided for @postMatchBannerTitleLost.
  ///
  /// In en, this message translates to:
  /// **'Could this be the item you found?'**
  String get postMatchBannerTitleLost;

  /// No description provided for @postMatchBannerTitleFound.
  ///
  /// In en, this message translates to:
  /// **'Could this be your item?'**
  String get postMatchBannerTitleFound;

  /// No description provided for @postMatchBannerBodyLost.
  ///
  /// In en, this message translates to:
  /// **'Someone reported losing something that looks like the item you found. Compare the details and message them.'**
  String get postMatchBannerBodyLost;

  /// No description provided for @postMatchBannerBodyFound.
  ///
  /// In en, this message translates to:
  /// **'Someone reported finding something that looks like what you lost. Compare the details and message them.'**
  String get postMatchBannerBodyFound;

  /// No description provided for @postMessageOwner.
  ///
  /// In en, this message translates to:
  /// **'Message the owner'**
  String get postMessageOwner;

  /// No description provided for @postMessageFinder.
  ///
  /// In en, this message translates to:
  /// **'Message the finder'**
  String get postMessageFinder;

  /// No description provided for @postItemSemantics.
  ///
  /// In en, this message translates to:
  /// **'{status} item, {title}'**
  String postItemSemantics(String status, String title);

  /// No description provided for @postLocationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get postLocationNotSet;

  /// No description provided for @postNewPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get postNewPost;

  /// No description provided for @postHeaderLost.
  ///
  /// In en, this message translates to:
  /// **'Tell the community what you lost.'**
  String get postHeaderLost;

  /// No description provided for @postHeaderFound.
  ///
  /// In en, this message translates to:
  /// **'Help return what you found.'**
  String get postHeaderFound;

  /// No description provided for @postReadyToPost.
  ///
  /// In en, this message translates to:
  /// **'Ready to post'**
  String get postReadyToPost;

  /// No description provided for @postDetailsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} of 5 details added'**
  String postDetailsAdded(int count);

  /// No description provided for @postPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get postPhotos;

  /// No description provided for @postPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get postPhoto;

  /// No description provided for @postStep.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String postStep(int number);

  /// No description provided for @postPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Clear photos help others identify the item.'**
  String get postPhotosHint;

  /// No description provided for @postCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get postCamera;

  /// No description provided for @postGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get postGallery;

  /// No description provided for @postRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get postRemovePhoto;

  /// No description provided for @postUploadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploading photo'**
  String get postUploadingPhoto;

  /// No description provided for @postAddPhotoFrom.
  ///
  /// In en, this message translates to:
  /// **'Add photo from {source}'**
  String postAddPhotoFrom(String source);

  /// No description provided for @postItemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get postItemName;

  /// No description provided for @postItemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Blue backpack'**
  String get postItemNameHint;

  /// No description provided for @postItemNameHintEdit.
  ///
  /// In en, this message translates to:
  /// **'e.g. Black wallet'**
  String get postItemNameHintEdit;

  /// No description provided for @postChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get postChooseCategory;

  /// No description provided for @postChooseCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get postChooseCategoryTitle;

  /// No description provided for @postDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get postDescription;

  /// No description provided for @postDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Last seen near the fountain at Central Park. It has a small scratch on the front…'**
  String get postDescriptionHint;

  /// No description provided for @postDescriptionHelper.
  ///
  /// In en, this message translates to:
  /// **'{count}/500 · at least 10 characters'**
  String postDescriptionHelper(int count);

  /// No description provided for @postDescriptionHintEdit.
  ///
  /// In en, this message translates to:
  /// **'Describe the item in detail…'**
  String get postDescriptionHintEdit;

  /// No description provided for @postDescriptionHelperEdit.
  ///
  /// In en, this message translates to:
  /// **'At least 10 characters'**
  String get postDescriptionHelperEdit;

  /// No description provided for @postRewardOptional.
  ///
  /// In en, this message translates to:
  /// **'Reward (optional)'**
  String get postRewardOptional;

  /// No description provided for @postRewardHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \$100'**
  String get postRewardHint;

  /// No description provided for @postRewardHintEdit.
  ///
  /// In en, this message translates to:
  /// **'e.g. 50'**
  String get postRewardHintEdit;

  /// No description provided for @postRewardNote.
  ///
  /// In en, this message translates to:
  /// **'A reward is shown as an amber tag on your post.'**
  String get postRewardNote;

  /// No description provided for @postLocationTime.
  ///
  /// In en, this message translates to:
  /// **'Location & time'**
  String get postLocationTime;

  /// No description provided for @postNoLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get postNoLocationSelected;

  /// No description provided for @postLocateMe.
  ///
  /// In en, this message translates to:
  /// **'Locate me'**
  String get postLocateMe;

  /// No description provided for @postOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get postOpenMap;

  /// No description provided for @postMovePin.
  ///
  /// In en, this message translates to:
  /// **'Move pin'**
  String get postMovePin;

  /// No description provided for @postPickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick on map'**
  String get postPickOnMap;

  /// No description provided for @postMovePinOnMap.
  ///
  /// In en, this message translates to:
  /// **'Move pin on map'**
  String get postMovePinOnMap;

  /// No description provided for @postTypeAddress.
  ///
  /// In en, this message translates to:
  /// **'Type an address instead'**
  String get postTypeAddress;

  /// No description provided for @postDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get postDate;

  /// No description provided for @postTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get postTime;

  /// No description provided for @postDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date / time'**
  String get postDateTime;

  /// No description provided for @postTapToPickDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick date'**
  String get postTapToPickDate;

  /// No description provided for @postLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Where was it lost or found?'**
  String get postLocationHint;

  /// No description provided for @postHowPeopleReachYou.
  ///
  /// In en, this message translates to:
  /// **'How people reach you'**
  String get postHowPeopleReachYou;

  /// No description provided for @postInAppChat.
  ///
  /// In en, this message translates to:
  /// **'In-app chat'**
  String get postInAppChat;

  /// No description provided for @postInAppChatNote.
  ///
  /// In en, this message translates to:
  /// **'Always on. Members contact you through Finder messages.'**
  String get postInAppChatNote;

  /// No description provided for @postOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get postOn;

  /// No description provided for @postShowPhone.
  ///
  /// In en, this message translates to:
  /// **'Show my phone number'**
  String get postShowPhone;

  /// No description provided for @postShowPhoneNote.
  ///
  /// In en, this message translates to:
  /// **'Shown on your profile to signed-in members'**
  String get postShowPhoneNote;

  /// No description provided for @postPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get postPhoneNumber;

  /// No description provided for @postPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +1 234 567 8900'**
  String get postPhoneHint;

  /// No description provided for @postPhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'Saved to your profile and shared with signed-in members.'**
  String get postPhoneHelper;

  /// No description provided for @postPostNow.
  ///
  /// In en, this message translates to:
  /// **'Post now'**
  String get postPostNow;

  /// No description provided for @postSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get postSaveDraft;

  /// No description provided for @postSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get postSaveChanges;

  /// No description provided for @postLocationSetTo.
  ///
  /// In en, this message translates to:
  /// **'Location set to {label}.'**
  String postLocationSetTo(String label);

  /// No description provided for @postEnterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get postEnterLocation;

  /// No description provided for @postEnterLocationHint.
  ///
  /// In en, this message translates to:
  /// **'City, street or area'**
  String get postEnterLocationHint;

  /// No description provided for @postErrTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the item name before posting.'**
  String get postErrTitleRequired;

  /// No description provided for @postErrDescriptionShort.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 10 characters in the description.'**
  String get postErrDescriptionShort;

  /// No description provided for @postErrPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a phone number or turn off phone sharing.'**
  String get postErrPhoneRequired;

  /// No description provided for @postErrLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to post.'**
  String get postErrLoginRequired;

  /// No description provided for @postErrTitleRequiredEdit.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get postErrTitleRequiredEdit;

  /// No description provided for @postErrDescriptionShortEdit.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters.'**
  String get postErrDescriptionShortEdit;

  /// No description provided for @postLive.
  ///
  /// In en, this message translates to:
  /// **'Your post is live.'**
  String get postLive;

  /// No description provided for @postUpdated.
  ///
  /// In en, this message translates to:
  /// **'Post updated.'**
  String get postUpdated;

  /// No description provided for @postPhotoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added.'**
  String get postPhotoAdded;

  /// No description provided for @postDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved locally.'**
  String get postDraftSaved;

  /// No description provided for @postUploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image…'**
  String get postUploadingImage;

  /// No description provided for @postTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get postTapToChange;

  /// No description provided for @postTapToPickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick from gallery'**
  String get postTapToPickFromGallery;

  /// No description provided for @postAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get postAddPhoto;

  /// No description provided for @postChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get postChangePhoto;

  /// No description provided for @postILostSomething.
  ///
  /// In en, this message translates to:
  /// **'I lost something'**
  String get postILostSomething;

  /// No description provided for @postIFoundSomething.
  ///
  /// In en, this message translates to:
  /// **'I found something'**
  String get postIFoundSomething;

  /// No description provided for @postAskCommunityHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask the community for help'**
  String get postAskCommunityHelp;

  /// No description provided for @postHelpReturnHome.
  ///
  /// In en, this message translates to:
  /// **'Help return it home'**
  String get postHelpReturnHome;

  /// No description provided for @postMyPosts.
  ///
  /// In en, this message translates to:
  /// **'My posts'**
  String get postMyPosts;

  /// No description provided for @postOpenReturnedCount.
  ///
  /// In en, this message translates to:
  /// **'{open} open · {returned} returned'**
  String postOpenReturnedCount(int open, int returned);

  /// No description provided for @postNoOpenPosts.
  ///
  /// In en, this message translates to:
  /// **'No open posts'**
  String get postNoOpenPosts;

  /// No description provided for @postNoReturnedYet.
  ///
  /// In en, this message translates to:
  /// **'No returned items yet'**
  String get postNoReturnedYet;

  /// No description provided for @postCreateYourFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first post to get started.'**
  String get postCreateYourFirst;

  /// No description provided for @postReturnedAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Posts you mark as returned will appear here.'**
  String get postReturnedAppearHere;

  /// No description provided for @postMarkReturnedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as returned?'**
  String get postMarkReturnedTitle;

  /// No description provided for @postMarkReturnedBody.
  ///
  /// In en, this message translates to:
  /// **'Mark \"{title}\" as returned? It leaves the Home feed but stays visible in Search.'**
  String postMarkReturnedBody(String title);

  /// No description provided for @postErrLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your posts.'**
  String get postErrLoad;

  /// No description provided for @postErrDelete.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the post.'**
  String get postErrDelete;

  /// No description provided for @postErrResolve.
  ///
  /// In en, this message translates to:
  /// **'Unable to resolve the post.'**
  String get postErrResolve;

  /// No description provided for @postErrReopen.
  ///
  /// In en, this message translates to:
  /// **'Unable to reopen the post.'**
  String get postErrReopen;

  /// No description provided for @postErrSave.
  ///
  /// In en, this message translates to:
  /// **'Unable to save the post.'**
  String get postErrSave;

  /// No description provided for @postSavedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved items'**
  String get postSavedItems;

  /// No description provided for @postSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep track of items you\'re helping to return or find.'**
  String get postSavedSubtitle;

  /// No description provided for @postSavedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved · items you are helping to return or find'**
  String postSavedCount(int count);

  /// No description provided for @postLoadingSaved.
  ///
  /// In en, this message translates to:
  /// **'Loading saved items...'**
  String get postLoadingSaved;

  /// No description provided for @postNoSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved items yet'**
  String get postNoSavedTitle;

  /// No description provided for @postNoSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on any post to keep it here.'**
  String get postNoSavedSubtitle;

  /// No description provided for @postSentForReview.
  ///
  /// In en, this message translates to:
  /// **'Sent for review. We\'ll tell you when it\'s live.'**
  String get postSentForReview;

  /// No description provided for @postWaitingForReview.
  ///
  /// In en, this message translates to:
  /// **'Waiting for review'**
  String get postWaitingForReview;

  /// No description provided for @postWaitingForReviewBody.
  ///
  /// In en, this message translates to:
  /// **'An admin checks every post before it goes public, usually within a few hours.'**
  String get postWaitingForReviewBody;

  /// No description provided for @postRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get postRejectedTitle;

  /// No description provided for @postRejectedReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String postRejectedReason(String reason);

  /// No description provided for @postEditAndResubmit.
  ///
  /// In en, this message translates to:
  /// **'Edit & resubmit'**
  String get postEditAndResubmit;

  /// No description provided for @postBadgeRejected.
  ///
  /// In en, this message translates to:
  /// **'NOT APPROVED'**
  String get postBadgeRejected;

  /// No description provided for @postBadgeExpired.
  ///
  /// In en, this message translates to:
  /// **'ARCHIVED'**
  String get postBadgeExpired;

  /// No description provided for @postExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get postExpiredTitle;

  /// No description provided for @postExpiredBody.
  ///
  /// In en, this message translates to:
  /// **'This post was archived after 90 days. Reopen it if it is still relevant.'**
  String get postExpiredBody;

  /// No description provided for @postTranslatedNote.
  ///
  /// In en, this message translates to:
  /// **'Translated automatically'**
  String get postTranslatedNote;

  /// No description provided for @postSeeOriginal.
  ///
  /// In en, this message translates to:
  /// **'See original'**
  String get postSeeOriginal;

  /// No description provided for @postSeeTranslation.
  ///
  /// In en, this message translates to:
  /// **'See translation'**
  String get postSeeTranslation;

  /// No description provided for @postPostLostCta.
  ///
  /// In en, this message translates to:
  /// **'Post lost item'**
  String get postPostLostCta;

  /// No description provided for @postPostFoundCta.
  ///
  /// In en, this message translates to:
  /// **'Post found item'**
  String get postPostFoundCta;

  /// No description provided for @mapNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get mapNearbyTitle;

  /// No description provided for @mapNearbyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No posts within {km} km} =1{1 post within {km} km} other{{count} posts within {km} km}}'**
  String mapNearbyCount(int count, int km);

  /// No description provided for @mapRadius.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String mapRadius(int km);

  /// No description provided for @mapNearbyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts around here yet. Try a larger radius.'**
  String get mapNearbyEmpty;

  /// No description provided for @repoUnableLogin.
  ///
  /// In en, this message translates to:
  /// **'Unable to login'**
  String get repoUnableLogin;

  /// No description provided for @repoUnableLoginGoogle.
  ///
  /// In en, this message translates to:
  /// **'Unable to login with Google'**
  String get repoUnableLoginGoogle;

  /// No description provided for @repoUnableLogout.
  ///
  /// In en, this message translates to:
  /// **'Unable to logout'**
  String get repoUnableLogout;

  /// No description provided for @repoUnableSignUp.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign up'**
  String get repoUnableSignUp;

  /// No description provided for @repoUnableSendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to send password reset code'**
  String get repoUnableSendResetCode;

  /// No description provided for @repoUnableVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify verification code'**
  String get repoUnableVerifyCode;

  /// No description provided for @repoUnableResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset password'**
  String get repoUnableResetPassword;

  /// No description provided for @repoUnableVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify email address'**
  String get repoUnableVerifyEmail;

  /// No description provided for @repoUnableResendCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend verification code'**
  String get repoUnableResendCode;

  /// No description provided for @repoUnableLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications.'**
  String get repoUnableLoadNotifications;

  /// No description provided for @repoUnableUpdateNotification.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the notification.'**
  String get repoUnableUpdateNotification;

  /// No description provided for @repoUnableUpdateNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to update notifications.'**
  String get repoUnableUpdateNotifications;

  /// No description provided for @repoUnableLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile.'**
  String get repoUnableLoadProfile;

  /// No description provided for @repoUnableUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to update your profile.'**
  String get repoUnableUpdateProfile;

  /// No description provided for @repoUnableLoadPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Unable to load privacy settings.'**
  String get repoUnableLoadPrivacy;

  /// No description provided for @repoUnableUpdatePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Unable to update privacy settings.'**
  String get repoUnableUpdatePrivacy;

  /// No description provided for @repoUnableLoadNotifSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notification settings.'**
  String get repoUnableLoadNotifSettings;

  /// No description provided for @repoUnableUpdateNotifSettings.
  ///
  /// In en, this message translates to:
  /// **'Unable to update notification settings.'**
  String get repoUnableUpdateNotifSettings;

  /// No description provided for @repoUnableLoadBlocked.
  ///
  /// In en, this message translates to:
  /// **'Unable to load blocked users.'**
  String get repoUnableLoadBlocked;

  /// No description provided for @repoUnableBlock.
  ///
  /// In en, this message translates to:
  /// **'Unable to block this user.'**
  String get repoUnableBlock;

  /// No description provided for @repoUnableUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unable to unblock this user.'**
  String get repoUnableUnblock;

  /// No description provided for @repoUnableSubmitVerification.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit your verification.'**
  String get repoUnableSubmitVerification;

  /// No description provided for @repoUnableLoadVerification.
  ///
  /// In en, this message translates to:
  /// **'Unable to load verification status.'**
  String get repoUnableLoadVerification;

  /// No description provided for @repoUnableDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete your account.'**
  String get repoUnableDeleteAccount;

  /// No description provided for @repoUnableLoadSaved.
  ///
  /// In en, this message translates to:
  /// **'Unable to load saved items.'**
  String get repoUnableLoadSaved;

  /// No description provided for @repoUnableUpdateSaved.
  ///
  /// In en, this message translates to:
  /// **'Unable to update saved items.'**
  String get repoUnableUpdateSaved;

  /// No description provided for @repoLoginToSave.
  ///
  /// In en, this message translates to:
  /// **'Please log in to save items.'**
  String get repoLoginToSave;

  /// No description provided for @repoLoginToManageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please log in to manage notifications.'**
  String get repoLoginToManageNotifications;

  /// No description provided for @repoActionBlockUsers.
  ///
  /// In en, this message translates to:
  /// **'block users'**
  String get repoActionBlockUsers;

  /// No description provided for @repoActionCheckVerification.
  ///
  /// In en, this message translates to:
  /// **'check verification'**
  String get repoActionCheckVerification;

  /// No description provided for @repoActionDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'delete your account'**
  String get repoActionDeleteAccount;

  /// No description provided for @repoActionSubmitVerification.
  ///
  /// In en, this message translates to:
  /// **'submit verification'**
  String get repoActionSubmitVerification;

  /// No description provided for @repoActionUpdateBlocked.
  ///
  /// In en, this message translates to:
  /// **'update blocked users'**
  String get repoActionUpdateBlocked;

  /// No description provided for @repoActionUpdateNotifSettings.
  ///
  /// In en, this message translates to:
  /// **'update notification settings'**
  String get repoActionUpdateNotifSettings;

  /// No description provided for @repoActionUpdatePrivacy.
  ///
  /// In en, this message translates to:
  /// **'update privacy settings'**
  String get repoActionUpdatePrivacy;

  /// No description provided for @repoActionUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'update your profile'**
  String get repoActionUpdateProfile;

  /// No description provided for @repoActionViewBlocked.
  ///
  /// In en, this message translates to:
  /// **'view blocked users'**
  String get repoActionViewBlocked;

  /// No description provided for @repoActionViewNotifSettings.
  ///
  /// In en, this message translates to:
  /// **'view notification settings'**
  String get repoActionViewNotifSettings;

  /// No description provided for @repoActionViewPrivacy.
  ///
  /// In en, this message translates to:
  /// **'view privacy settings'**
  String get repoActionViewPrivacy;

  /// No description provided for @repoActionViewProfile.
  ///
  /// In en, this message translates to:
  /// **'view your profile'**
  String get repoActionViewProfile;

  /// No description provided for @repoPleaseLogInTo.
  ///
  /// In en, this message translates to:
  /// **'Please log in to {action}.'**
  String repoPleaseLogInTo(String action);

  /// No description provided for @serverAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get serverAccountDeleted;

  /// No description provided for @serverAccountIsAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Account is already verified.'**
  String get serverAccountIsAlreadyVerified;

  /// No description provided for @serverCouldNotApproveTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not approve the request.'**
  String get serverCouldNotApproveTheRequest;

  /// No description provided for @serverCouldNotDeleteTheAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account.'**
  String get serverCouldNotDeleteTheAccount;

  /// No description provided for @serverCouldNotDeleteThePost.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the post.'**
  String get serverCouldNotDeleteThePost;

  /// No description provided for @serverCouldNotRegisterThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Could not register this device.'**
  String get serverCouldNotRegisterThisDevice;

  /// No description provided for @serverCouldNotRejectTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Could not reject the request.'**
  String get serverCouldNotRejectTheRequest;

  /// No description provided for @serverCouldNotResolveTheReport.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve the report.'**
  String get serverCouldNotResolveTheReport;

  /// No description provided for @serverCouldNotStoreTheImage.
  ///
  /// In en, this message translates to:
  /// **'Could not store the image.'**
  String get serverCouldNotStoreTheImage;

  /// No description provided for @serverCouldNotUpdateTheAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not update the account.'**
  String get serverCouldNotUpdateTheAccount;

  /// No description provided for @serverCouldNotUpdateThePost.
  ///
  /// In en, this message translates to:
  /// **'Could not update the post.'**
  String get serverCouldNotUpdateThePost;

  /// No description provided for @serverDatabaseErrorOccurredDuringLogin.
  ///
  /// In en, this message translates to:
  /// **'Database error occurred during login.'**
  String get serverDatabaseErrorOccurredDuringLogin;

  /// No description provided for @serverDatabaseErrorOccurredDuringRegistration.
  ///
  /// In en, this message translates to:
  /// **'Database error occurred during registration.'**
  String get serverDatabaseErrorOccurredDuringRegistration;

  /// No description provided for @serverDatabaseErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Database error occurred.'**
  String get serverDatabaseErrorOccurred;

  /// No description provided for @serverDatabaseError.
  ///
  /// In en, this message translates to:
  /// **'Database error.'**
  String get serverDatabaseError;

  /// No description provided for @serverEmailAndCodeAreRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and code are required.'**
  String get serverEmailAndCodeAreRequired;

  /// No description provided for @serverEmailIsAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Email is already registered.'**
  String get serverEmailIsAlreadyRegistered;

  /// No description provided for @serverEmailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully.'**
  String get serverEmailVerifiedSuccessfully;

  /// No description provided for @serverErrorBlockingUser.
  ///
  /// In en, this message translates to:
  /// **'Error blocking user.'**
  String get serverErrorBlockingUser;

  /// No description provided for @serverErrorCreatingPost.
  ///
  /// In en, this message translates to:
  /// **'Error creating post.'**
  String get serverErrorCreatingPost;

  /// No description provided for @serverErrorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account.'**
  String get serverErrorDeletingAccount;

  /// No description provided for @serverErrorDeletingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error deleting message.'**
  String get serverErrorDeletingMessage;

  /// No description provided for @serverErrorDeletingPost.
  ///
  /// In en, this message translates to:
  /// **'Error deleting post.'**
  String get serverErrorDeletingPost;

  /// No description provided for @serverErrorFetchingBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Error fetching blocked users.'**
  String get serverErrorFetchingBlockedUsers;

  /// No description provided for @serverErrorFetchingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error fetching profile.'**
  String get serverErrorFetchingProfile;

  /// No description provided for @serverErrorFetchingUserProfile.
  ///
  /// In en, this message translates to:
  /// **'Error fetching user profile.'**
  String get serverErrorFetchingUserProfile;

  /// No description provided for @serverErrorInitiatingConversation.
  ///
  /// In en, this message translates to:
  /// **'Error initiating conversation.'**
  String get serverErrorInitiatingConversation;

  /// No description provided for @serverErrorLoadingConversations.
  ///
  /// In en, this message translates to:
  /// **'Error loading conversations.'**
  String get serverErrorLoadingConversations;

  /// No description provided for @serverErrorLoadingMatches.
  ///
  /// In en, this message translates to:
  /// **'Error loading matches.'**
  String get serverErrorLoadingMatches;

  /// No description provided for @serverErrorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages.'**
  String get serverErrorLoadingMessages;

  /// No description provided for @serverErrorLoadingNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading notification settings.'**
  String get serverErrorLoadingNotificationSettings;

  /// No description provided for @serverErrorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error loading notifications.'**
  String get serverErrorLoadingNotifications;

  /// No description provided for @serverErrorLoadingPost.
  ///
  /// In en, this message translates to:
  /// **'Error loading post.'**
  String get serverErrorLoadingPost;

  /// No description provided for @serverErrorLoadingPosts.
  ///
  /// In en, this message translates to:
  /// **'Error loading posts.'**
  String get serverErrorLoadingPosts;

  /// No description provided for @serverErrorLoadingPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading privacy settings.'**
  String get serverErrorLoadingPrivacySettings;

  /// No description provided for @serverErrorLoadingReports.
  ///
  /// In en, this message translates to:
  /// **'Error loading reports.'**
  String get serverErrorLoadingReports;

  /// No description provided for @serverErrorLoadingSavedItems.
  ///
  /// In en, this message translates to:
  /// **'Error loading saved items.'**
  String get serverErrorLoadingSavedItems;

  /// No description provided for @serverErrorLoadingSimilarPosts.
  ///
  /// In en, this message translates to:
  /// **'Error loading similar posts.'**
  String get serverErrorLoadingSimilarPosts;

  /// No description provided for @serverErrorLoadingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics.'**
  String get serverErrorLoadingStatistics;

  /// No description provided for @serverErrorLoadingTheFile.
  ///
  /// In en, this message translates to:
  /// **'Error loading the file.'**
  String get serverErrorLoadingTheFile;

  /// No description provided for @serverErrorLoadingTheRequest.
  ///
  /// In en, this message translates to:
  /// **'Error loading the request.'**
  String get serverErrorLoadingTheRequest;

  /// No description provided for @serverErrorLoadingTheUser.
  ///
  /// In en, this message translates to:
  /// **'Error loading the user.'**
  String get serverErrorLoadingTheUser;

  /// No description provided for @serverErrorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users.'**
  String get serverErrorLoadingUsers;

  /// No description provided for @serverErrorLoadingVerificationRequests.
  ///
  /// In en, this message translates to:
  /// **'Error loading verification requests.'**
  String get serverErrorLoadingVerificationRequests;

  /// No description provided for @serverErrorLoadingVerificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Error loading verification status.'**
  String get serverErrorLoadingVerificationStatus;

  /// No description provided for @serverErrorRemovingSavedPost.
  ///
  /// In en, this message translates to:
  /// **'Error removing saved post.'**
  String get serverErrorRemovingSavedPost;

  /// No description provided for @serverErrorSavingPost.
  ///
  /// In en, this message translates to:
  /// **'Error saving post.'**
  String get serverErrorSavingPost;

  /// No description provided for @serverErrorSearchingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error searching users.'**
  String get serverErrorSearchingUsers;

  /// No description provided for @serverErrorSendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Error sending message.'**
  String get serverErrorSendingMessage;

  /// No description provided for @serverErrorSubmittingReport.
  ///
  /// In en, this message translates to:
  /// **'Error submitting report.'**
  String get serverErrorSubmittingReport;

  /// No description provided for @serverErrorSubmittingVerification.
  ///
  /// In en, this message translates to:
  /// **'Error submitting verification.'**
  String get serverErrorSubmittingVerification;

  /// No description provided for @serverErrorUnblockingUser.
  ///
  /// In en, this message translates to:
  /// **'Error unblocking user.'**
  String get serverErrorUnblockingUser;

  /// No description provided for @serverErrorUpdatingChat.
  ///
  /// In en, this message translates to:
  /// **'Error updating chat.'**
  String get serverErrorUpdatingChat;

  /// No description provided for @serverErrorUpdatingNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Error updating notification settings.'**
  String get serverErrorUpdatingNotificationSettings;

  /// No description provided for @serverErrorUpdatingNotification.
  ///
  /// In en, this message translates to:
  /// **'Error updating notification.'**
  String get serverErrorUpdatingNotification;

  /// No description provided for @serverErrorUpdatingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error updating notifications.'**
  String get serverErrorUpdatingNotifications;

  /// No description provided for @serverErrorUpdatingPost.
  ///
  /// In en, this message translates to:
  /// **'Error updating post.'**
  String get serverErrorUpdatingPost;

  /// No description provided for @serverErrorUpdatingPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Error updating privacy settings.'**
  String get serverErrorUpdatingPrivacySettings;

  /// No description provided for @serverErrorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile.'**
  String get serverErrorUpdatingProfile;

  /// No description provided for @serverFileNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'File no longer exists.'**
  String get serverFileNoLongerExists;

  /// No description provided for @serverFinderAdministratorsCannotBeBlocked.
  ///
  /// In en, this message translates to:
  /// **'Finder administrators cannot be blocked.'**
  String get serverFinderAdministratorsCannotBeBlocked;

  /// No description provided for @serverGoogleAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Google authentication failed.'**
  String get serverGoogleAuthenticationFailed;

  /// No description provided for @serverIfThatAddressIsRegisteredACode.
  ///
  /// In en, this message translates to:
  /// **'If that address is registered, a code is on its way.'**
  String get serverIfThatAddressIsRegisteredACode;

  /// No description provided for @serverIncorrectEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get serverIncorrectEmailOrPassword;

  /// No description provided for @serverIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get serverIncorrectPassword;

  /// No description provided for @serverInvalidOrExpiredToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired token.'**
  String get serverInvalidOrExpiredToken;

  /// No description provided for @serverInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid token.'**
  String get serverInvalidToken;

  /// No description provided for @serverInvalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code.'**
  String get serverInvalidVerificationCode;

  /// No description provided for @serverLocationSearchIsUnavailableRightNowTry.
  ///
  /// In en, this message translates to:
  /// **'Location search is unavailable right now. Try again in a moment.'**
  String get serverLocationSearchIsUnavailableRightNowTry;

  /// No description provided for @serverMessageCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Message cannot be empty.'**
  String get serverMessageCannotBeEmpty;

  /// No description provided for @serverMessageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Message not found.'**
  String get serverMessageNotFound;

  /// No description provided for @serverNoImageReceived.
  ///
  /// In en, this message translates to:
  /// **'No image received.'**
  String get serverNoImageReceived;

  /// No description provided for @serverNoVerificationRequest.
  ///
  /// In en, this message translates to:
  /// **'No verification request.'**
  String get serverNoVerificationRequest;

  /// No description provided for @serverNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated.'**
  String get serverNotAuthenticated;

  /// No description provided for @serverNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Not authorized.'**
  String get serverNotAuthorized;

  /// No description provided for @serverNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found.'**
  String get serverNotFound;

  /// No description provided for @serverPasswordHasBeenResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password has been reset successfully.'**
  String get serverPasswordHasBeenResetSuccessfully;

  /// No description provided for @serverPasswordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get serverPasswordIsRequired;

  /// No description provided for @serverPleaseChooseAnImageUnder8Mb.
  ///
  /// In en, this message translates to:
  /// **'Please choose an image under 8 MB.'**
  String get serverPleaseChooseAnImageUnder8Mb;

  /// No description provided for @serverPostDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully.'**
  String get serverPostDeletedSuccessfully;

  /// No description provided for @serverPostDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted.'**
  String get serverPostDeleted;

  /// No description provided for @serverPostNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found.'**
  String get serverPostNotFound;

  /// No description provided for @serverPostRemovedFromSavedList.
  ///
  /// In en, this message translates to:
  /// **'Post removed from saved list.'**
  String get serverPostRemovedFromSavedList;

  /// No description provided for @serverPostSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Post saved successfully.'**
  String get serverPostSavedSuccessfully;

  /// No description provided for @serverRemoveTheAdminRoleBeforeDeletingThis.
  ///
  /// In en, this message translates to:
  /// **'Remove the admin role before deleting this account.'**
  String get serverRemoveTheAdminRoleBeforeDeletingThis;

  /// No description provided for @serverRemoveTheAdminRoleBeforeSuspendingThis.
  ///
  /// In en, this message translates to:
  /// **'Remove the admin role before suspending this account.'**
  String get serverRemoveTheAdminRoleBeforeSuspendingThis;

  /// No description provided for @serverReportNotFound.
  ///
  /// In en, this message translates to:
  /// **'Report not found.'**
  String get serverReportNotFound;

  /// No description provided for @serverReportSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully.'**
  String get serverReportSubmittedSuccessfully;

  /// No description provided for @serverRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Request not found.'**
  String get serverRequestNotFound;

  /// No description provided for @serverThatFileDoesNotLookLikeAn.
  ///
  /// In en, this message translates to:
  /// **'That file does not look like an image we can read.'**
  String get serverThatFileDoesNotLookLikeAn;

  /// No description provided for @serverTheMessageYouAreReplyingToIs.
  ///
  /// In en, this message translates to:
  /// **'The message you are replying to is not in this chat.'**
  String get serverTheMessageYouAreReplyingToIs;

  /// No description provided for @serverThisAccountHasBeenSuspendedContactSupport.
  ///
  /// In en, this message translates to:
  /// **'This account has been suspended. Contact support if you think this is a mistake.'**
  String get serverThisAccountHasBeenSuspendedContactSupport;

  /// No description provided for @serverThisUserDoesNotAcceptDirectMessages.
  ///
  /// In en, this message translates to:
  /// **'This user does not accept direct messages.'**
  String get serverThisUserDoesNotAcceptDirectMessages;

  /// No description provided for @serverTooManyLocationLookupsPleaseSlowDown.
  ///
  /// In en, this message translates to:
  /// **'Too many location lookups. Please slow down.'**
  String get serverTooManyLocationLookupsPleaseSlowDown;

  /// No description provided for @serverUserBlockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully.'**
  String get serverUserBlockedSuccessfully;

  /// No description provided for @serverUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get serverUserNotFound;

  /// No description provided for @serverUserUnblockedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User unblocked successfully.'**
  String get serverUserUnblockedSuccessfully;

  /// No description provided for @serverVerificationCodeHasExpiredPleaseRequestA.
  ///
  /// In en, this message translates to:
  /// **'Verification code has expired. Please request a new one.'**
  String get serverVerificationCodeHasExpiredPleaseRequestA;

  /// No description provided for @serverVerificationCodeIsValid.
  ///
  /// In en, this message translates to:
  /// **'Verification code is valid.'**
  String get serverVerificationCodeIsValid;

  /// No description provided for @serverVerificationCodeResentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent successfully.'**
  String get serverVerificationCodeResentSuccessfully;

  /// No description provided for @serverVerificationCodeSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent successfully.'**
  String get serverVerificationCodeSentSuccessfully;

  /// No description provided for @serverYouAlreadyHaveAVerificationRequestUnder.
  ///
  /// In en, this message translates to:
  /// **'You already have a verification request under review.'**
  String get serverYouAlreadyHaveAVerificationRequestUnder;

  /// No description provided for @serverYouAlreadyReportedThisPost.
  ///
  /// In en, this message translates to:
  /// **'You already reported this post.'**
  String get serverYouAlreadyReportedThisPost;

  /// No description provided for @serverYouAreNotAParticipantInThis.
  ///
  /// In en, this message translates to:
  /// **'You are not a participant in this chat.'**
  String get serverYouAreNotAParticipantInThis;

  /// No description provided for @serverYouAreNotAParticipant.
  ///
  /// In en, this message translates to:
  /// **'You are not a participant.'**
  String get serverYouAreNotAParticipant;

  /// No description provided for @serverYouCanOnlyDeleteYourOwnMessages.
  ///
  /// In en, this message translates to:
  /// **'You can only delete your own messages.'**
  String get serverYouCanOnlyDeleteYourOwnMessages;

  /// No description provided for @serverYouCannotBlockYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot block yourself.'**
  String get serverYouCannotBlockYourself;

  /// No description provided for @serverYouCannotDeleteYourOwnAccountHere.
  ///
  /// In en, this message translates to:
  /// **'You cannot delete your own account here.'**
  String get serverYouCannotDeleteYourOwnAccountHere;

  /// No description provided for @serverYouCannotMessageThisUser.
  ///
  /// In en, this message translates to:
  /// **'You cannot message this user.'**
  String get serverYouCannotMessageThisUser;

  /// No description provided for @serverYouCannotMessageYourself.
  ///
  /// In en, this message translates to:
  /// **'You cannot message yourself.'**
  String get serverYouCannotMessageYourself;

  /// No description provided for @serverYouCannotRemoveYourOwnAdminRole.
  ///
  /// In en, this message translates to:
  /// **'You cannot remove your own admin role.'**
  String get serverYouCannotRemoveYourOwnAdminRole;

  /// No description provided for @serverYouCannotSuspendYourOwnAccount.
  ///
  /// In en, this message translates to:
  /// **'You cannot suspend your own account.'**
  String get serverYouCannotSuspendYourOwnAccount;

  /// No description provided for @serverYouDoNotOwnThisPost.
  ///
  /// In en, this message translates to:
  /// **'You do not own this post.'**
  String get serverYouDoNotOwnThisPost;

  /// No description provided for @serverYourAccountAndDataHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account and data have been deleted.'**
  String get serverYourAccountAndDataHaveBeenDeleted;

  /// No description provided for @serverYourIdentityIsAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Your identity is already verified.'**
  String get serverYourIdentityIsAlreadyVerified;

  /// No description provided for @serverThisRequestWasAlreadyHandled.
  ///
  /// In en, this message translates to:
  /// **'This request was already handled.'**
  String get serverThisRequestWasAlreadyHandled;

  /// No description provided for @serverRequestNotValid.
  ///
  /// In en, this message translates to:
  /// **'The request was not valid.'**
  String get serverRequestNotValid;

  /// No description provided for @serverSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get serverSessionExpired;

  /// No description provided for @serverNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do that.'**
  String get serverNotAllowed;

  /// No description provided for @serverProblem.
  ///
  /// In en, this message translates to:
  /// **'The server ran into a problem. Please try again.'**
  String get serverProblem;

  /// No description provided for @serverRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed ({status}).'**
  String serverRequestFailed(int status);

  /// No description provided for @serverTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to respond. Check your connection and try again.'**
  String get serverTimeout;

  /// No description provided for @serverOffline.
  ///
  /// In en, this message translates to:
  /// **'You seem to be offline. Check your connection and try again.'**
  String get serverOffline;

  /// No description provided for @serverThisPostIsAwaitingReview.
  ///
  /// In en, this message translates to:
  /// **'This post is awaiting review.'**
  String get serverThisPostIsAwaitingReview;

  /// No description provided for @serverApproveOrRejectThisPostFirst.
  ///
  /// In en, this message translates to:
  /// **'Approve or reject this post first.'**
  String get serverApproveOrRejectThisPostFirst;

  /// No description provided for @serverCouldNotApproveThePost.
  ///
  /// In en, this message translates to:
  /// **'Could not approve the post.'**
  String get serverCouldNotApproveThePost;

  /// No description provided for @serverCouldNotRejectThePost.
  ///
  /// In en, this message translates to:
  /// **'Could not reject the post.'**
  String get serverCouldNotRejectThePost;

  /// No description provided for @serverThatStatusIsNotPublic.
  ///
  /// In en, this message translates to:
  /// **'That status is not public.'**
  String get serverThatStatusIsNotPublic;

  /// No description provided for @serverNotAnApiKey.
  ///
  /// In en, this message translates to:
  /// **'That does not look like an API key.'**
  String get serverNotAnApiKey;

  /// No description provided for @serverProviderRejectedTheKey.
  ///
  /// In en, this message translates to:
  /// **'The provider rejected the key.'**
  String get serverProviderRejectedTheKey;

  /// No description provided for @serverModelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Model not found.'**
  String get serverModelNotFound;

  /// No description provided for @serverModelNameRequired.
  ///
  /// In en, this message translates to:
  /// **'A model name is required.'**
  String get serverModelNameRequired;

  /// No description provided for @serverBaseUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'A base URL and a model name are required for a custom provider.'**
  String get serverBaseUrlRequired;

  /// No description provided for @serverCouldNotReachProvider.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the AI provider.'**
  String get serverCouldNotReachProvider;

  /// No description provided for @serverCouldNotLoadAiSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not load the AI settings.'**
  String get serverCouldNotLoadAiSettings;

  /// No description provided for @serverCouldNotRemoveAiSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the AI settings.'**
  String get serverCouldNotRemoveAiSettings;
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
      <String>['ar', 'ckb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
