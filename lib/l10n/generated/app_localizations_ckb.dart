// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Central Kurdish (`ckb`).
class AppLocalizationsCkb extends AppLocalizations {
  AppLocalizationsCkb([String locale = 'ckb']) : super(locale);

  @override
  String get appName => 'Finder';

  @override
  String get commonCancel => 'پاشگەزبوونەوە';

  @override
  String get commonSave => 'پاشەکەوتکردن';

  @override
  String get commonDelete => 'سڕینەوە';

  @override
  String get commonRemove => 'لابردن';

  @override
  String get commonDiscard => 'فڕێدان';

  @override
  String get commonDone => 'تەواو';

  @override
  String get commonOk => 'باشە';

  @override
  String get commonClose => 'داخستن';

  @override
  String get commonBack => 'گەڕانەوە';

  @override
  String get commonNext => 'دواتر';

  @override
  String get commonSkip => 'تێپەڕاندن';

  @override
  String get commonContinue => 'بەردەوامبوون';

  @override
  String get commonRetry => 'دووبارە هەوڵدانەوە';

  @override
  String get commonTryAgain => 'دووبارە هەوڵ بدەرەوە';

  @override
  String get commonRefresh => 'نوێکردنەوە';

  @override
  String get commonOpen => 'کردنەوە';

  @override
  String get commonEdit => 'دەستکاری';

  @override
  String get commonShare => 'هاوبەشکردن';

  @override
  String get commonReport => 'ڕاپۆرتکردن';

  @override
  String get commonBlock => 'بلۆککردن';

  @override
  String get commonUnblock => 'لابردنی بلۆک';

  @override
  String get commonSend => 'ناردن';

  @override
  String get commonSearch => 'گەڕان';

  @override
  String get commonYes => 'بەڵێ';

  @override
  String get commonNo => 'نەخێر';

  @override
  String get commonLoading => 'بارکردن…';

  @override
  String get commonSaving => 'پاشەکەوتکردن…';

  @override
  String get commonSending => 'ناردن…';

  @override
  String get commonUploading => 'بەرزکردنەوە…';

  @override
  String get commonSeeAll => 'هەموو ببینە';

  @override
  String get commonViewProfile => 'بینینی پڕۆفایل';

  @override
  String get commonMoreOptions => 'هەڵبژاردەی زیاتر';

  @override
  String get commonLogOut => 'چوونەدەرەوە';

  @override
  String get commonLost => 'ونبوو';

  @override
  String get commonFound => 'دۆزراوە';

  @override
  String get commonReturned => 'گەڕێنراوەتەوە';

  @override
  String get commonMarkAsReturned => 'وەک گەڕێنراوە نیشانە بکە';

  @override
  String get commonMarkedAsReturned => 'وەک گەڕێنراوە نیشانە کرا.';

  @override
  String get commonReopen => 'دووبارە کردنەوە';

  @override
  String get commonPosts => 'پۆستەکان';

  @override
  String get commonMessages => 'نامەکان';

  @override
  String get commonNotifications => 'ئاگادارکردنەوەکان';

  @override
  String get commonProfile => 'پڕۆفایل';

  @override
  String get commonHome => 'سەرەکی';

  @override
  String get commonLocation => 'شوێن';

  @override
  String get commonLocationNotSpecified => 'شوێن دیاری نەکراوە';

  @override
  String get commonFinderUser => 'بەکارهێنەری Finder';

  @override
  String get commonYou => 'تۆ';

  @override
  String get commonSomethingWentWrong =>
      'هەڵەیەک ڕوویدا. تکایە دووبارە هەوڵ بدەرەوە.';

  @override
  String commonUploadFailed(String detail) {
    return 'بەرزکردنەوە سەرکەوتوو نەبوو. $detail';
  }

  @override
  String get commonCopied => 'کۆپی کرا.';

  @override
  String get commonJustNow => 'ئێستا';

  @override
  String commonMinutesAgo(int count) {
    return '$count خولەک لەمەوبەر';
  }

  @override
  String commonHoursAgo(int count) {
    return '$count کاتژمێر لەمەوبەر';
  }

  @override
  String commonDaysAgo(int count) {
    return '$count ڕۆژ لەمەوبەر';
  }

  @override
  String commonWeeksAgo(int count) {
    return '$count هەفتە لەمەوبەر';
  }

  @override
  String get commonToday => 'ئەمڕۆ';

  @override
  String get commonYesterday => 'دوێنێ';

  @override
  String commonMonthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'کانوونی دووەم',
      '2': 'شوبات',
      '3': 'ئازار',
      '4': 'نیسان',
      '5': 'ئایار',
      '6': 'حوزەیران',
      '7': 'تەممووز',
      '8': 'ئاب',
      '9': 'ئەیلوول',
      '10': 'تشرینی یەکەم',
      '11': 'تشرینی دووەم',
      '12': 'کانوونی یەکەم',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String commonWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'دووشەممە',
      '2': 'سێشەممە',
      '3': 'چوارشەممە',
      '4': 'پێنجشەممە',
      '5': 'هەینی',
      '6': 'شەممە',
      '7': 'یەکشەممە',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String commonDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String commonDayMonthYear(int day, String month, int year) {
    return '$day $month $year';
  }

  @override
  String get languageTitle => 'زمان';

  @override
  String get languageSubtitle => 'ئەو زمانە هەڵبژێرە کە Finder بەکاری دەهێنێت';

  @override
  String get languageSystem => 'زمانی مۆبایل بەکاربهێنە';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageKurdish => 'کوردی';

  @override
  String get languageChanged => 'زمان گۆڕدرا.';

  @override
  String get authLoginTitle => 'بەخێربێیتەوە';

  @override
  String get authLoginSubtitle =>
      'بچۆرە ژوورەوە بۆ ئەوەی بەردەوام بیت لە دۆزینەوەی ئەوەی گرنگە.';

  @override
  String get authEmailLabel => 'ئیمەیڵ';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'وشەی نهێنی';

  @override
  String get authPasswordHint => 'وشەی نهێنیت';

  @override
  String get authForgotPassword => 'وشەی نهێنیت لەبیرچووە؟';

  @override
  String get authSignIn => 'چوونەژوورەوە';

  @override
  String get authOrContinueWith => 'یان بەردەوام بە لەگەڵ';

  @override
  String get authContinueWithGoogle => 'بەردەوامبوون بە Google';

  @override
  String get authNoAccountPrompt => 'هەژمارت نییە؟';

  @override
  String get authSignUp => 'تۆماربوون';

  @override
  String get authInvalidEmail => 'ئیمەیڵێکی دروست بنووسە.';

  @override
  String get authPasswordMin6 => 'وشەی نهێنی دەبێت لانیکەم ٦ پیت بێت.';

  @override
  String get authSignupTitle => 'هەژمارەکەت دروست بکە';

  @override
  String get authSignupSubtitle =>
      'شتە ونبوو و دۆزراوەکان لەگەڵ کۆمەڵگە ڕاپۆرت بکە و بەدوایدا بچۆ.';

  @override
  String get authEmailAddressLabel => 'ناونیشانی ئیمەیڵ';

  @override
  String get authEmailAddressHint => 'yourname@example.com';

  @override
  String get authNameLabel => 'ناوت';

  @override
  String get authNameHint => 'بە چی بانگت بکەین؟';

  @override
  String get authPhoneLabel => 'ژمارەی مۆبایل';

  @override
  String get authPhoneHint => '+964 750 000 0000';

  @override
  String get authSignupPasswordHint => 'لانیکەم ٨ پیت';

  @override
  String get authPasswordRule =>
      'لانیکەم ٨ پیت بەکاربهێنە کە پیتێک و ژمارەیەکی تێدابێت.';

  @override
  String get authCreateAccount => 'دروستکردنی هەژمار';

  @override
  String get authOrSignUpWith => 'یان تۆمار بە لەگەڵ';

  @override
  String get authSignUpWithGoogle => 'تۆماربوون بە Google';

  @override
  String get authHaveAccountPrompt => 'پێشتر هەژمارت هەیە؟';

  @override
  String get authLogIn => 'چوونەژوورەوە';

  @override
  String get authForgotInvalidEmail => 'تکایە ئیمەیڵێکی دروست بنووسە';

  @override
  String get authForgotCodeSent =>
      'کۆدی پشتڕاستکردنەوە نێردرا! ئیمەیڵەکەت بپشکنە.';

  @override
  String get authForgotCodeResent =>
      'کۆدێکی نوێی پشتڕاستکردنەوە نێردرا! ئیمەیڵەکەت بپشکنە.';

  @override
  String get authForgotEnterNumericCode =>
      'تکایە کۆدی ٦ ژمارەیی پشتڕاستکردنەوە بنووسە';

  @override
  String get authForgotCodeVerified => 'کۆدەکە بە سەرکەوتوویی پشتڕاستکرایەوە!';

  @override
  String get authForgotPasswordsMismatch => 'وشە نهێنییەکان وەک یەک نین';

  @override
  String get authForgotPasswordUpdated =>
      'وشەی نهێنی بە سەرکەوتوویی نوێکرایەوە! تکایە بچۆرە ژوورەوە.';

  @override
  String get authForgotTitle => 'وشەی نهێنیم لەبیرچووە';

  @override
  String get authForgotSubtitle =>
      'ئیمەیڵەکەت بنووسە و کۆدێکی ٦ ژمارەیی پشتڕاستکردنەوەت بۆ دەنێرین.';

  @override
  String get authForgotCheckInboxTitle => 'ئیمەیڵەکەت بپشکنە';

  @override
  String authForgotCheckInboxSubtitle(String email) {
    return 'ئەو کۆدە ٦ ژمارەییە بنووسە کە بۆ $email نێردراوە.';
  }

  @override
  String get authForgotNewPasswordTitle => 'وشەی نهێنی نوێ دابنێ';

  @override
  String get authForgotNewPasswordSubtitle =>
      'وشەی نهێنییەکی نوێ و پارێزراو بۆ هەژمارەکەت دروست بکە.';

  @override
  String get authForgotSendCode => 'ناردنی کۆدی پشتڕاستکردنەوە';

  @override
  String get authForgotCancelAndLogIn => 'پاشگەزبوونەوە و چوونەژوورەوە';

  @override
  String get authVerificationCodeLabel => 'کۆدی پشتڕاستکردنەوە';

  @override
  String get authVerificationCodeHint => 'کۆدی ٦ ژمارەیی';

  @override
  String get authVerifyCode => 'پشتڕاستکردنەوەی کۆد';

  @override
  String get authChangeEmail => 'گۆڕینی ئیمەیڵ';

  @override
  String get authResendCode => 'دووبارە ناردنی کۆد';

  @override
  String get authNewPasswordLabel => 'وشەی نهێنی نوێ';

  @override
  String get authNewPasswordHint => 'لانیکەم ٦ پیت';

  @override
  String get authConfirmPasswordLabel => 'دڵنیاکردنەوەی وشەی نهێنی نوێ';

  @override
  String get authConfirmPasswordHint => 'وشەی نهێنی نوێ دووبارە بنووسەوە';

  @override
  String get authResetPassword => 'نوێکردنەوەی وشەی نهێنی';

  @override
  String get authStartOver => 'لە سەرەتاوە دەست پێبکەرەوە / ئیمەیڵ بگۆڕە';

  @override
  String get authVerifyEnterCode =>
      'تکایە کۆدی ٦ ژمارەیی پشتڕاستکردنەوە بنووسە.';

  @override
  String get authVerifiedWelcome =>
      'هەژمارەکە پشتڕاستکرایەوە. بەخێربێیت بۆ Finder!';

  @override
  String get authVerifyCodeResent =>
      'کۆدێکی نوێی پشتڕاستکردنەوە بۆ ئیمەیڵەکەت نێردرا.';

  @override
  String get authVerifyTitle => 'ئیمەیڵەکەت پشتڕاست بکەرەوە';

  @override
  String get authVerifySubtitle =>
      'کۆدێکی ٦ ژمارەیی پشتڕاستکردنەوەمان بۆ ئیمەیڵە تۆمارکراوەکەت نارد. لە خوارەوە بینووسە بۆ چالاککردنی هەژمارەکەت.';

  @override
  String get authVerifyAccount => 'پشتڕاستکردنەوەی هەژمار';

  @override
  String get authGoogleCancelled => 'چوونەژوورەوە بە Google هەڵوەشێنرایەوە.';

  @override
  String get authGoogleTokenFailed =>
      'زانیاری چوونەژوورەوە لە Google وەرنەگیرا.';

  @override
  String get authSessionExpired =>
      'دانیشتنەکەت بەسەرچوو. تکایە دووبارە بچۆرە ژوورەوە.';

  @override
  String get authSocialSemantic => 'بەردەوامبوون بە هەژماری کۆمەڵایەتی';

  @override
  String get authLegalAgreePrefix => 'بە دروستکردنی هەژمار ڕازی دەبیت بە ';

  @override
  String get authLegalAgreeAnd => ' و ';

  @override
  String get authLegalAgreeSuffix => '.';

  @override
  String get onboardLostTitle =>
      'شتێکت ون کردووە؟ لە یەک خولەکدا بڵاوی بکەرەوە';

  @override
  String get onboardLostDescription =>
      'وێنەیەک و شوێن و کاتی ونبوونەکە زیاد بکە. Finder پیشانی خەڵکی نزیکت دەدات و دەستبەجێ ئاگادارت دەکاتەوە کە شتێک لێکچوو.';

  @override
  String get onboardFoundTitle =>
      'شتێکت دۆزیوەتەوە؟ یارمەتی بدە بگەڕێتەوە ماڵەوە';

  @override
  String get onboardFoundDescription =>
      'ئەوەی دۆزیوتەتەوە بڵاوی بکەرەوە. کەسێک هەموو پۆستێک پێداچوونەوەی بۆ دەکات، و ئەپەکە بە زمانی خۆیان لەگەڵ ئەوانەی دەگەڕێن لێکی دەدات.';

  @override
  String get onboardConnectTitle =>
      'گفتوگۆ بکە، دڵنیا ببەوە، بە سەلامەتی بیگەڕێنەوە';

  @override
  String get onboardConnectDescription =>
      'لەناو ئەپەکە نامە بنێرە، پرسیاری وردەکارییەک بکە کە تەنها خاوەنەکە دەیزانێت، و لە شوێنێکی گشتی یەکتر ببینن. بەشی یارمەتی و پشتیوانی هەموو هەنگاوەکانت پێ دەڵێت.';

  @override
  String get onboardGetStarted => 'دەست پێ بکە';

  @override
  String get legalOpenWebVersion => 'کردنەوەی وەشانی وێب';

  @override
  String legalCouldNotOpen(String url) {
    return 'نەتوانرا $url بکرێتەوە';
  }

  @override
  String get legalPrivacyTitle => 'سیاسەتی تایبەتێتی';

  @override
  String get legalTermsTitle => 'مەرجەکانی خزمەتگوزاری';

  @override
  String get legalUpdated => 'دوایین نوێکردنەوە: ١٣ی ئەیلوولی ٢٠٢٦';

  @override
  String get legalPrivacyIntro =>
      'Finder یارمەتی خەڵک دەدات شتە ونبوو و دۆزراوەکان ڕاپۆرت بکەن و پەیوەندی بە یەکتر بکەن. ئەم سیاسەتە ڕوون دەکاتەوە ئەپەکە چ زانیارییەک کۆدەکاتەوە، بۆچی، و تۆ چ کۆنترۆڵێکت بەسەریدا هەیە.';

  @override
  String get legalPrivacy1Heading => '١. ئەو زانیارییانەی کۆیان دەکەینەوە';

  @override
  String get legalPrivacy1Body1 =>
      'زانیاری هەژمار: ئیمەیڵ، وشەی نهێنی (بە شێوەی شفرەکراو هەڵدەگیرێت)، ناو، نازناو و بە ئارەزوو ژمارەی مۆبایل، شار و پیشە.';

  @override
  String get legalPrivacy1Body2 =>
      'پۆستەکان: ناونیشان، وەسف، پۆلێن، دەقی شوێن، ڕێکەوت و ئەو وێنانەی هاوپێچیان دەکەیت.';

  @override
  String get legalPrivacy1Body3 =>
      'نامەکان: ئەو دەق و وێنانەی لەگەڵ ئەندامانی تردا ئاڵوگۆڕیان دەکەیت.';

  @override
  String get legalPrivacy1Body4 =>
      'پشتڕاستکردنەوەی ناسنامە (ئارەزوومەندانە): وێنەی بەڵگەنامەی ناسنامە و سێڵفی، تەنها بۆ پێدانی نیشانەی پشتڕاستکراو بەکاردێن.';

  @override
  String get legalPrivacy1Body5 =>
      'زانیاری تەکنیکی: تۆماری داواکارییەکان (ناونیشانی IP، خاڵی پەیوەندی، کات) بۆ ئاسایش هەڵدەگیرێن، لەگەڵ ڕاپۆرتی ناسناوی تێکچوون و ئاماری بەکارهێنان (کام شاشە بەکاردێن، هەرگیز ناوەڕۆکی پۆست یان نامەکان نا).';

  @override
  String get legalPrivacy1Body6 =>
      'چوونەژوورەوە بە Google: ئیمەیڵ، ناو و وێنەی پڕۆفایلت لە Google وەردەگرین.';

  @override
  String get legalPrivacy2Heading => '٢. چۆن بەکاریان دەهێنین';

  @override
  String get legalPrivacy2Body1 =>
      'بۆ کارپێکردنی خزمەتگوزارییەکە: پیشاندانی پۆستەکان، گەیاندنی نامە و ئاگادارکردنەوەکان، و ڕێگەدان بە ئەندامان پەیوەندی بە یەکتر بکەن. بۆ پاراستنی کۆمەڵگە: ڕاپۆرت، بلۆک و پشتڕاستکردنەوەی ناسنامە. بۆ ناردنی ئیمەیڵی پێویست وەک کۆدی پشتڕاستکردنەوە و نوێکردنەوەی وشەی نهێنی. هەواڵی بەرهەم تەنها ئەگەر خۆت ڕازی بیت دەنێردرێت.';

  @override
  String get legalPrivacy2Body2 =>
      'زانیاری کەسی نافرۆشین و ڕیکلامی لایەنی سێیەم پیشان نادەین.';

  @override
  String get legalPrivacy3Heading => '٣. ئەندامانی تر چی دەبینن';

  @override
  String get legalPrivacy3Body =>
      'ناو، وێنە و پۆستەکانت بۆ ئەندامە چووەژوورەوەکان دەبینرێن. ژمارەی مۆبایلت شاراوەیە مەگەر لە تایبەتێتی و سەلامەتی هاوبەشکردنی چالاک بکەیت. ئیمەیڵەکەت هەرگیز بۆ ئەندامانی تر پیشان نادرێت. ئەو ئەندامانەی بلۆکیان دەکەیت ناتوانن پۆستەکانت ببینن یان نامەت بۆ بنێرن.';

  @override
  String get legalPrivacy4Heading => '٤. زانیارییەکان لە کوێ هەڵدەگیرێن';

  @override
  String get legalPrivacy4Body =>
      'زانیارییەکان لەسەر ڕاژەکارەکانی دابینکەری هۆستینگ و وێنەکان لەسەر Cloudinary هەڵدەگیرێن، هەردووکیان بەپێی مەرجەکانی پرۆسێسکردنی زانیاری خۆیان. زانیارییەکان بە HTTPS دەگوازرێنەوە.';

  @override
  String get legalPrivacy5Heading => '٥. چەند دەیانهێڵینەوە';

  @override
  String get legalPrivacy5Body =>
      'زانیاری هەژمار تا هەژمارەکەت هەبێت دەهێڵرێتەوە. بەڵگەنامەکانی پشتڕاستکردنەوە دوای بڕیاردان دەسڕدرێنەوە، و نەک درەنگتر لە ٩٠ ڕۆژ دوای بەرزکردنەوە. تۆماری داواکارییەکان ٣٠ ڕۆژ دەهێڵرێنەوە.';

  @override
  String get legalPrivacy6Heading => '٦. مافەکانت';

  @override
  String get legalPrivacy6Body1 =>
      'دەستگەیشتن و ڕاستکردنەوە: هەر کاتێک بتەوێت پڕۆفایلەکەت لە ئەپەکەدا دەستکاری بکە.';

  @override
  String get legalPrivacy6Body2 =>
      'سڕینەوە: هەژمارەکەت لە تایبەتێتی و سەلامەتی ← سڕینەوەی هەژمار بسڕەوە. پۆست، گفتوگۆ، ڕێکخستن و پڕۆفایلەکەت دەستبەجێ لادەبرێن؛ کۆپییە یەدەگەکان لە ماوەی ٣٠ ڕۆژدا بەسەردەچن.';

  @override
  String get legalPrivacy6Body3 =>
      'گواستنەوەی زانیاری و پرسیارەکان: بنووسە بۆ privacy@finder.app.';

  @override
  String get legalPrivacy7Heading => '٧. منداڵان';

  @override
  String get legalPrivacy7Body =>
      'Finder بۆ منداڵانی خوار ١٦ ساڵ نییە. ئەو هەژمارانە لادەبەین کە بزانین هی منداڵن.';

  @override
  String get legalPrivacy8Heading => '٨. گۆڕانکارییەکان';

  @override
  String get legalPrivacy8Body =>
      'گۆڕانکارییە گرنگەکان پێش جێبەجێبوونیان لە ئەپەکەدا ڕادەگەیەنین. ئەو ڕێکەوتەی سەرەوە پیشان دەدات ئەم سیاسەتە دوایین جار کەی پێداچوونەوەی بۆ کراوە.';

  @override
  String get legalTermsIntro =>
      'بە دروستکردنی هەژمار یان بەکارهێنانی Finder ڕازی دەبیت بەم مەرجانە. ئەگەر ڕازی نیت، خزمەتگوزارییەکە بەکارمەهێنە.';

  @override
  String get legalTerms1Heading => '١. خزمەتگوزارییەکە';

  @override
  String get legalTerms1Body =>
      'Finder تابلۆیەکی ئاگاداری کۆمەڵگەیە بۆ شتە ونبوو و دۆزراوەکان. ئێمە شوێنی بڵاوکردنەوە و گفتوگۆ دابین دەکەین؛ بەشداری لە ڕادەستکردن ناکەین، پشتڕاست ناکەینەوە کە شتێک هی ئەندامێکە، و لایەن نین لە هیچ ڕێککەوتنێکی پاداشت لەنێوان ئەنداماندا.';

  @override
  String get legalTerms2Heading => '٢. هەژمارەکەت';

  @override
  String get legalTerms2Body =>
      'دەبێت لانیکەم ١٦ ساڵ بیت. وشەی نهێنیت بە نهێنی بپارێزە؛ تۆ بەرپرسیاری لە چالاکی هەژمارەکەت. یەک کەس، یەک هەژمار. خۆت وەک کەسانی تر پیشان مەدە.';

  @override
  String get legalTerms3Heading => '٣. ناوەڕۆکەکەت';

  @override
  String get legalTerms3Body =>
      'خاوەندارێتی ئەوەی بڵاوی دەکەیتەوە بۆ خۆت دەمێنێتەوە. مۆڵەت بە Finder دەدەیت لەناو خزمەتگوزارییەکەدا هەڵیبگرێت، پیشانی بدات و بڵاوی بکاتەوە تا ئەندامانی تر بیبینن. تەنها ئەو وێنە و زانیارییانە بڵاو بکەرەوە کە مافی هاوبەشکردنیانت هەیە.';

  @override
  String get legalTerms4Heading => '٤. ڕێساکانی ڕەفتار';

  @override
  String get legalTerms4Body1 =>
      'نابێت: ڕاپۆرتی درۆ بڵاو بکەیتەوە یان داوای شتێک بکەیت کە هی تۆ نییە؛ پێش گەڕاندنەوەی شتێک داوای پارە بکەیت یان خزمەتگوزارییەکە بۆ فێڵ بەکاربهێنیت؛ ئەندامانی تر بێزار بکەیت، هەڕەشەیان لێ بکەیت یان جیاکارییان لەگەڵ بکەیت؛ ناوەڕۆکی نایاسایی یان ناوەڕۆکێک بڵاو بکەیتەوە کە مافی کەسانی تر پێشێل دەکات؛ زانیاری خزمەتگوزارییەکە کۆبکەیتەوە، API تاقی بکەیتەوە یان کارپێکردنی تێک بدەیت.';

  @override
  String get legalTerms4Body2 =>
      'دەتوانین ناوەڕۆک لابەین، ئەو هەژمارانە ڕابگرین یان بسڕینەوە کە ئەم ڕێسایانە دەشکێنن، و لە کاتی پێویستدا هاوکاری لایەنە یاساییەکان بکەین.';

  @override
  String get legalTerms5Heading => '٥. سەلامەتی';

  @override
  String get legalTerms5Body =>
      'لە شوێنی گشتی یەکتر ببینن، کەسێک لەگەڵ خۆت ببە، و هەرگیز پێش وەرگرتنی شتەکەت پاداشت مەدە. گفتوگۆی ناو ئەپەکە بەکاربهێنە تا بتوانیت بلۆک و ڕاپۆرت بکەیت. Finder ناتوانێت ڕاستگۆیی هیچ ئەندامێک گەرەنتی بکات.';

  @override
  String get legalTerms6Heading => '٦. پشتڕاستکردنەوەی ناسنامە';

  @override
  String get legalTerms6Body =>
      'نیشانەی پشتڕاستکراو واتە ئەندامێک بەڵگەنامەی ناسنامەی پێشکەش کردووە کە تیمەکەمان پێداچوونەوەی بۆ کردووە. ئەمە گەرەنتی ناسنامە یان نیازپاکی نییە.';

  @override
  String get legalTerms7Heading => '٧. بەردەستبوون و گۆڕانکارییەکان';

  @override
  String get legalTerms7Body =>
      'دەتوانین هەر کاتێک تایبەتمەندییەکان بگۆڕین یان ڕایانبگرین. هەوڵ دەدەین خزمەتگوزارییەکە بەردەست بێت بەڵام بەڵێنی کارپێکردنی بێ پچڕان نادەین.';

  @override
  String get legalTerms8Heading => '٨. بەرپرسیارێتی';

  @override
  String get legalTerms8Body =>
      'تا ئەو ڕادەیەی یاسا ڕێگە دەدات، Finder \"وەک خۆی\" پێشکەش دەکرێت و ئێمە بەرپرسیار نین لە زیانەکانی بەکارهێنانی خزمەتگوزارییەکە، ڕەفتاری ئەندامانی تر، یان ئەو شتانەی نادۆزرێنەوە.';

  @override
  String get legalTerms9Heading => '٩. کۆتاییهێنان';

  @override
  String get legalTerms9Body =>
      'دەتوانیت هەر کاتێک هەژمارەکەت لە تایبەتێتی و سەلامەتی بسڕیتەوە. ئێمە دەتوانین کۆتایی بەو هەژمارانە بهێنین کە ئەم مەرجانە پێشێل دەکەن.';

  @override
  String get legalTerms10Heading => '١٠. پەیوەندی';

  @override
  String get legalTerms10Body =>
      'پرسیار دەربارەی ئەم مەرجانە: support@finder.app';

  @override
  String get adminConsoleTitle => 'پانێڵی بەڕێوەبەر';

  @override
  String get adminConsoleSubtitle =>
      'بەکارهێنەران، پۆستەکان، ڕاپۆرتەکان و پشتڕاستکردنەوە';

  @override
  String get adminModeration => 'چاودێری';

  @override
  String get adminUsersTitle => 'بەکارهێنەران';

  @override
  String get adminUsersTileSubtitle =>
      'گەڕان، پشتڕاستکردنەوە، ڕاگرتن، بەرزکردنەوە یان سڕینەوەی هەژمارەکان';

  @override
  String get adminPostsTileSubtitle =>
      'هەموو پۆستە ونبوو و دۆزراوەکان، کراوە یان گەڕێنراوە';

  @override
  String get adminReportsTitle => 'ڕاپۆرتەکان';

  @override
  String get adminReportsSubtitle => 'ئەو پۆستانەی ئەندامان ڕاپۆرتیان کردوون';

  @override
  String get adminVerificationTitle => 'پشتڕاستکردنەوەی ناسنامە';

  @override
  String get adminVerificationTileSubtitle =>
      'پێداچوونەوە بە بەڵگەنامە و سێڵفییەکان';

  @override
  String get adminStatMembers => 'ئەندامان';

  @override
  String get adminVerifiedLabel => 'پشتڕاستکراو';

  @override
  String get adminStatOpenPosts => 'پۆستی کراوە';

  @override
  String get adminStatToVerify => 'چاوەڕێی پشتڕاستکردنەوە';

  @override
  String get adminSuspendedLabel => 'ڕاگیراو';

  @override
  String get adminStatMessages24h => 'نامەی ٢٤ کاتژمێر';

  @override
  String get adminPostsSubtitle => 'هەموو ئەوەی لە فیدەکەدایە';

  @override
  String get adminPostsSearchHint => 'ناونیشان، وەسف، خاوەن';

  @override
  String get adminFilterAll => 'هەموو';

  @override
  String get adminFilterOpen => 'کراوە';

  @override
  String get adminFilterReported => 'ڕاپۆرتکراو';

  @override
  String get adminFilterHandled => 'یەکلاکراوە';

  @override
  String get adminFilterAdmins => 'بەڕێوەبەران';

  @override
  String get adminFilterPending => 'چاوەڕوان';

  @override
  String get adminFilterApproved => 'پەسەندکراو';

  @override
  String get adminFilterRejected => 'ڕەتکراوە';

  @override
  String get adminNoPostsHere => 'هیچ پۆستێک لێرە نییە';

  @override
  String adminPostSheetSubtitle(String owner, String status) {
    return 'لەلایەن $owner · $status';
  }

  @override
  String get adminStatusReturned => 'گەڕێنراوەتەوە';

  @override
  String get adminStatusOpen => 'کراوە';

  @override
  String get adminOpenThePost => 'کردنەوەی پۆستەکە';

  @override
  String get adminReopenThePost => 'دووبارە کردنەوەی پۆستەکە';

  @override
  String get adminPostReopened => 'پۆستەکە دووبارە کرایەوە.';

  @override
  String get adminRemoveThePost => 'لابردنی پۆستەکە';

  @override
  String get adminRemovePostOwnerNotified =>
      'خاوەنەکە بە هۆکارەکەت ئاگادار دەکرێتەوە';

  @override
  String get adminPostRemoved => 'پۆستەکە لابرا.';

  @override
  String get adminRemovePostTitle => 'ئەم پۆستە لابدرێت؟';

  @override
  String get adminRemovePostReasonSubtitle =>
      'هۆکارێکی کورت بۆ خاوەنەکە دەنێردرێت.';

  @override
  String get adminReasonOptionalLabel => 'هۆکار (ئارەزوومەندانە)';

  @override
  String get adminReasonPostHint => 'نموونە: شتێکی ونبوو یان دۆزراوە نییە';

  @override
  String get adminNoOpenReports => 'هیچ ڕاپۆرتێکی کراوە نییە';

  @override
  String get adminNothingHandledYet => 'هێشتا هیچ یەکلا نەکراوەتەوە';

  @override
  String get adminBadgeOpen => 'کراوە';

  @override
  String get adminBadgeHandled => 'یەکلاکراوە';

  @override
  String get adminNoReasonGiven => 'هۆکار نەنووسراوە';

  @override
  String adminQuotedReason(String reason) {
    return '\"$reason\"';
  }

  @override
  String adminReportedBy(String name, String time) {
    return 'ڕاپۆرتکراوە لەلایەن $name · $time';
  }

  @override
  String adminPostBySuffix(String name) {
    return ' · پۆستی $name';
  }

  @override
  String get adminDismissReport => 'ڕەتکردنەوەی ڕاپۆرتەکە';

  @override
  String get adminPostStaysUp => 'پۆستەکە دەمێنێتەوە';

  @override
  String get adminRemovePostSettles =>
      'هەموو ڕاپۆرتەکانی یەکلا دەکاتەوە؛ خاوەنەکە ئاگادار دەکرێتەوە';

  @override
  String adminRemovePostConfirmBody(String title) {
    return '\"$title\" و گفتوگۆکانی دەسڕدرێنەوە. ئەمە ناگەڕێتەوە.';
  }

  @override
  String get adminReportDismissed => 'ڕاپۆرتەکە ڕەتکرایەوە.';

  @override
  String get adminUsersSubtitle => 'هەژمارەکانی سەر Finder';

  @override
  String get adminUsersSearchHint => 'ناو، نازناو یان ئیمەیڵ';

  @override
  String get adminNoAccountsMatch => 'هیچ هەژمارێک نەدۆزرایەوە';

  @override
  String get adminRemoveVerifiedBadge => 'لابردنی نیشانەی پشتڕاستکراو';

  @override
  String get adminMarkAsVerified => 'نیشانەکردن وەک پشتڕاستکراو';

  @override
  String get adminRemoveBadgeSubtitle =>
      'نیشانەکە لە پڕۆفایل و پۆستەکانی نامێنێت';

  @override
  String get adminGrantBadgeSubtitle =>
      'نیشانەکە بەبێ پێداچوونەوەی بەڵگەنامە دەدات';

  @override
  String get adminVerifiedBadgeRemoved => 'نیشانەی پشتڕاستکراو لابرا.';

  @override
  String get adminMarkedAsVerified => 'وەک پشتڕاستکراو نیشانە کرا.';

  @override
  String get adminRemoveAdminRole => 'لابردنی ڕۆڵی بەڕێوەبەر';

  @override
  String get adminMakeAdministrator => 'کردن بە بەڕێوەبەر';

  @override
  String get adminLoseConsoleAccess => 'دەستگەیشتنی بەم پانێڵە لەدەست دەدات';

  @override
  String get adminFullAccess =>
      'دەستگەیشتنی تەواو بە بەکارهێنەران، پۆستەکان و ڕاپۆرتەکان';

  @override
  String get adminRemoveAdminRoleTitle => 'ڕۆڵی بەڕێوەبەر لابدرێت؟';

  @override
  String adminMakeAdminTitle(String name) {
    return '$name بکرێت بە بەڕێوەبەر؟';
  }

  @override
  String adminRemoveAdminBody(String name) {
    return '$name چیتر ناتوانێت چاودێری Finder بکات.';
  }

  @override
  String get adminMakeAdminBody =>
      'بەڕێوەبەران دەتوانن هەر هەژمارێک ڕابگرن یان بسڕنەوە و هەر پۆستێک لابەن.';

  @override
  String get adminRemoveRole => 'لابردنی ڕۆڵ';

  @override
  String get adminMakeAdmin => 'کردن بە بەڕێوەبەر';

  @override
  String get adminRoleRemoved => 'ڕۆڵی بەڕێوەبەر لابرا.';

  @override
  String adminNowAdmin(String name) {
    return '$name ئێستا بەڕێوەبەرە.';
  }

  @override
  String get adminLiftSuspension => 'هەڵگرتنی ڕاگرتن';

  @override
  String get adminSuspendAccount => 'ڕاگرتنی هەژمار';

  @override
  String get adminCanSignInAgain => 'دەتوانێت دووبارە بچێتە ژوورەوە';

  @override
  String get adminSignedOutCannotSignIn => 'دەردەکرێت و ناتوانێت بچێتە ژوورەوە';

  @override
  String get adminLiftSuspensionTitle => 'ڕاگرتنەکە هەڵبگیرێت؟';

  @override
  String adminSuspendTitle(String name) {
    return '$name ڕابگیرێت؟';
  }

  @override
  String get adminLiftBody => 'هەژمارەکە دووبارە بە ئاسایی کاردەکات.';

  @override
  String get adminSuspendBody =>
      'پۆستەکانی دەمێننەوە. دەستگەیشتنی نامێنێت تا ڕاگرتنەکە هەڵدەگریت.';

  @override
  String get adminLift => 'هەڵگرتن';

  @override
  String get adminSuspend => 'ڕاگرتن';

  @override
  String get adminSuspensionLifted => 'ڕاگرتنەکە هەڵگیرا.';

  @override
  String get adminAccountSuspended => 'هەژمارەکە ڕاگیرا.';

  @override
  String get adminDeleteAccount => 'سڕینەوەی هەژمار';

  @override
  String get adminDeleteAccountSubtitle =>
      'هەژمارەکە، پۆستەکانی و گفتوگۆکانی لادەبات. ناگەڕێتەوە.';

  @override
  String adminDeleteTitle(String name) {
    return '$name بسڕدرێتەوە؟';
  }

  @override
  String get adminDeleteBody =>
      'هەموو ئەوەی بڵاوی کردووەتەوە و هەموو گفتوگۆیەک کە تێیدا بووە بە یەکجاری دەسڕدرێنەوە.';

  @override
  String get adminAccountDeleted => 'هەژمارەکە سڕایەوە.';

  @override
  String adminYouSuffix(String name) {
    return '$name (تۆ)';
  }

  @override
  String adminPostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پۆست',
      one: '١ پۆست',
    );
    return '$_temp0';
  }

  @override
  String adminReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ڕاپۆرت',
      one: '١ ڕاپۆرت',
    );
    return '$_temp0';
  }

  @override
  String adminJoined(String time) {
    return 'بەشداربووە $time';
  }

  @override
  String get adminBadgeSuspended => 'ڕاگیراو';

  @override
  String get adminQueueTitle => 'ڕیزی پێداچوونەوە';

  @override
  String get adminQueueSubtitle => 'داواکارییەکانی پشتڕاستکردنەوەی ناسنامە';

  @override
  String get adminNothingToReview => 'هیچ شتێک بۆ پێداچوونەوە نییە';

  @override
  String get adminNoRequestsHere => 'هیچ داواکارییەک لێرە نییە';

  @override
  String get adminNewRequestsShowHere =>
      'داواکارییە نوێیەکانی پشتڕاستکردنەوە لێرە دەردەکەون.';

  @override
  String get adminBadgeRejected => 'ڕەتکراوە';

  @override
  String get adminBadgePending => 'چاوەڕوان';

  @override
  String get adminDocIdCard => 'کارتی ناسنامە';

  @override
  String get adminDocDriversLicense => 'مۆڵەتی شۆفێری';

  @override
  String get adminDocPassport => 'پاسپۆرت';

  @override
  String get adminDocDocument => 'بەڵگەنامە';

  @override
  String adminSubmitted(String doc, String time) {
    return '$doc · نێردراوە $time';
  }

  @override
  String adminReviewedStatus(String status, String time) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'approved': 'پەسەندکراوە $time',
      'rejected': 'ڕەتکراوەتەوە $time',
      'other': '$status $time',
    });
    return '$_temp0';
  }

  @override
  String adminReasonPrefix(String reason) {
    return 'هۆکار: $reason';
  }

  @override
  String get adminDocumentSection => 'بەڵگەنامە';

  @override
  String get adminStep1 => 'هەنگاوی ١';

  @override
  String get adminLiveSelfie => 'سێڵفی ڕاستەوخۆ';

  @override
  String get adminStep2 => 'هەنگاوی ٢';

  @override
  String get adminFrontOfId => 'ڕووی پێشەوەی ناسنامە';

  @override
  String get adminPhotoPage => 'لاپەڕەی وێنە';

  @override
  String get adminBackOfId => 'ڕووی پشتەوەی ناسنامە';

  @override
  String get adminSelfieCaption => 'سێڵفی گیراو بە کامێرای پێشەوە';

  @override
  String get adminReviewGuidance =>
      'ڕووخساری ناو بەڵگەنامەکە بەراورد بکە لەگەڵ سێڵفییەکە، بزانە ناوەکە لەگەڵ هەژمارەکە یەکدەگرێتەوە، و بەڵگەنامەکە بەسەرنەچووە یان دەستکاری نەکراوە.';

  @override
  String adminTapToZoom(String caption) {
    return '$caption · دەست لێبدە بۆ گەورەکردن';
  }

  @override
  String get adminReject => 'ڕەتکردنەوە';

  @override
  String get adminApprove => 'پەسەندکردن';

  @override
  String get adminApproveTitle => 'ئەم ناسنامەیە پەسەند بکرێت؟';

  @override
  String adminApproveBody(String name) {
    return '$name نیشانەی پشتڕاستکراو و ئاگادارکردنەوەیەک وەردەگرێت.';
  }

  @override
  String get adminIdentityApproved => 'ناسنامەکە پەسەند کرا.';

  @override
  String get adminRejectRequestTitle => 'ڕەتکردنەوەی داواکاری';

  @override
  String adminRejectReasonSubtitle(String name) {
    return 'هۆکارەکە بۆ $name دەنێردرێت تا بتوانێت چاکی بکات.';
  }

  @override
  String get adminReasonLabel => 'هۆکار';

  @override
  String get adminRejectReasonHint =>
      'نموونە: سێڵفییەکە زۆر تاریکە بۆ بەراوردکردن لەگەڵ بەڵگەنامەکە.';

  @override
  String get adminRequestRejected => 'داواکارییەکە ڕەتکرایەوە.';

  @override
  String get stateErrorTitle => 'هەڵەیەک ڕوویدا';

  @override
  String get stateLoading => 'بارکردن';

  @override
  String get uiShowPassword => 'پیشاندانی وشەی نهێنی';

  @override
  String get uiHidePassword => 'شاردنەوەی وشەی نهێنی';

  @override
  String get uiCouldNotLoad => 'بار نەکرا';

  @override
  String get adminStatToApprove => 'چاوەڕێی پەسەندکردن';

  @override
  String get adminStatRejected => 'ڕەتکراوە';

  @override
  String adminFilterPendingCount(int count) {
    return 'چاوەڕوان ($count)';
  }

  @override
  String get adminNothingToApprove => 'هیچ شتێک بۆ پەسەندکردن نییە';

  @override
  String get adminNothingToApproveBody =>
      'پۆستە نوێیەکان لێرە دەردەکەون پێش ئەوەی کەسی تر بیانبینێت.';

  @override
  String get adminReviewTitle => 'پێداچوونەوە بەم پۆستە';

  @override
  String adminRiskLabel(int score) {
    return 'مەترسی AI $score';
  }

  @override
  String get adminRiskUnavailable => 'پشکنینی AI بەردەست نییە';

  @override
  String get adminRiskLow => 'باش دیارە';

  @override
  String get adminRiskMedium => 'بە وردی بپشکنە';

  @override
  String get adminRiskHigh => 'لەوانەیە ڕەت بکرێتەوە';

  @override
  String adminOriginalText(String lang) {
    return 'دەقی ڕەسەن ($lang)';
  }

  @override
  String get adminRejectPostTitle => 'ئەم پۆستە ڕەت بکرێتەوە؟';

  @override
  String get adminRejectPostSubtitle =>
      'هۆکارەکە بۆ خاوەنەکە دەنێردرێت تا چاکی بکات و دووبارە بینێرێت.';

  @override
  String get adminRejectPostHint => 'نموونە: وێنەکە شتەکە پیشان نادات.';

  @override
  String get adminPostApproved => 'پۆستەکە پەسەند کرا. ئێستا بڵاوە.';

  @override
  String get adminPostRejected =>
      'پۆستەکە ڕەتکرایەوە. خاوەنەکە ئاگادار کرایەوە.';

  @override
  String get adminStatusPending => 'چاوەڕوان';

  @override
  String get adminStatusRejected => 'ڕەتکراوە';

  @override
  String get adminStatusExpired => 'ئەرشیفکراو';

  @override
  String get adminAiTitle => 'یاریدەدەری AI';

  @override
  String get adminAiSubtitle =>
      'دابینکەر، مۆدێل و کلیل بۆ وەرگێڕان و پێش‌پشکنین';

  @override
  String get adminAiNotConfigured =>
      'ڕێک نەخراوە. پۆستەکان وەرناگێڕدرێن و پێش‌پشکنین ناکرێن.';

  @override
  String get adminAiKeyLabel => 'کلیلی API';

  @override
  String get adminAiKeyHint => 'کلیلەکە لە داشبۆردی دابینکەرەکە بلکێنە';

  @override
  String get adminAiKeyBody =>
      'کلیلەکە یەک جار پشتڕاست دەکرێتەوە، بە شێوەی کۆدکراو لەسەر ڕاژەکار هەڵدەگیرێت و جارێکی تر پیشان نادرێت. دەستبەجێ بۆ هەموو بەکارهێنەران کار دەکات. هەر پۆستێکی نوێ نزیکەی یەک سەنت تێدەچێت لەسەر هەرزانترین مۆدێلەکان.';

  @override
  String get adminAiProvider => 'دابینکەر';

  @override
  String get adminAiModelLabel => 'مۆدێل';

  @override
  String get adminAiModelHint => 'بنەڕەتییەکە بهێڵەوە ئەگەر دڵنیا نیت';

  @override
  String get adminAiBaseUrlLabel => 'لینکی بنەڕەتی';

  @override
  String get adminAiBaseUrlHint => 'https://openrouter.ai/api/v1';

  @override
  String get adminAiKeyHintReplace =>
      'کلیلێکی نوێ بلکێنە بۆ گۆڕینی پاشەکەوتکراوەکە';

  @override
  String get adminAiSourceDb => 'لە ئەپەکەوە پاشەکەوت کراوە';

  @override
  String get adminAiSourceEnv => 'لەسەر ڕاژەکار دانراوە';

  @override
  String get adminAiSourceNone => 'دانەنراوە';

  @override
  String adminAiBacklog(int translations, int scores) {
    return '$translations پۆست چاوەڕێی وەرگێڕانن · $scores چاوەڕێی نمرەی مەترسین';
  }

  @override
  String adminAiSaved(int count) {
    return 'کلیلەکە پشتڕاستکرایەوە. $count پۆست بۆ هەمووان وەردەگێڕدرێن…';
  }

  @override
  String get adminAiRemove => 'لابردنی کلیل';

  @override
  String get adminAiRemoveBody =>
      'پۆستە نوێیەکان وەرناگێڕدرێن و پێش‌پشکنین ناکرێن هەتا کلیلێک دووبارە پاشەکەوت دەکرێت.';

  @override
  String get adminAiRemoved => 'ڕێکخستنەکانی AI لابران.';

  @override
  String get onboardStepReport => 'هەنگاوی 1 · ڕاپۆرت';

  @override
  String get onboardStepMatch => 'هەنگاوی 2 · لێکچوون';

  @override
  String get onboardStepReturn => 'هەنگاوی 3 · گەڕاندنەوە';

  @override
  String get onboardHaveAccount => 'پێشتر هەژمارم هەیە';

  @override
  String get onboardSampleLost => 'ونبوو';

  @override
  String get onboardSampleFound => 'دۆزراوە';

  @override
  String get onboardSamplePlace => 'هەولێر · فامیلی مۆڵ';

  @override
  String get onboardSampleMinute => 'لە ١ خولەکدا بڵاوکرایەوە';

  @override
  String get onboardSampleMatch => '٩٢٪ لێکچوون';

  @override
  String get onboardSampleReviewed => 'پێداچوونەوە کراوە';

  @override
  String get onboardSampleAsk => 'لە پشتەوە چی هەڵکۆڵراوە؟';

  @override
  String get onboardSampleAnswer => 'پیتەکانی ناوم، ئ.س 😊';

  @override
  String get onboardSampleVerified => 'خاوەن دڵنیاکراوەتەوە';

  @override
  String get onboardSampleMeet => 'لە شوێنی گشتی یەکتر ببینن';

  @override
  String get chatConversationTitle => 'گفتوگۆ';

  @override
  String get chatNotFoundTitle => 'گفتوگۆکە نەدۆزرایەوە';

  @override
  String get chatNotFoundSubtitle =>
      'گفتوگۆیەک لە پۆستێک یان لە نامەکان بکەرەوە.';

  @override
  String get chatLoadingMessages => 'بارکردنی نامەکان...';

  @override
  String chatSayHello(String name) {
    return 'سڵاو لە $name بکە';
  }

  @override
  String get chatStartSubtitle => 'گفتوگۆکە بە ناردنی نامەیەک دەست پێبکە.';

  @override
  String chatAskAbout(String item) {
    return 'دەربارەی \"$item\" بپرسە یان ڕادەستکردنێکی سەلامەت ڕێک بخە.';
  }

  @override
  String get chatDirectMessageViewProfile => 'نامەی ڕاستەوخۆ · بینینی پڕۆفایل';

  @override
  String get chatDirectMessage => 'نامەی ڕاستەوخۆ';

  @override
  String chatAboutItem(String item) {
    return 'دەربارەی \"$item\"';
  }

  @override
  String get chatReopenPost => 'دووبارە کردنەوەی پۆستەکە';

  @override
  String get chatReopenSubtitle => 'دووبارە لە سەرەکی پیشانی بدە';

  @override
  String get chatReturnedSubtitle => 'شتەکە گەڕاوەتەوە بۆ خاوەنەکەی';

  @override
  String get chatViewPost => 'بینینی پۆستەکە';

  @override
  String get chatReportPost => 'ڕاپۆرتکردنی پۆستەکە';

  @override
  String get chatPostReported => 'سوپاس، پۆستەکە ڕاپۆرت کرا.';

  @override
  String get chatReopenTitle => 'ئەم پۆستە دووبارە بکرێتەوە؟';

  @override
  String get chatMarkReturnedTitle => 'وەک گەڕێنراوە نیشانە بکرێت؟';

  @override
  String chatReopenBody(String item) {
    return '\"$item\" دووبارە وەک پۆستێکی کراوە لە سەرەکی دەردەکەوێت.';
  }

  @override
  String chatMarkReturnedBody(String item) {
    return '\"$item\" لە سەرەکی دەردەچێت بەڵام لە گەڕان دەمێنێتەوە. هەموو کەس لەم گفتوگۆیەدا تێبینییەک وەردەگرێت.';
  }

  @override
  String get chatPostReopened => 'پۆستەکە دووبارە کرایەوە.';

  @override
  String get chatAutoReopened => 'ئەم پۆستەم دووبارە کردەوە.';

  @override
  String get chatAutoReturned => 'ئەم شتەم وەک گەڕێنراوە نیشانە کرد. سوپاس!';

  @override
  String get chatYourMessage => 'نامەکەت';

  @override
  String get chatMessage => 'نامە';

  @override
  String get chatReply => 'وەڵام';

  @override
  String get chatCopyText => 'کۆپیکردنی دەق';

  @override
  String get chatDeleteForEveryone => 'سڕینەوە بۆ هەمووان';

  @override
  String get chatDeleteTitle => 'ئەم نامەیە بسڕدرێتەوە؟';

  @override
  String get chatDeleteBody =>
      'بۆ هەموو کەس لەم گفتوگۆیەدا لادەبرێت. ئەمە ناگەڕێتەوە.';

  @override
  String get chatSendPhoto => 'ناردنی وێنە';

  @override
  String get chatWriteReplyHint => 'وەڵامێک بنووسە…';

  @override
  String get chatTypeMessageHint => 'نامەیەک بنووسە…';

  @override
  String get chatMicPermission =>
      'ڕێگە بە مایکرۆفۆن بدە بۆ ناردنی نامەی دەنگی.';

  @override
  String get chatSendMessage => 'ناردنی نامە';

  @override
  String get chatNotSent => 'نەنێردرا';

  @override
  String get chatYouSaid => 'تۆ وتت';

  @override
  String get chatTheySaid => 'ئەو وتی';

  @override
  String get chatCancelReply => 'پاشگەزبوونەوە لە وەڵام';

  @override
  String chatNewCount(int count) {
    return '$count نوێ';
  }

  @override
  String get chatLatest => 'نوێترین';

  @override
  String get chatSignInToMessage => 'تکایە بچۆرە ژوورەوە بۆ ناردنی نامە.';

  @override
  String get chatOwnPost => 'ئەمە پۆستی خۆتە.';

  @override
  String get chatOpenFailed => 'گفتوگۆکە نەکرایەوە.';

  @override
  String get chatLoadFailed => 'نامەکان بار نەکران.';

  @override
  String get chatNotSentFailure => 'نامەکە نەنێردرا.';

  @override
  String get chatNothingToRetry => 'هیچ شتێک نییە بۆ دووبارە هەوڵدان.';

  @override
  String get chatDeleteFailed => 'نامەکە نەسڕایەوە.';

  @override
  String get msgDeleted => 'ئەم نامەیە سڕاوەتەوە';

  @override
  String get msgVoiceMessage => 'نامەی دەنگی';

  @override
  String get msgPhoto => 'وێنە';

  @override
  String get msgNoMessagesYet => 'هێشتا هیچ نامەیەک نییە';

  @override
  String get msgNewConversation => 'گفتوگۆی نوێ';

  @override
  String get msgNewChat => 'چاتی نوێ';

  @override
  String msgUnreadConversations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count گفتوگۆی نەخوێندراوە',
      one: '١ گفتوگۆی نەخوێندراوە',
    );
    return '$_temp0';
  }

  @override
  String get msgSubtitle => 'بە سەلامەتی لەگەڵ خاوەن و دۆزەرەوەکان گفتوگۆ بکە';

  @override
  String get msgSearchHint => 'گەڕان لە گفتوگۆکان…';

  @override
  String get msgLoading => 'بارکردنی گفتوگۆکان...';

  @override
  String get msgNoConversations => 'هێشتا هیچ گفتوگۆیەک نییە';

  @override
  String get msgNoConversationsFound => 'هیچ گفتوگۆیەک نەدۆزرایەوە';

  @override
  String get msgEmptySubtitle =>
      'لە هەر پۆستێک پەیوەندی بە خاوەن یان دۆزەرەوە بکە، یان چاتێکی نوێ دەست پێبکە.';

  @override
  String get msgTryAnother => 'ناوێک یان وشەیەکی تر تاقی بکەرەوە.';

  @override
  String notifUnreadCount(int count) {
    return '$count نەخوێندراوە';
  }

  @override
  String get notifCaughtUp => 'هەموو شتێکت بینیوە';

  @override
  String get notifMarkAllRead => 'هەموو وەک خوێندراوە';

  @override
  String get notifLoading => 'بارکردنی ئاگادارکردنەوەکان...';

  @override
  String get notifEmptyTitle => 'هێشتا هیچ ئاگادارکردنەوەیەک نییە';

  @override
  String get notifEmptySubtitle =>
      'ئاگادارت دەکەینەوە کاتێک کەسێک نامەت بۆ دەنێرێت، پۆستەکەت چالاکی هەبوو، یان شتێک گەڕێنرایەوە.';

  @override
  String get notifUnreadSemantics => 'ئاگادارکردنەوەی نەخوێندراوە';

  @override
  String get notifLoadingPreferences => 'بارکردنی هەڵبژاردەکان...';

  @override
  String get notifStayConnected => 'لە پەیوەندیدا بمێنەوە';

  @override
  String get notifStayConnectedBody =>
      'هەڵبژێرە کام کات ئاگادارکردنەوە دروست دەکات. گۆڕانکارییەکان دەستبەجێ پاشەکەوت دەکرێن.';

  @override
  String get notifAll => 'هەموو ئاگادارکردنەوەکان';

  @override
  String get notifAllMuted => 'هەموو شتێک بێدەنگە';

  @override
  String get notifAllOff => 'هەموو شتێک بە یەکجار ناچالاک بکە';

  @override
  String get notifConversations => 'گفتوگۆکان';

  @override
  String get notifNewMessage => 'نامەی نوێ';

  @override
  String get notifNewMessageSubtitle =>
      'کاتێک کەسێک دەربارەی پۆستێک بۆت دەنووسێت';

  @override
  String get notifSmartMatching => 'هاوشێوەکردنی زیرەک';

  @override
  String get notifItemMatch => 'ئاگاداری هاوشێوەی شت';

  @override
  String get notifItemMatchSubtitle =>
      'کاتێک پۆستێکی نوێ لە شتێک دەچێت کە ون کردووتە یان دۆزیوتەتەوە';

  @override
  String get notifSmartBadge => 'زیرەک';

  @override
  String get notifPostUpdates => 'نوێکردنەوەی پۆست';

  @override
  String get notifPostUpdatesSubtitle =>
      'کاتێک شتێک کە دەربارەی گفتوگۆت کردووە گەڕێنرایەوە';

  @override
  String get notifFromFinder => 'لە Finder';

  @override
  String get notifTips => 'ئامۆژگاری و هەواڵ';

  @override
  String get notifTipsSubtitle =>
      'هەندێ جار نوێکردنەوەی بەرهەم. بە بنەڕەت ناچالاکە.';

  @override
  String get notifEmailCopies => 'کۆپی بە ئیمەیڵ';

  @override
  String get notifEmailCopiesSubtitle =>
      'ئاگادارکردنەوە گرنگەکان بە ئیمەیڵیش بنێرە';

  @override
  String get notifFooter =>
      'ئاگادارکردنەوەکان لەناو ئەپەکە دەگەن. ئاگادارکردنەوەی مۆبایل هەمان هەڵبژاردەکان پەیڕەو دەکات.';

  @override
  String get privacyTitle => 'تایبەتێتی و سەلامەتی';

  @override
  String get privacyBlockMemberTitle => 'بلۆککردنی ئەندامێک';

  @override
  String get privacyAdminCannotBlock => 'بەڕێوەبەرانی Finder بلۆک ناکرێن.';

  @override
  String get privacyDeleteAccountTitle => 'هەژمارەکەت بسڕدرێتەوە؟';

  @override
  String get privacyDeleteAccountBody =>
      'پۆست، گفتوگۆ، شتە پاشەکەوتکراوەکان و پڕۆفایلەکەت دەستبەجێ لادەبرێن. ئەمە ناگەڕێتەوە.';

  @override
  String get privacyTypeDeleteLabel => 'DELETE بنووسە بۆ دڵنیاکردنەوە';

  @override
  String get privacyPasswordLabel => 'وشەی نهێنیت';

  @override
  String get privacyTypeDeleteHint => 'DELETE';

  @override
  String get privacyPasswordHint => 'وشەی نهێنی';

  @override
  String get privacyDeleteAccount => 'سڕینەوەی هەژمار';

  @override
  String get privacyTypeDeleteError => 'DELETE بنووسە بۆ دڵنیاکردنەوە.';

  @override
  String get privacyEnterPassword => 'تکایە وشەی نهێنیت بنووسە.';

  @override
  String get privacyAccountDeleted => 'هەژمارەکەت سڕایەوە.';

  @override
  String get privacyLoadingSettings => 'بارکردنی ڕێکخستنەکان...';

  @override
  String get privacyHeadline => 'زانیارییەکانت، کۆنترۆڵی تۆ';

  @override
  String get privacyIntro =>
      'بڕیار بدە ئەندامانی تر چی ببینن و کێ بتوانێت پەیوەندیت پێوە بکات. گۆڕانکارییەکان دەستبەجێ جێبەجێ دەبن.';

  @override
  String get privacyVisibility => 'دەرکەوتن';

  @override
  String get privacyShowProfile => 'پڕۆفایلم پیشان بدە';

  @override
  String get privacyShowProfileSubtitle =>
      'ناچالاک تەنها ناو و وێنەکەت لەسەر پۆستەکان پیشان دەدات؛ پیشە، مۆبایل و شوێن شاراوە دەمێننەوە.';

  @override
  String get privacyAllowMessages => 'ڕێگە بە نامەی ڕاستەوخۆ بدە';

  @override
  String get privacyAllowMessagesSubtitle =>
      'ڕێگە بە ئەندامان بدە گفتوگۆ لەگەڵت دەست پێبکەن. گفتوگۆ ئێستاکان کراوە دەمێننەوە.';

  @override
  String get privacyShowCity => 'شارەکەم پیشان بدە';

  @override
  String get privacyShowCitySubtitle =>
      'ناونیشانی پڕۆفایلەکەت لەگەڵ ئەندامانی تر هاوبەش دەکات.';

  @override
  String get privacyHidePhone => 'ژمارەی مۆبایلم بشارەوە';

  @override
  String get privacyHidePhoneSubtitle =>
      'کاتێک چالاکە، ئەندامان تەنها لە ڕێگەی گفتوگۆی ناو ئەپ دەتوانن پەیوەندیت پێوە بکەن.';

  @override
  String get privacyBlockedMembersLabel => 'ئەندامە بلۆککراوەکان';

  @override
  String get privacyBlockedMembers => 'ئەندامە بلۆککراوەکان';

  @override
  String get privacyBlockedMembersBody =>
      'ئەندامە بلۆککراوەکان ناتوانن پۆستەکانت ببینن یان نامەت بۆ بنێرن، و تۆش هی ئەوان نابینیت.';

  @override
  String privacyBlockedTotal(int count) {
    return '$count بە گشتی';
  }

  @override
  String get privacyLoadingBlocked => 'بارکردنی ئەندامە بلۆککراوەکان...';

  @override
  String get privacyNoBlocked => 'هیچ ئەندامێکی بلۆککراو نییە';

  @override
  String get privacyNoBlockedSubtitle =>
      'ئەو ئەندامانەی بلۆکیان دەکەیت لێرە دەردەکەون.';

  @override
  String get privacyBlockAnother => 'بلۆککردنی ئەندامێکی تر';

  @override
  String get privacyDeleteAccountSubtitle =>
      'هەژمار، پۆست و گفتوگۆکانت بە یەکجاری لابەرە.';

  @override
  String blockUserLabel(String name) {
    return 'بلۆککردنی $name';
  }

  @override
  String blockUserTitle(String name) {
    return '$name بلۆک بکرێت؟';
  }

  @override
  String blockUserDone(String name) {
    return '$name بلۆک کرا.';
  }

  @override
  String blockUnblocked(String name) {
    return '$name دەتوانێت دووبارە پەیوەندیت پێوە بکات.';
  }

  @override
  String get blockChatConfirmBody =>
      'ئەم گفتوگۆیە نامێنێت و هیچکامتان ناتوانن نامە بۆ یەکتر بنێرن. هەر کاتێک بتەوێت لە تایبەتێتی و سەلامەتی بیگەڕێنەوە.';

  @override
  String get blockProfileSubtitle =>
      'هیچکامتان ناتوانن یەکتر ببینن یان نامە بنێرن';

  @override
  String get blockProfileConfirmBody =>
      'هەر کاتێک بتەوێت لە تایبەتێتی و سەلامەتی بیگەڕێنەوە.';

  @override
  String get blockStaffSubtitle => 'هەژماری ستاف بلۆک ناکرێت';

  @override
  String get blockMemberFallback => 'ئەندام';

  @override
  String get profileFinderMember => 'ئەندامی Finder';

  @override
  String get profileChangePhoto => 'گۆڕینی وێنە';

  @override
  String get profileStatActive => 'چالاک';

  @override
  String get profileStatResolved => 'گەڕێنراوە';

  @override
  String get profileStatSaved => 'پاشەکەوتکراو';

  @override
  String profileShareLine(String id) {
    return 'لە Finder بمدۆزەرەوە · ناسنامەی ئەندام $id';
  }

  @override
  String get profileCopied => 'وردەکاری پڕۆفایل کۆپی کرا.';

  @override
  String get profileEdit => 'دەستکاری پڕۆفایل';

  @override
  String get profileCopyDetails => 'کۆپیکردنی وردەکاری پڕۆفایل';

  @override
  String get profileAboutTitle => 'دەربارەی Finder';

  @override
  String get profileAboutVersion => 'وەشانی 1.0 · دیزاینی Beacon';

  @override
  String get profileAboutBody =>
      'Finder یارمەتی کۆمەڵگە دەدات شتە ونبووەکان بگەڕێنەوە بۆ خاوەنەکانیان. ئەوەی ون کردووتە یان دۆزیوتەتەوە ڕاپۆرت بکە، بە سەلامەتی لەناو ئەپەکە گفتوگۆ بکە و شتەکان وەک گەڕێنراوە نیشانە بکە کاتێک دەگەڕێنەوە ماڵەوە.';

  @override
  String get profileSafetyFirst => 'سەلامەتی لە پێشەوە';

  @override
  String get profileSafetyBody =>
      'لە شوێنی گشتی یەکتر ببینن، هەرگیز پێش وەرگرتنی شتەکەت پاداشت مەدە، و گفتوگۆی ناو ئەپ بەکاربهێنە تا بتوانیت بلۆک و ڕاپۆرت بکەیت.';

  @override
  String get profileAccount => 'هەژمار';

  @override
  String get profileMyPosts => 'پۆستەکانم';

  @override
  String get profileMyPostsSubtitle => 'ئەوەی ڕاپۆرتت کردووە بەڕێوەی ببە';

  @override
  String get profileSavedItems => 'شتە پاشەکەوتکراوەکان';

  @override
  String get profileSavedItemsSubtitle => 'ئەو شتانەی چاودێرییان دەکەیت';

  @override
  String get profileAdminConsole => 'پانێڵی بەڕێوەبەر';

  @override
  String get profileAdminConsoleSubtitle =>
      'بەکارهێنەران، پۆستەکان، ڕاپۆرتەکان و پشتڕاستکردنەوە';

  @override
  String get profilePreferences => 'هەڵبژاردەکان';

  @override
  String get profileDarkMode => 'دۆخی تاریک';

  @override
  String get profileNightTheme => 'ڕووکاری شەو';

  @override
  String get profileDayTheme => 'ڕووکاری ڕۆژ';

  @override
  String get profileSupportLegal => 'پشتگیری و یاسایی';

  @override
  String get profileTerms => 'مەرجەکانی خزمەتگوزاری';

  @override
  String get profilePrivacyPolicy => 'سیاسەتی تایبەتێتی';

  @override
  String get profileLogOutTitle => 'دەچیتە دەرەوە؟';

  @override
  String get profileLogOutBody =>
      'هەر کاتێک بتەوێت دەتوانیت دووبارە بچیتە ژوورەوە.';

  @override
  String get profileDiscardTitle => 'گۆڕانکارییەکان فڕێبدرێن؟';

  @override
  String get profileDiscardBody => 'دەستکارییەکانت پاشەکەوت نەکراون.';

  @override
  String get profileKeepEditing => 'بەردەوامبوون لە دەستکاری';

  @override
  String get profileLoading => 'بارکردنی پڕۆفایلەکەت...';

  @override
  String get profileFullName => 'ناوی تەواو';

  @override
  String get profileFullNameHint => 'ناوت';

  @override
  String get profileNickname => 'نازناو';

  @override
  String get profileNicknameHint => 'هاوڕێکانت بە چی دەتناسن';

  @override
  String get profilePhone => 'مۆبایل';

  @override
  String get profilePhoneHint => '+964 750 000 0000';

  @override
  String get profileCity => 'شار';

  @override
  String get profileCityHint => 'شار، وڵات';

  @override
  String get profileJob => 'پیشە / کار';

  @override
  String get profileJobHint => 'کارت چییە؟';

  @override
  String get profileSignInEmailLabel => 'ئیمەیڵی چوونەژوورەوە';

  @override
  String get profileEmailNote =>
      'ئیمەیڵەکەت بۆ چوونەژوورەوە بەکاردێت و لێرە ناگۆڕدرێت.';

  @override
  String get profileSaveChanges => 'پاشەکەوتکردنی گۆڕانکارییەکان';

  @override
  String get profileEnterName => 'تکایە ناوت بنووسە.';

  @override
  String get profileUpdated => 'پڕۆفایل نوێکرایەوە.';

  @override
  String get profileLoadingOther => 'بارکردنی پڕۆفایل…';

  @override
  String get profileUnavailableTitle => 'ئەم ئەندامە بەردەست نییە';

  @override
  String get profileUnavailableSubtitle =>
      'لەوانەیە هەژمارەکە لابرابێت، یان ناتوانن یەکتر ببینن.';

  @override
  String get profileMore => 'زیاتر';

  @override
  String profileMemberSince(String time) {
    return 'ئەندامە لە $time';
  }

  @override
  String profilePostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پۆست',
      one: '١ پۆست',
    );
    return '$_temp0';
  }

  @override
  String profileMessageFirstName(String name) {
    return 'نامە بۆ $name';
  }

  @override
  String profileItemsReported(String name) {
    return 'ئەو شتانەی $name ڕاپۆرتی کردوون';
  }

  @override
  String get profileNoPosts => 'هێشتا هیچ پۆستێک نییە';

  @override
  String get profileSendMessage => 'ناردنی نامە';

  @override
  String get profileFinderAdmin => 'بەڕێوەبەری Finder';

  @override
  String get profileAdminBadge => 'بەڕێوەبەر';

  @override
  String get profileFindMember => 'دۆزینەوەی ئەندامێک';

  @override
  String get profileSearchMemberHint => 'گەڕان بە ناو یان ئیمەیڵ…';

  @override
  String get profileSelect => 'هەڵبژاردن';

  @override
  String get profileSearchFailed => 'گەڕان سەرکەوتوو نەبوو.';

  @override
  String get profileSearchSubtitle =>
      'لانیکەم دوو پیت لە ناو یان ئیمەیڵ بنووسە.';

  @override
  String get profileSearchBlockedNote =>
      'ئەو ئەندامانەی بلۆکت کردوون لێرە دەرناکەون.';

  @override
  String profileSearchNoMatch(String query) {
    return 'هیچ ئەندامێک لەگەڵ \"$query\" ناگونجێت.';
  }

  @override
  String profileUserRowSemantics(String name, String action) {
    return '$name، $action';
  }

  @override
  String get verifyVerifiedIdentity => 'ناسنامەی پشتڕاستکراو';

  @override
  String get verifyGetVerified => 'پشتڕاستکردنەوە';

  @override
  String get verifyBadgeVisible => 'نیشانەکەت بۆ کۆمەڵگە دەبینرێت';

  @override
  String get verifyBuildTrust => 'بە نیشانەی پشتڕاستکراو متمانە دروست بکە';

  @override
  String get verifyPassport => 'پاسپۆرت';

  @override
  String get verifyIdentityCard => 'کارتی ناسنامە';

  @override
  String get verifyDriversLicense => 'مۆڵەتی شۆفێری';

  @override
  String get verifyTitle => 'پشتڕاستکردنەوەی ناسنامە';

  @override
  String get verifyApprovedSubtitle => 'ناسنامەکەت پشتڕاستکراوەتەوە';

  @override
  String get verifyUnderReview => 'لە ژێر پێداچوونەوەدایە';

  @override
  String get verifyNeedsNewPhotos => 'پێویستی بە وێنەی نوێیە';

  @override
  String verifyStepsComplete(int count) {
    return '$count لە ٣ هەنگاو تەواو بووە';
  }

  @override
  String get verifyCheckingStatus => 'پشکنینی دۆخەکەت...';

  @override
  String get verifyVerifiedMember => 'ئەندامی پشتڕاستکراو';

  @override
  String get verifyReviewedByPerson =>
      'لەلایەن کەسێکەوە پێداچوونەوەی بۆ دەکرێت';

  @override
  String get verifyThanks =>
      'سوپاس بۆ یارمەتیدانت لە متمانەپێکراو ڕاگرتنی Finder.';

  @override
  String get verifyHeroHeadline =>
      'هەژمارە پشتڕاستکراوەکان یارمەتی دروستکردنی کۆمەڵگەیەکی سەلامەتتر دەدەن بۆ هەمووان.';

  @override
  String get verifyApprovedBody =>
      'پۆست و نامەکانت ئێستا نیشانەی پشتڕاستکراو پیشان دەدەن.';

  @override
  String get verifyHeroBody =>
      'وێنەکانت بە تایبەتی هەڵدەگیرێن و تەنها ئەو ئەندامەی تیمی Finder دەیانبینێت کە پشکنینیان دەکات. پێداچوونەوە زۆربەی جار ڕۆژێک دەخایەنێت.';

  @override
  String get verifyHowItWorks => 'چۆن کاردەکات';

  @override
  String get verifyStep1Title => 'وێنەی ناسنامەکەت بگرە';

  @override
  String get verifyStep1Body =>
      'کامێرا یان گەلەری. هەموو گۆشەکان لەناو چوارچێوە، بەبێ بریسکە.';

  @override
  String get verifyStep2Title => 'سێڵفییەکی ڕاستەوخۆ بگرە';

  @override
  String get verifyStep2Body => 'تەنها کامێرای پێشەوە، تا بزانین بەڕاستی تۆیت.';

  @override
  String get verifyStep3Title => 'کەسێک پێداچوونەوەی بۆ دەکات';

  @override
  String get verifyStep3Body =>
      'ڕووخساری ناو ناسنامەکە لەگەڵ سێڵفییەکەت و ناوی هەژمارەکەت بەراورد دەکەن. لە هەردوو حاڵەتدا ئاگادارکردنەوە وەردەگریت.';

  @override
  String get verifyIdentityVerified => 'ناسنامە پشتڕاستکرایەوە';

  @override
  String get verifyPending => 'پشتڕاستکردنەوە چاوەڕوانە';

  @override
  String get verifyPendingBadge => 'چاوەڕوان';

  @override
  String verifyVerifiedWith(String doc) {
    return 'بە $docەکەت پشتڕاستکراوەتەوە.';
  }

  @override
  String verifyReceived(String doc, String time) {
    return '$docەکەتمان $time وەرگرت. ئەندامێکی تیمی Finder پێداچوونەوەی بۆ دەکات؛ کە تەواو بوو ئاگادارکردنەوە وەردەگریت.';
  }

  @override
  String get verifyNotApproved => 'هێشتا پەسەند نەکراوە';

  @override
  String get verifyNeedsPhotosBadge => 'پێویستی بە وێنەیە';

  @override
  String get verifyPhotosRejected => 'وێنەکان پشتڕاست نەکرانەوە.';

  @override
  String verifyReviewedAt(String time) {
    return 'پێداچوونەوە کرا $time';
  }

  @override
  String get verifySubmitNewPhotos => 'ناردنی وێنەی نوێ';

  @override
  String verifyDocTypeLower(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'id_card': 'کارتی ناسنامە',
      'drivers_license': 'مۆڵەتی شۆفێری',
      'passport': 'پاسپۆرت',
      'other': 'بەڵگەنامە',
    });
    return '$_temp0';
  }

  @override
  String get verifyDocSelection => 'هەڵبژاردنی بەڵگەنامە';

  @override
  String get verifyDocSelectionSubtitle =>
      'ئەو ناسنامەیە هەڵبژێرە کە دەتەوێت بۆ پشتڕاستکردنەوە بەکاری بهێنیت';

  @override
  String get verifyDocPhotos => 'وێنەکانی بەڵگەنامە';

  @override
  String get verifyBothSides => 'هەردوو ڕووی ناسنامەکەت، کامێرا یان گەلەری';

  @override
  String get verifyPhotoPage => 'لاپەڕەی وێنە، کامێرا یان گەلەری';

  @override
  String get verifyFrontOfId => 'ڕووی پێشەوەی ناسنامە';

  @override
  String get verifyPhotoPageLabel => 'لاپەڕەی وێنە';

  @override
  String get verifyBackOfId => 'ڕووی پشتەوەی ناسنامە';

  @override
  String get verifyLiveSelfie => 'سێڵفی ڕاستەوخۆ';

  @override
  String get verifyLiveSelfieSubtitle =>
      'ئێستا بە کامێرای پێشەوە دەگیرێت؛ وێنەی گەلەری وەرناگیرێت.';

  @override
  String get verifyRetakeSelfie => 'دووبارە گرتنی سێڵفی';

  @override
  String get verifyTakeSelfie => 'سێڵفییەک بگرە';

  @override
  String get verifyTip =>
      'شوێنێکی ڕووناک بەکاربهێنە، هەموو بەڵگەنامەکە لەناو چوارچێوە ڕابگرە و بۆ سێڵفی کڵاو یان چاویلکەی خۆر لابە.';

  @override
  String get verifyFrontOfYourId => 'ڕووی پێشەوەی ناسنامەکەت';

  @override
  String get verifyBackOfYourId => 'ڕووی پشتەوەی ناسنامەکەت';

  @override
  String get verifyStoredPrivately =>
      'بە تایبەتی هەڵدەگیرێت، تەنها پێداچوونەوەکار دەیبینێت.';

  @override
  String verifyAddDocumentFirst(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تکایە سەرەتا وێنەکانی بەڵگەنامەکەت زیاد بکە.',
      one: 'تکایە سەرەتا وێنەی بەڵگەنامەکەت زیاد بکە.',
    );
    return '$_temp0';
  }

  @override
  String get verifyTakeSelfieFirst => 'تکایە سێڵفییەک بگرە بۆ تەواوکردن.';

  @override
  String get verifySubmitted => 'نێردرا. دوای پێداچوونەوە ئاگادار دەکرێیتەوە.';

  @override
  String verifyStepLabel(int index) {
    return 'هەنگاوی $index';
  }

  @override
  String get verifySubmitForReview => 'ناردن بۆ پێداچوونەوە';

  @override
  String get verifyConfirmOwnership =>
      'بە ناردن دڵنیا دەکەیتەوە کە بەڵگەنامەکان هی تۆن.';

  @override
  String get verifyAddToContinue =>
      'وێنەکانی بەڵگەنامەکەت و سێڵفییەک زیاد بکە بۆ بەردەوامبوون.';

  @override
  String verifyUploadAddedSemantics(String label) {
    return '$label زیادکرا، دەست لێبدە بۆ گۆڕین';
  }

  @override
  String verifyUploadAddSemantics(String label) {
    return 'زیادکردنی $label';
  }

  @override
  String verifyUploadAdded(String label) {
    return '$label زیادکرا';
  }

  @override
  String get verifyTapToReplace => 'دەست لێبدە بۆ گۆڕین';

  @override
  String get verifyCameraOrGallery => 'کامێرا یان گەلەری';

  @override
  String get helpTitle => 'یارمەتی و پشتگیری';

  @override
  String get helpHeroPrefix => 'چۆن دەتوانین ئەمڕۆ ';

  @override
  String get helpHeroAccent => 'پشتگیریت';

  @override
  String get helpHeroSuffix => ' بکەین؟';

  @override
  String get helpIntro =>
      'جا گەنجینەیەکت ون کردبێت یان یادگارییەکت دۆزیبێتەوە، وەڵامەکانی خوارەوە زۆربەی پرسیارەکان دەگرنەوە.';

  @override
  String get helpSearchHint => 'گەڕان لە پرسیارەکان (نموونە: \'وشەی نهێنی\')';

  @override
  String helpNoAnswers(String query) {
    return 'هیچ وەڵامێک لەگەڵ \"$query\" ناگونجێت. وشەیەکی تر تاقی بکەرەوە یان لە خوارەوە پەیوەندیمان پێوە بکە.';
  }

  @override
  String helpAnswersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وەڵام',
      one: '١ وەڵام',
    );
    return '$_temp0';
  }

  @override
  String get helpBrowseByTopic => 'گەڕان بەپێی بابەت';

  @override
  String get helpStillQuestions => 'هێشتا پرسیارت هەیە؟';

  @override
  String get helpEmailReply =>
      'ئیمەیڵمان بۆ بنێرە و لە ماوەی ڕۆژێکی کاردا وەڵام دەدەینەوە.';

  @override
  String get helpEmailSupport => 'ئیمەیڵ بۆ پشتگیری';

  @override
  String get helpEmailSubject => 'داواکاری پشتگیری Finder';

  @override
  String get helpEmailBody => 'سڵاو تیمی Finder،\n\n';

  @override
  String get helpCopyAddress => 'کۆپیکردنی ناونیشانی پشتگیری';

  @override
  String helpAddressCopied(String email) {
    return '$email کۆپی کرا.';
  }

  @override
  String get helpTechnicalFeedback => 'فیدباکی تەکنیکی';

  @override
  String get helpFoundGlitch => 'کێشەیەکت دۆزیوەتەوە؟';

  @override
  String get helpGlitchBody =>
      'پێمان بڵێ چیت کرد، چیت چاوەڕوان دەکرد و لەبری ئەوە چی ڕوویدا. سکرینشۆت زۆر یارمەتیدەرە.';

  @override
  String get helpReportIssue => 'ڕاپۆرتکردنی کێشەیەکی تەکنیکی';

  @override
  String get helpBugSubject => 'ڕاپۆرتی کێشەی Finder';

  @override
  String get helpBugBody =>
      'چیم کرد:\n\nچیم چاوەڕوان دەکرد:\n\nچی ڕوویدا:\n\nئامێر / پلاتفۆرم:\n';

  @override
  String helpNoEmailApp(String email) {
    return 'هیچ ئەپێکی ئیمەیڵ نەدۆزرایەوە. $email کۆپی کرا.';
  }

  @override
  String get helpGotIt => 'تێگەیشتم';

  @override
  String get helpTopicAccountSubtitle => 'پڕۆفایل، پشتڕاستکردنەوە و وشەی نهێنی';

  @override
  String get helpFaqChangeNameQ => 'چۆن ناو یان وێنەکەم بگۆڕم؟';

  @override
  String get helpFaqChangeNameA =>
      'پڕۆفایل بکەرەوە، دەست لە \"دەستکاری پڕۆفایل\" بدە، خانەکان بگۆڕە و پاشەکەوتی بکە. وێنە نوێیەکە لەسەر هەموو پۆست و نامەکانت دەردەکەوێت.';

  @override
  String get helpFaqForgotPasswordQ => 'وشەی نهێنیم لەبیرچووە.';

  @override
  String get helpFaqForgotPasswordA =>
      'لە شاشەی چوونەژوورەوە دەست لە \"وشەی نهێنیت لەبیرچووە؟\" بدە. کۆدێکی نوێکردنەوە بۆ ئیمەیڵەکەت دەنێردرێت؛ لەگەڵ وشەی نهێنی نوێت بینووسە.';

  @override
  String get helpFaqVerifiedBadgeQ => 'نیشانەی پشتڕاستکراو واتە چی؟';

  @override
  String get helpFaqVerifiedBadgeA =>
      'ئەندامی پشتڕاستکراو ناسنامەکەی بە بەڵگەنامەی ناسنامە و سێڵفی دڵنیا کردووەتەوە. لە پڕۆفایل ← پشتڕاستکردنەوە دەست پێبکە. پێداچوونەوە نزیکەی ڕۆژێک دەخایەنێت.';

  @override
  String get helpFaqDeleteAccountQ => 'چۆن هەژمارەکەم بسڕمەوە؟';

  @override
  String get helpFaqDeleteAccountA =>
      'بڕۆ بۆ تایبەتێتی و سەلامەتی ← سڕینەوەی هەژمار. پۆست، گفتوگۆ و پڕۆفایلەکەت لە ماوەی ٣٠ ڕۆژدا لادەبەین.';

  @override
  String get helpTopicSafety => 'سەلامەتی';

  @override
  String get helpTopicSafetySubtitle => 'چاوپێکەوتن و بلۆککردن';

  @override
  String get helpFaqMeetQ => 'لە کوێ یەکتر ببینین بۆ ڕادەستکردنی شتێک؟';

  @override
  String get helpFaqMeetA =>
      'شوێنێکی گشتی قەرەباڵغ لە ڕۆژدا هەڵبژێرە، وەک کافێ، بنکەی پۆلیس یان مۆڵ. ئەگەر دەتوانیت هاوڕێیەک لەگەڵ خۆت ببە.';

  @override
  String get helpFaqBotheringQ => 'کەسێک بێزارم دەکات.';

  @override
  String get helpFaqBotheringA =>
      'گفتوگۆکە بکەرەوە، دەست لە مینیوی گۆشەی سەرەوە بدە و \"بلۆککردن\" هەڵبژێرە. چیتر ناتوانێت پۆستەکانت ببینێت یان نامەت بۆ بنێرێت. ئەگەر پۆستەکە ساختە دیار بوو ڕاپۆرتیشی بکە.';

  @override
  String get helpFaqRewardQ => 'پێش وەرگرتنەوەی شتەکەم پاداشت بدەم؟';

  @override
  String get helpFaqRewardA =>
      'نەخێر. هەرگیز پێش ئەوەی شتەکە لە دەستت بێت پارە مەنێرە. پاداشت ئارەزوومەندانەیە و لە کاتی ڕادەستکردن دەدرێت.';

  @override
  String get helpTopicPosting => 'بڵاوکردنەوەی شتەکان';

  @override
  String get helpTopicPostingSubtitle => 'نووسینی ڕاپۆرت کە هاوشێوە دەدۆزێتەوە';

  @override
  String get helpFaqGoodPostQ => 'چی پۆستێک باش دەکات؟';

  @override
  String get helpFaqGoodPostA =>
      'وێنەیەکی ڕوون، شوێنێکی ورد، ڕێکەوت و کات، و وردەکاری تایبەت (خەت، ستیکەر، نەخش). ژمارە زنجیرەییەکان بە نهێنی بهێڵەوە تا کەسێک خاوەندارێتی دەسەلمێنێت.';

  @override
  String get helpFaqMarkReturnedQ => 'چۆن شتێک وەک گەڕێنراوە نیشانە بکەم؟';

  @override
  String get helpFaqMarkReturnedA =>
      'پۆستەکە بکەرەوە یان بڕۆ بۆ پۆستەکانم و \"وەک گەڕێنراوە نیشانە بکە\" هەڵبژێرە. هەموو ئەوانەی دەربارەی گفتوگۆیان لەگەڵت کردووە ئاگادارکردنەوە وەردەگرن.';

  @override
  String get helpFaqEditPostQ => 'دەتوانم پۆستێک دەستکاری بکەم یان بیسڕمەوە؟';

  @override
  String get helpFaqEditPostA =>
      'بەڵێ. لە پۆستەکانم دەست لە دەستکاری بدە، یان پۆستەکە بکەرەوە و مینیوی گۆشەی سەرەوە بەکاربهێنە بۆ دەستکاری، گەڕاندنەوە یان سڕینەوە.';

  @override
  String get helpTopicMessaging => 'نامەناردن';

  @override
  String get helpTopicMessagingSubtitle =>
      'پەیوەندیکردن بە خاوەن و دۆزەرەوەکان';

  @override
  String get helpFaqContactOwnerQ => 'چۆن پەیوەندی بە خاوەنی پۆستێک بکەم؟';

  @override
  String get helpFaqContactOwnerA =>
      'پۆستەکە بکەرەوە و دەست لە \"گفتوگۆ لەگەڵ خاوەن\" (یان \"من ئەم شتەم دۆزیوەتەوە\") بدە. گفتوگۆیەک دەربارەی ئەو شتە لە نامەکان دەکرێتەوە.';

  @override
  String get helpFaqSendPhotosQ => 'دەتوانم وێنە بنێرم؟';

  @override
  String get helpFaqSendPhotosA =>
      'بەڵێ. لە گفتوگۆدا دەست لە دوگمەی وێنە لە تەنیشت خانەی نامە بدە بۆ ناردنی وێنەیەک وەک بەڵگە.';

  @override
  String get helpFaqCantMessageQ => 'بۆچی ناتوانم نامە بۆ کەسێک بنێرم؟';

  @override
  String get helpFaqCantMessageA =>
      'یان یەکێکتان ئەوی تری بلۆک کردووە، یان ئەو نامەی ڕاستەوخۆی لە ڕێکخستنەکانی تایبەتێتی ناچالاک کردووە.';

  @override
  String helpComingSoon(String feature) {
    return '$feature بەم زووانە دێت.';
  }

  @override
  String get helpThisFeature => 'ئەم تایبەتمەندییە';

  @override
  String get voicePlay => 'لێدانی نامەی دەنگی';

  @override
  String get voicePause => 'وەستاندنی نامەی دەنگی';

  @override
  String get voiceHoldHint => 'مایکرۆفۆنەکە ڕابگرە بۆ تۆمارکردنی نامەی دەنگی.';

  @override
  String get voiceHoldTap => 'ڕایبگرە بۆ تۆمارکردنی نامەی دەنگی.';

  @override
  String get voiceSlideToCancel => 'ڕایکێشە بۆ پاشگەزبوونەوە';

  @override
  String get voiceCancelRecording => 'پاشگەزبوونەوە لە تۆمارکردن';

  @override
  String get photoAddTitle => 'زیادکردنی وێنە';

  @override
  String get photoTakePhoto => 'وێنە بگرە';

  @override
  String get photoOpenCamera => 'کامێرا بکەرەوە';

  @override
  String get photoChooseGallery => 'هەڵبژاردن لە گەلەری';

  @override
  String get photoPickExisting => 'وێنەیەکی ئامادە هەڵبژێرە';

  @override
  String get photoOpenFailed => 'ئەم وێنەیە نەکرایەوە.';

  @override
  String get photoPrepareFailed => 'وێنەکە ئامادە نەکرا. دووبارە هەوڵ بدەرەوە.';

  @override
  String get photoAdjustAvatar => 'وێنەکەت ڕێک بخە';

  @override
  String get photoAdjustCover => 'کەڤەرەکەت ڕێک بخە';

  @override
  String get photoUse => 'بەکارهێنانی وێنە';

  @override
  String get photoGestureHint =>
      'پەنجە بکەرەوە بۆ گەورەکردن · ڕایکێشە بۆ جوڵاندن · دوو جار دەست لێبدە بۆ گەورەکردن';

  @override
  String get photoRotate => 'سووڕاندن';

  @override
  String get photoReset => 'ڕێکخستنەوە';

  @override
  String get photoRemoveCover => 'لابردنی وێنەی کەڤەر';

  @override
  String get photoAddCover => 'زیادکردنی وێنەی کەڤەر';

  @override
  String get photoChangeCover => 'گۆڕینی وێنەی کەڤەر';

  @override
  String get photoChangeProfile => 'گۆڕینی وێنەی پڕۆفایل';

  @override
  String get photoAddProfile => 'زیادکردنی وێنەی پڕۆفایل';

  @override
  String get photoProfileTitle => 'وێنەی پڕۆفایل';

  @override
  String get photoCoverTitle => 'وێنەی کەڤەر';

  @override
  String photoUploadFailed(String detail) {
    return 'بەرزکردنەوەی وێنە سەرکەوتوو نەبوو. $detail';
  }

  @override
  String get photoFileEmpty => 'فایلە هەڵبژێردراوەکە بەتاڵە.';

  @override
  String get photoTooLarge =>
      'تکایە وێنەیەک هەڵبژێرە کە لە ٨ مێگابایت کەمتر بێت.';

  @override
  String get photoNoFileId => 'ڕاژەکار ناسنامەی فایلی نەگەڕاندەوە.';

  @override
  String get photoNoUrl => 'ڕاژەکار لینکی وێنەی نەگەڕاندەوە.';

  @override
  String get photoCameraDenied =>
      'دەستگەیشتن بە کامێرا ڕەتکرایەوە. لە ڕێکخستنەکانی مۆبایلەکەت ڕێگە بدە یان وێنەیەک لە گەلەری هەڵبژێرە.';

  @override
  String get photoAccessDenied =>
      'دەستگەیشتن بە وێنەکان ڕەتکرایەوە. لە ڕێکخستنەکانی مۆبایلەکەت ڕێگە بدە و دووبارە هەوڵ بدەرەوە.';

  @override
  String get photoCameraOpenFailed => 'کامێرا نەکرایەوە.';

  @override
  String get photoPickerOpenFailed => 'هەڵبژێری وێنە نەکرایەوە.';

  @override
  String get pushMessagesChannelDesc => 'نامەی نوێی چات';

  @override
  String get pushUpdatesChannel => 'نوێکردنەوەکان';

  @override
  String get pushUpdatesChannelDesc => 'نوێکردنەوەی پۆست و هەژمار';

  @override
  String get chatTyping => 'دەنووسێت…';

  @override
  String get chatOnline => 'ئۆنلاینە';

  @override
  String chatLastSeen(String when) {
    return 'دوایین جار $when';
  }

  @override
  String get chatYouPrefix => 'تۆ: ';

  @override
  String get chatAddCaption => 'تێبینییەک زیاد بکە…';

  @override
  String get chatLoadingOlder => 'بارکردنی نامە کۆنەکان…';

  @override
  String get voiceTapToLock =>
      'دەست لێبدە بۆ تۆمارکردنی بێ‌دەست، ڕایبگرە بۆ تۆمارکردن';

  @override
  String get voiceSlideUpToLock => 'بۆ سەرەوە ڕایکێشە بۆ قوفڵکردن';

  @override
  String get voiceSend => 'ناردنی نامەی دەنگی';

  @override
  String get voiceDiscard => 'فڕێدانی تۆمارەکە';

  @override
  String voiceSpeed(String speed) {
    return '$speed×';
  }

  @override
  String get chatForwarded => 'فۆروارد کراوە';

  @override
  String get chatDeleteForMe => 'سڕینەوە بۆ خۆم';

  @override
  String get chatForward => 'فۆرواردکردن';

  @override
  String get chatForwardTo => 'فۆرواردکردن بۆ';

  @override
  String get chatForwardSent => 'فۆروارد کرا.';

  @override
  String chatUnreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نامەی نەخوێندراوە',
      one: '١ نامەی نەخوێندراوە',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenPhoto => 'کردنەوەی وێنە';

  @override
  String get welcomeTitle => 'بەخێربێیت بۆ Finder';

  @override
  String get welcomeSubtitle =>
      'ونبوو و دۆزراوەکانی شارەکەت: کەسانێک پێداچوونەوەی بۆ دەکەن، بۆت لێک دەدرێت، بە زمانی خۆت.';

  @override
  String get welcomeStep1Title => 'بڵاوی بکەرەوە';

  @override
  String get welcomeStep1Body =>
      'ونبوو یان دۆزراوە، وێنەیەک و شوێنەکە زیاد بکە. چاودێرێک پێش بڵاوبوونەوە پشکنینی دەکات.';

  @override
  String get welcomeStep2Title => 'لێکچوون وەربگرە';

  @override
  String get welcomeStep2Body =>
      'ئاگادارت دەکەینەوە کاتێک پۆستێک لەگەڵ هی تۆ لێک دەچێت، و هەموو پۆستەکان بە زمانی ئەپەکەت پیشان دەدەین.';

  @override
  String get welcomeStep3Title => 'بە سەلامەتی بیگەڕێنەوە';

  @override
  String get welcomeStep3Body =>
      'لێرە گفتوگۆ بکە، پرسیاری وردەکارییەک بکە کە تەنها خاوەنەکە دەیزانێت، و لە شوێنێکی گشتی یەکتر ببینن.';

  @override
  String get welcomeHelpHint =>
      'ڕێنمایی هەنگاو بە هەنگاو، لەوانە چۆن دڵنیا بیتەوە کە لەگەڵ خاوەنە ڕاستەقینەکە قسە دەکەیت، لە پرۆفایل ← یارمەتی و پشتیوانی دەدۆزیتەوە.';

  @override
  String get welcomeGotIt => 'تێگەیشتم';

  @override
  String get welcomeOpenHelp => 'ڕێنماییەکان ببینە';

  @override
  String get helpTileSubtitle => 'ڕێنمایی، ئامۆژگاری سەلامەتی و پەیوەندی';

  @override
  String get helpGuideTitle => 'Finder چۆن کار دەکات';

  @override
  String get helpGuideStartTitle => 'دەستپێکردن';

  @override
  String get helpGuideStartSubtitle =>
      'زمان، پرۆفایل، ئاگادارکردنەوە، نیشانەکان';

  @override
  String get helpGuideStart1 =>
      'زمانەکەت لە ئایکۆنی وەرگێڕان لە شاشەی چوونەژوورەوە یان لە پرۆفایل هەڵبژێرە. هەموو پۆستەکان بەو زمانە پیشان دەدرێن.';

  @override
  String get helpGuideStart2 =>
      'پرۆفایلەکەت بە ناوی ڕاستەقینە و وێنەیەک تەواو بکە: خەڵک زیاتر ئامادەن شتێک بگەڕێننەوە بۆ کەسێک کە دەیناسنەوە.';

  @override
  String get helpGuideStart3 =>
      'ڕێگە بە ئاگادارکردنەوەکان بدە تا دەستبەجێ لە لێکچوون و نامەکان ئاگادار بیت.';

  @override
  String get helpGuideStart4 =>
      'نیشانەکان: «چاوەڕوان» واتە چاودێرێک هێشتا پۆستەکە دەپشکنێت، «بڵاوکراوە» واتە هەمووان دەیبینن، «گەڕێنراوەتەوە» واتە شتەکە گەڕاوەتەوە بۆ خاوەنەکەی.';

  @override
  String get helpGuideLostTitle => 'بڵاوکردنەوەی شتێکی ونبوو';

  @override
  String get helpGuideLostSubtitle => 'چی بنووسیت و چی لای خۆت بهێڵیتەوە';

  @override
  String get helpGuideLost1 =>
      'وێنەیەکی ڕوونی شتەکە یان هەمان مۆدێل زیاد بکە تا خەڵک بە یەک چاوپێکەوتن بیناسنەوە.';

  @override
  String get helpGuideLost2 =>
      'شوێنی ورد و کاتی دوا جار کە لەلات بوو بنووسە. خەڵکی نزیک یەکەم جار پۆستەکەت دەبینن.';

  @override
  String get helpGuideLost3 =>
      'وەسفی بکە، بەڵام یەک دوو وردەکاری لای خۆت بهێڵەوە (خراشێک، ناوەڕۆکەکەی، هەڵکۆڵینێک). بەکاریان دەهێنیت بۆ دڵنیابوون کە دۆزەرەوەکە بەڕاستی هەیەتی.';

  @override
  String get helpGuideLost4 =>
      'پاداشت ئارەزوومەندانەیە. هەرگیز هیچ پارەیەک مەدە پێش ئەوەی شتەکە لە دەستی خۆتدا بێت.';

  @override
  String get helpGuideLost5 =>
      'پۆستەکەت «چاوەڕوان» پیشان دەدرێت هەتا چاودێرێک پەسەندی دەکات، زۆربەی جار لە چەند کاتژمێرێکدا. ئاگادارکردنەوەت پێ دەگات کاتێک بڵاو دەبێتەوە و هەر کاتێک پۆستێکی دۆزراوە لێک دەچێت.';

  @override
  String get helpGuideFoundTitle => 'بڵاوکردنەوەی شتێکی دۆزراوە';

  @override
  String get helpGuideFoundSubtitle => 'خاوەنەکە بپارێزە لە کاتی گەڕاندا بۆی';

  @override
  String get helpGuideFound1 =>
      'وێنەی شتەکە بگرە، بەڵام هەر شتێکی کەسی بشارەوە: ناوەکان، ژمارەی ناسنامە، کارتی بانک، ناونیشان، شاشەی مۆبایل.';

  @override
  String get helpGuideFound2 =>
      'ژمارەی زنجیرەیی، IMEI یان ناوەڕۆکی جزدان و جانتا بڵاو مەکەرەوە. بۆ پشکنینی داواکارییەکان بیانهێڵەوە.';

  @override
  String get helpGuideFound3 =>
      'بڵێ لە کوێ و کەی دۆزیوتەتەوە و ئێستا نزیکەی لە کوێیە. پێویست ناکات ناونیشانی ماڵەکەت بڵێیت.';

  @override
  String get helpGuideFound4 =>
      'بەڵگەنامە، پاسپۆرت، مۆبایل، کارتی بانک و پارە: هەروەها بیاندە بە پۆلیس یان مێزی ونبووەکانی شوێنەکە، و لە پۆستەکەدا ئەوە بنووسە.';

  @override
  String get helpGuideFound5 =>
      'دوای پەسەندکردن، ئەپەکە پۆستەکەت لەگەڵ ئەوانەی دەگەڕێن لێک دەدات و بە زمانی خۆیان ئاگاداریان دەکاتەوە.';

  @override
  String get helpGuideMatchTitle => 'کاتێک لێکچوون یان نامەیەکت پێ دەگات';

  @override
  String get helpGuideMatchSubtitle => 'دواتر چی بکەیت';

  @override
  String get helpGuideMatch1 =>
      'پۆستە لێکچووەکە بکەرەوە و وێنە و شوێن و کاتەکە لەگەڵ هی خۆت بەراورد بکە.';

  @override
  String get helpGuideMatch2 =>
      'لەناو گفتوگۆی ئەپەکە وەڵام بدەرەوە. ژمارەی مۆبایل و ناونیشانەکەت تایبەت بهێڵەوە هەتا یەکتر دەبینن.';

  @override
  String get helpGuideMatch3 =>
      'ئەگەر تۆ شتەکەت دۆزیوەتەوە، پێش ڕازیبوون بە بینین، داوای وردەکارییەک لە داواکارەکە بکە کە لە پۆستەکەدا نییە.';

  @override
  String get helpGuideMatch4 =>
      'شتە ڕاستەکە نییە؟ بە ڕێزەوە بڵێ. کەسێک کە فشارت لێ دەکات، داوای پارە دەکات یان پاڵت پێوە دەنێت بچیتە ئەپێکی تر نیشانەی مەترسییە: بلۆکی بکە و ڕاپۆرتی بکە.';

  @override
  String get helpGuideVerifyTitle => 'دڵنیابوون لەوەی خاوەنە ڕاستەقینەکەیە';

  @override
  String get helpGuideVerifySubtitle => 'پشکنینی سادە کە داواکاری درۆ ڕادەگرێت';

  @override
  String get helpGuideVerify1 =>
      'پرسیاری شتێک بکە کە تەنها خاوەنەکە دەیزانێت: چی لەناویدایە، خراش یان ستیکەرێک، وێنەی شاشەی قفڵ، هەڵکۆڵینێک، ڕەنگی وردی قایشەکە.';

  @override
  String get helpGuideVerify2 =>
      'داوای وێنەیەکی شتەکە لە پێش ونبوونی بکە، یان پسوولە، سندوقەکە، یان ژمارەی زنجیرەیی کە بتوانیت بەراوردی بکەیت.';

  @override
  String get helpGuideVerify3 =>
      'بۆ مۆبایل: خاوەنەکە دەتوانێت پەیوەندی بە ژمارەکەوە بکات یان لەبەردەمت قفڵەکەی بکاتەوە. بۆ کلیل: دەتوانێت ناوی ئۆتۆمبێلەکە بڵێت یان دەرگاکە بکاتەوە.';

  @override
  String get helpGuideVerify4 =>
      'بۆ بەڵگەنامە و کارتی بانک، تەنها بیدە بەو کەسەی ناوی لەسەرە لەگەڵ ناسنامەیەکی لێکچوو، یان بە فەرمانگەی دەرکەر یان پۆلیس.';

  @override
  String get helpGuideVerify5 =>
      'هەرگیز پێشەکی مەنێرە، پارە مەگوازەوە یان زانیاری بانکیت هاوبەش مەکە بۆ «ئازادکردنی» شتێک. Finder هەرگیز داوای پارەدان ناکات.';

  @override
  String get helpGuideVerify6 =>
      'هێشتا دڵنیا نیت؟ داوا بکە لە بنکەی پۆلیس یەکتر ببینن، یان گفتوگۆکە ڕاپۆرت بکە و با چاودێرێک سەیری بکات.';

  @override
  String get helpGuideMeetTitle => 'بینینی سەلامەت';

  @override
  String get helpGuideMeetSubtitle => 'ڕادەستکردنەکە';

  @override
  String get helpGuideMeet1 =>
      'لە شوێنێکی گشتی قەرەباڵغ و بە ڕۆژ یەکتر ببینن: مۆڵ، کافێ، بنکەی پۆلیس یان مێزی ونبووەکان.';

  @override
  String get helpGuideMeet2 =>
      'هاوڕێیەک لەگەڵ خۆت ببە یان بە کەسێک بڵێ بۆ کوێ دەچیت و کەی چاوەڕوانی گەڕانەوەت دەکرێت.';

  @override
  String get helpGuideMeet3 =>
      'بۆ ڕادەستکردن سواری ئۆتۆمبێل مەبە و مەچۆ بۆ ماڵێکی تایبەت.';

  @override
  String get helpGuideMeet4 =>
      'پاداشت تەنها دوای وەرگرتنی شتەکە بدە، و تەنها ئەگەر خۆت پێشنیارت کردبێت. کەس ناتوانێت داوای بکات.';

  @override
  String get helpGuideMeet5 =>
      'دواتر، پۆستەکە وەک «گەڕێنراوەتەوە» نیشانە بکە تا ئاگادارکردنەوەکە بوەستێت و ئەوانی تر لەگەڵت ئاهەنگ بگێڕن.';

  @override
  String get helpGuideReportTitle => 'ڕاپۆرتکردنی کێشەیەک';

  @override
  String get helpGuideReportSubtitle => 'پۆستەکان، کەسەکان، هەڵەکان';

  @override
  String get helpGuideReport1 =>
      'پۆستێک لە مێنیوەکەیەوە ڕاپۆرت بکە و هۆکارێک هەڵبژێرە. چاودێرێک پێداچوونەوەی بۆ دەکات و دەتوانێت لایببات یان ئاگاداری نووسەرەکە بکاتەوە.';

  @override
  String get helpGuideReport2 =>
      'بەکارهێنەرێک لە پرۆفایلەکەی یان لە گفتوگۆکە بلۆک بکە بۆ وەستاندنی نامەکانی. پێی ناوترێت.';

  @override
  String get helpGuideReport3 =>
      'هەموو پۆستێکی نوێ لەلایەن چاودێرێکەوە دەپشکنرێت، لەگەڵ پێش‌پشکنینی AI بۆ فێڵ، ڕیکلام و وێنەی نەشیاو. پۆستە پەسەندکراوەکانیش هێشتا دەتوانرێت ڕاپۆرت بکرێن.';

  @override
  String get helpGuideReport4 =>
      'شتێک کار ناکات؟ «ڕاپۆرتی کێشە» لە خوارەوە بەکاربهێنە. بۆ کێشەی سەلامەتی بەپەلە: سەرەتا پەیوەندی بە پۆلیسەوە بکە.';

  @override
  String get navPost => 'پۆست';

  @override
  String navTab(String label) {
    return 'تابی $label';
  }

  @override
  String get categoryAllItems => 'هەموو شتەکان';

  @override
  String get categoryAll => 'هەموو';

  @override
  String get categoryNearby => 'نزیک';

  @override
  String get categoryRecent => 'نوێترین';

  @override
  String get categoryWithReward => 'بە پاداشت';

  @override
  String get categoryElectronics => 'ئەلیکترۆنیات';

  @override
  String get categoryWatchesJewelry => 'کاتژمێر و خشڵ';

  @override
  String get categoryWalletsBags => 'جزدان و جانتا';

  @override
  String get categoryKeys => 'کلیل';

  @override
  String get categoryPets => 'ئاژەڵی ماڵی';

  @override
  String get categoryClothing => 'جلوبەرگ';

  @override
  String get categoryDocuments => 'بەڵگەنامە';

  @override
  String get categoryOther => 'هی تر';

  @override
  String get categoryWallets => 'جزدان';

  @override
  String get categoryBags => 'جانتا';

  @override
  String get categoryWallet => 'جزدان';

  @override
  String get categoryJewelry => 'خشڵ';

  @override
  String get categoryOthers => 'هی تر';

  @override
  String get categoryVisibilityPublic => 'گشتی';

  @override
  String get categoryVisibilityFriendsOnly => 'تەنها هاوڕێیان';

  @override
  String get categoryVisibilityPrivate => 'تایبەت';

  @override
  String get filterTitle => 'فلتەرەکان';

  @override
  String get filterSubtitle => 'ئەوەی بەدوایدا دەگەڕێیت وردتر بکە';

  @override
  String get filterReset => 'ڕێکخستنەوە';

  @override
  String get filterApply => 'جێبەجێکردنی فلتەرەکان';

  @override
  String get filterType => 'جۆر';

  @override
  String get filterLocationHint => 'شار یان ناوچە بنووسە';

  @override
  String get filterDateRange => 'ماوەی ڕێکەوت';

  @override
  String get filterFrom => 'لە';

  @override
  String get filterTo => 'بۆ';

  @override
  String get filterSelectDate => 'ڕێکەوت هەڵبژێرە';

  @override
  String get filterRewardOffered => 'پاداشتی هەیە';

  @override
  String get filterRewardSubtitle => 'تەنها ئەو پۆستانەی پاداشت دەدەن';

  @override
  String get filterVerifiedOnly => 'تەنها بەکارهێنەرە پشتڕاستکراوەکان';

  @override
  String get filterVerifiedSubtitle =>
      'بڵاوکراوە لەلایەن ئەندامانی ناسنامە پشتڕاستکراو';

  @override
  String get filterSortBy => 'ڕیزکردن بەپێی';

  @override
  String get filterMostRecent => 'نوێترین';

  @override
  String get filterNearest => 'نزیکترین بۆ من';

  @override
  String get filterAnyTime => 'هەر کاتێک';

  @override
  String get filterLast24h => '٢٤ کاتژمێری ڕابردوو';

  @override
  String get filterLastWeek => 'هەفتەی ڕابردوو';

  @override
  String get filterLastMonth => 'مانگی ڕابردوو';

  @override
  String filterDate(int day, String month, int year) {
    return '$day $month، $year';
  }

  @override
  String get searchSubtitle => 'شتە ونبوو و دۆزراوەکانی نزیکت بدۆزەرەوە';

  @override
  String get searchHint => 'گەڕان بۆ شت، شوێن…';

  @override
  String get searchClear => 'سڕینەوەی گەڕان';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ئەنجام',
      one: '١ ئەنجام',
    );
    return '$_temp0';
  }

  @override
  String get searchClearFilters => 'سڕینەوەی فلتەرەکان';

  @override
  String get searchResetFilters => 'ڕێکخستنەوەی فلتەرەکان';

  @override
  String get searchNoResultsTitle => 'هیچ شتێکی هاوتا نەدۆزرایەوە';

  @override
  String get searchNoResultsSubtitle =>
      'وشەیەکی تر تاقی بکەرەوە یان فلتەرەکان بگۆڕە.';

  @override
  String get homeReportLost => 'ڕاپۆرتی ونبوو';

  @override
  String get homeReportLostSubtitle => 'داوا لە کۆمەڵگە بکە';

  @override
  String get homeReportFound => 'ڕاپۆرتی دۆزراوە';

  @override
  String get homeReportFoundSubtitle => 'بیگەڕێنەوە بۆ خاوەنەکەی';

  @override
  String get homeLoadingPosts => 'بارکردنی پۆستەکان...';

  @override
  String get homeNoLostItems => 'هیچ شتێکی ونبوو نییە';

  @override
  String get homeNoFoundItems => 'هیچ شتێکی دۆزراوە نییە';

  @override
  String get homeNoPostsYet => 'هێشتا هیچ پۆستێک نییە';

  @override
  String get homeCreateFirstPost => 'یەکەم پۆست دروست بکە بۆ دەستپێکردن.';

  @override
  String get homeTrySwitchingAll => 'بگۆڕە بۆ هەموو شتەکان.';

  @override
  String get homeOpenProfile => 'کردنەوەی پڕۆفایل';

  @override
  String get homeContactOwner => 'پەیوەندی بە خاوەن';

  @override
  String get homeContactFinder => 'پەیوەندی بە دۆزەرەوە';

  @override
  String get homeGoodMorning => 'بەیانی باش';

  @override
  String get homeGoodAfternoon => 'ڕۆژ باش';

  @override
  String get homeGoodEvening => 'ئێوارە باش';

  @override
  String get homeGuest => 'میوان';

  @override
  String homeNotificationsUnread(int count) {
    return 'ئاگادارکردنەوەکان، $count نەخوێندراوە';
  }

  @override
  String get mapPickLocation => 'شوێنێک هەڵبژێرە';

  @override
  String get mapSearchHint => 'گەڕان بۆ شوێن یان ناونیشان';

  @override
  String get mapSearching => 'گەڕان…';

  @override
  String get mapMoveToPlacePin => 'نەخشەکە بجوڵێنە بۆ دانانی نیشانە';

  @override
  String get mapUseMyLocation => 'شوێنی ئێستام بەکاربهێنە';

  @override
  String get mapFindingAddress => 'دۆزینەوەی ناونیشان…';

  @override
  String get mapUseThisLocation => 'ئەم شوێنە بەکاربهێنە';

  @override
  String get mapAttribution => 'زانیاری نەخشە © بەشداربووانی OpenStreetMap';

  @override
  String get mapErrGpsOff =>
      'خزمەتگوزاری شوێن (GPS) چالاک بکە بۆ بەکارهێنانی شوێنی ئێستات.';

  @override
  String get mapErrBlocked =>
      'دەستگەیشتن بە شوێن بلۆککراوە. لە ڕێکخستنەکانی مۆبایلەکەت ڕێگە بدە بۆ بەکارهێنانی شوێنی ئێستات.';

  @override
  String get mapErrDenied => 'مۆڵەتی شوێن نەدرا.';

  @override
  String get mapErrNoFix =>
      'شوێنی GPS نەدۆزرایەوە. بڕۆ شوێنێک کە ئاسمان ڕوونتر دەبینرێت و دووبارە هەوڵ بدەرەوە.';

  @override
  String shareKindTitle(String kind, String title) {
    return '$kind: $title';
  }

  @override
  String shareFindMe(String id) {
    return 'لە Finder بمدۆزەرەوە · ناسنامەی ئەندام $id';
  }

  @override
  String shareProfileSubject(String name) {
    return '$name لە Finder';
  }

  @override
  String get postItemDetailsTitle => 'وردەکاری شت';

  @override
  String get postItemDetails => 'وردەکاری شت';

  @override
  String get postNoDescription => 'هێشتا وەسف نەنووسراوە.';

  @override
  String get postReward => 'پاداشت';

  @override
  String postRewardAmount(String amount) {
    return 'پاداشت $amount';
  }

  @override
  String get postIFoundThis => 'من ئەم شتەم دۆزیوەتەوە';

  @override
  String get postThisIsMine => 'ئەمە هی منە';

  @override
  String get postReturnedOwnerNote =>
      'وەک گەڕێنراوە نیشانە کرا. چیتر لە سەرەکی دەرناکەوێت، بەڵام لە گەڕان دەمێنێتەوە تا خەڵک ئەنجامەکە ببینن.';

  @override
  String get postRemoveFromSaved => 'لابردن لە پاشەکەوتکراوەکان';

  @override
  String get postSaveItem => 'پاشەکەوتکردنی شت';

  @override
  String get postMoreActions => 'کرداری زیاتر';

  @override
  String get postLinkCopied => 'لینک کۆپی کرا.';

  @override
  String get postDetailsCopied => 'وردەکاری شتەکە کۆپی کرا.';

  @override
  String get postSavedToList => 'لە لیستەکەت پاشەکەوت کرا.';

  @override
  String get postRemovedFromSaved => 'لە پاشەکەوتکراوەکان لابرا.';

  @override
  String get postManageSheetTitle => 'بەڕێوەبردنی پۆست';

  @override
  String get postMoreSheetTitle => 'زیاتر';

  @override
  String get postShareSubtitle => 'وێنەکە و لینکێک بۆ هەر کەسێک بنێرە';

  @override
  String get postCopyLink => 'کۆپیکردنی لینک';

  @override
  String get postEditPost => 'دەستکاری پۆست';

  @override
  String get postReopenPost => 'دووبارە کردنەوەی پۆست';

  @override
  String get postDeletePost => 'سڕینەوەی پۆست';

  @override
  String get postReportPost => 'ڕاپۆرتکردنی پۆست';

  @override
  String get postBlockThisMember => 'بلۆککردنی ئەم ئەندامە';

  @override
  String get postBlockMember => 'بلۆککردنی ئەندام';

  @override
  String get postActiveAgain => 'پۆستەکە دووبارە چالاکە.';

  @override
  String get postDeleteTitle => 'پۆستەکە بسڕدرێتەوە؟';

  @override
  String postDeleteBody(String title) {
    return '\"$title\" بۆ هەمووان لادەبرێت. ئەمە ناگەڕێتەوە.';
  }

  @override
  String postDeleteBodyConfirm(String title) {
    return 'دڵنیایت دەتەوێت \"$title\" بسڕیتەوە؟ ئەمە ناگەڕێتەوە.';
  }

  @override
  String get postDeleted => 'پۆستەکە سڕایەوە.';

  @override
  String get postReportReasonSpam => 'سپام یان فێڵ';

  @override
  String get postReportReasonInappropriate => 'ناوەڕۆکی نەشیاو';

  @override
  String get postReportReasonMisleading => 'زانیاری هەڵە یان چەواشەکار';

  @override
  String get postReportReasonOther => 'شتێکی تر';

  @override
  String get postReportSheetTitle => 'ڕاپۆرتکردنی ئەم پۆستە';

  @override
  String get postReportSheetSubtitle =>
      'پێمان بڵێ کێشەکە چییە. تیمەکە پێداچوونەوە بە ڕاپۆرتەکان دەکات.';

  @override
  String get postReported => 'سوپاس، پۆستەکە ڕاپۆرت کرا.';

  @override
  String get postThisMember => 'ئەم ئەندامە';

  @override
  String postBlockTitle(String name) {
    return '$name بلۆک بکرێت؟';
  }

  @override
  String get postBlockBody =>
      'چیتر پۆست و نامەکانی یەکتر نابینن. دەتوانیت لە تایبەتێتی و سەلامەتی بیگەڕێنیتەوە.';

  @override
  String postBlocked(String name) {
    return '$name بلۆک کرا.';
  }

  @override
  String get postCategory => 'پۆلێن';

  @override
  String get postLostOn => 'ون بووە لە';

  @override
  String get postFoundOn => 'دۆزراوەتەوە لە';

  @override
  String get postOpenInMaps => 'کردنەوە لە نەخشە';

  @override
  String get postCouldNotOpenMaps => 'ئەپی نەخشە نەکرایەوە.';

  @override
  String get postNotProvided => 'دابین نەکراوە';

  @override
  String get postPostedByOwner => 'لەلایەن خاوەنەکەی بڵاوکراوەتەوە';

  @override
  String get postPostedByFinder => 'لەلایەن دۆزەرەوە بڵاوکراوەتەوە';

  @override
  String get postLoadingProfile => 'بارکردنی پڕۆفایل…';

  @override
  String get postProfileNotAvailable => 'پڕۆفایل بەردەست نییە';

  @override
  String get postVerifiedMember => 'ئەندامی پشتڕاستکراو';

  @override
  String postMemberSince(String date) {
    return 'ئەندامە لە $date';
  }

  @override
  String postPostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پۆست',
      one: '١ پۆست',
    );
    return '$_temp0';
  }

  @override
  String postMonthYear(String month, int year) {
    return '$month $year';
  }

  @override
  String get postPhone => 'مۆبایل';

  @override
  String get postCouldNotOpenDialer => 'ئەپی پەیوەندیکردن نەکرایەوە.';

  @override
  String get postChatWithOwner => 'گفتوگۆ لەگەڵ خاوەن';

  @override
  String get postChatWithFinder => 'گفتوگۆ لەگەڵ دۆزەرەوە';

  @override
  String get postCall => 'پەیوەندی';

  @override
  String get postPhoneNotShared =>
      'ژمارەی مۆبایل هاوبەش نەکراوە. گفتوگۆی ناو ئەپ سەلامەتترین ڕێگەیە بۆ ڕێککەوتن.';

  @override
  String get postOwnerActions => 'کردارەکانی خاوەن';

  @override
  String get postSafety => 'سەلامەتی';

  @override
  String get postPossibleMatches => 'هاوشێوە گونجاوەکان';

  @override
  String get postMatchesEyebrowLost => 'شتە دۆزراوەکان کە لە هی تۆ دەچن';

  @override
  String get postMatchesEyebrowFound => 'شتە ونبووەکان کە لەمە دەچن';

  @override
  String get postNoMatchesLost =>
      'هێشتا هاوشێوە نییە. بەردەوام پۆستە نوێیەکانی دۆزراوە لەگەڵ ئەمە بەراورد دەکەین و دەستبەجێ ئاگادارت دەکەینەوە کە شتێکی لێچوو دەرکەوت.';

  @override
  String get postNoMatchesFound =>
      'هێشتا هاوشێوە نییە. بەردەوام پۆستە نوێیەکانی ونبوو لەگەڵ ئەمە بەراورد دەکەین و دەستبەجێ ئاگادارت دەکەینەوە کە شتێکی لێچوو دەرکەوت.';

  @override
  String get postSimilarItems => 'شتە هاوشێوەکان';

  @override
  String get postSimilarEyebrowLost => 'شتە دۆزراوەکانی ئەم پۆلێنە';

  @override
  String get postSimilarEyebrowFound => 'شتە ونبووەکانی ئەم پۆلێنە';

  @override
  String get postViewAll => 'هەموو ببینە';

  @override
  String get postLoadingSimilar => 'بارکردنی شتە هاوشێوەکان...';

  @override
  String get postNoSimilarTitle => 'هێشتا شتی هاوشێوە نییە';

  @override
  String get postNoSimilarSubtitle =>
      'دواتر سەرێک بدەرەوە بۆ هاوشێوەکانی نزیک.';

  @override
  String get postMatchBannerTitleLost =>
      'دەکرێت ئەمە ئەو شتە بێت کە دۆزیوتەتەوە؟';

  @override
  String get postMatchBannerTitleFound => 'دەکرێت ئەمە شتەکەی تۆ بێت؟';

  @override
  String get postMatchBannerBodyLost =>
      'کەسێک ڕاپۆرتی ونبوونی شتێکی کردووە کە لەو شتە دەچێت کە دۆزیوتەتەوە. وردەکارییەکان بەراورد بکە و نامەی بۆ بنێرە.';

  @override
  String get postMatchBannerBodyFound =>
      'کەسێک ڕاپۆرتی دۆزینەوەی شتێکی کردووە کە لەوە دەچێت کە ون کردووتە. وردەکارییەکان بەراورد بکە و نامەی بۆ بنێرە.';

  @override
  String get postMessageOwner => 'نامە بۆ خاوەن';

  @override
  String get postMessageFinder => 'نامە بۆ دۆزەرەوە';

  @override
  String postItemSemantics(String status, String title) {
    return 'شتی $status، $title';
  }

  @override
  String get postLocationNotSet => 'شوێن دانەنراوە';

  @override
  String get postNewPost => 'پۆستی نوێ';

  @override
  String get postHeaderLost => 'بە کۆمەڵگە بڵێ چیت ون کردووە.';

  @override
  String get postHeaderFound => 'یارمەتی بدە ئەوەی دۆزیوتەتەوە بگەڕێتەوە.';

  @override
  String get postReadyToPost => 'ئامادەیە بۆ بڵاوکردنەوە';

  @override
  String postDetailsAdded(int count) {
    return '$count لە ٥ وردەکاری زیادکرا';
  }

  @override
  String get postPhotos => 'وێنەکان';

  @override
  String get postPhoto => 'وێنە';

  @override
  String postStep(int number) {
    return 'هەنگاوی $number';
  }

  @override
  String get postPhotosHint =>
      'وێنەی ڕوون یارمەتی ئەوانی تر دەدات شتەکە بناسنەوە.';

  @override
  String get postCamera => 'کامێرا';

  @override
  String get postGallery => 'گەلەری';

  @override
  String get postRemovePhoto => 'لابردنی وێنە';

  @override
  String get postUploadingPhoto => 'بەرزکردنەوەی وێنە';

  @override
  String postAddPhotoFrom(String source) {
    return 'زیادکردنی وێنە لە $source';
  }

  @override
  String get postItemName => 'ناوی شت';

  @override
  String get postItemNameHint => 'نموونە: جانتای پشتی شین';

  @override
  String get postItemNameHintEdit => 'نموونە: جزدانی ڕەش';

  @override
  String get postChooseCategory => 'پۆلێنێک هەڵبژێرە';

  @override
  String get postChooseCategoryTitle => 'هەڵبژاردنی پۆلێن';

  @override
  String get postDescription => 'وەسف';

  @override
  String get postDescriptionHint =>
      'نموونە: دوایین جار لە نزیک فوارەکەی پارکی ناوەند بینرا. خەتێکی بچووکی لەسەر پێشەوەیە…';

  @override
  String postDescriptionHelper(int count) {
    return '$count/500 · لانیکەم ١٠ پیت';
  }

  @override
  String get postDescriptionHintEdit => 'شتەکە بە وردی وەسف بکە…';

  @override
  String get postDescriptionHelperEdit => 'لانیکەم ١٠ پیت';

  @override
  String get postRewardOptional => 'پاداشت (ئارەزوومەندانە)';

  @override
  String get postRewardHint => 'نموونە: 100\$';

  @override
  String get postRewardHintEdit => 'نموونە: 50';

  @override
  String get postRewardNote =>
      'پاداشت وەک نیشانەیەکی زەرد لەسەر پۆستەکەت دەردەکەوێت.';

  @override
  String get postLocationTime => 'شوێن و کات';

  @override
  String get postNoLocationSelected => 'هیچ شوێنێک هەڵنەبژێردراوە';

  @override
  String get postLocateMe => 'شوێنم بدۆزەرەوە';

  @override
  String get postOpenMap => 'کردنەوەی نەخشە';

  @override
  String get postMovePin => 'جوڵاندنی نیشانە';

  @override
  String get postPickOnMap => 'هەڵبژاردن لەسەر نەخشە';

  @override
  String get postMovePinOnMap => 'جوڵاندنی نیشانە لەسەر نەخشە';

  @override
  String get postTypeAddress => 'لەبری ئەوە ناونیشانێک بنووسە';

  @override
  String get postDate => 'ڕێکەوت';

  @override
  String get postTime => 'کات';

  @override
  String get postDateTime => 'ڕێکەوت / کات';

  @override
  String get postTapToPickDate => 'دەست لێبدە بۆ هەڵبژاردنی ڕێکەوت';

  @override
  String get postLocationHint => 'لە کوێ ون بووە یان دۆزراوەتەوە؟';

  @override
  String get postHowPeopleReachYou => 'خەڵک چۆن پەیوەندیت پێوە دەکەن';

  @override
  String get postInAppChat => 'گفتوگۆی ناو ئەپ';

  @override
  String get postInAppChatNote =>
      'هەمیشە چالاکە. ئەندامان لە ڕێگەی نامەکانی Finder پەیوەندیت پێوە دەکەن.';

  @override
  String get postOn => 'چالاک';

  @override
  String get postShowPhone => 'ژمارەی مۆبایلم پیشان بدە';

  @override
  String get postShowPhoneNote =>
      'لە پڕۆفایلەکەت بۆ ئەندامە چووەژوورەوەکان دەردەکەوێت';

  @override
  String get postPhoneNumber => 'ژمارەی مۆبایل';

  @override
  String get postPhoneHint => 'نموونە: +964 750 000 0000';

  @override
  String get postPhoneHelper =>
      'لە پڕۆفایلەکەت پاشەکەوت دەکرێت و لەگەڵ ئەندامە چووەژوورەوەکان هاوبەش دەکرێت.';

  @override
  String get postPostNow => 'ئێستا بڵاوی بکەرەوە';

  @override
  String get postSaveDraft => 'پاشەکەوتکردنی ڕەشنووس';

  @override
  String get postSaveChanges => 'پاشەکەوتکردنی گۆڕانکارییەکان';

  @override
  String postLocationSetTo(String label) {
    return 'شوێن دانرا: $label.';
  }

  @override
  String get postEnterLocation => 'شوێن بنووسە';

  @override
  String get postEnterLocationHint => 'شار، شەقام یان ناوچە';

  @override
  String get postErrTitleRequired => 'تکایە پێش بڵاوکردنەوە ناوی شتەکە بنووسە.';

  @override
  String get postErrDescriptionShort =>
      'تکایە لانیکەم ١٠ پیت لە وەسفەکەدا بنووسە.';

  @override
  String get postErrPhoneRequired =>
      'تکایە ژمارەی مۆبایل بنووسە یان هاوبەشکردنی مۆبایل ناچالاک بکە.';

  @override
  String get postErrLoginRequired => 'دەبێت بچیتە ژوورەوە بۆ بڵاوکردنەوە.';

  @override
  String get postErrTitleRequiredEdit => 'تکایە ناونیشانێک بنووسە.';

  @override
  String get postErrDescriptionShortEdit => 'وەسف دەبێت لانیکەم ١٠ پیت بێت.';

  @override
  String get postLive => 'پۆستەکەت بڵاو کرایەوە.';

  @override
  String get postUpdated => 'پۆستەکە نوێکرایەوە.';

  @override
  String get postPhotoAdded => 'وێنە زیادکرا.';

  @override
  String get postDraftSaved => 'ڕەشنووس لەسەر ئامێرەکە پاشەکەوت کرا.';

  @override
  String get postUploadingImage => 'بەرزکردنەوەی وێنە…';

  @override
  String get postTapToChange => 'دەست لێبدە بۆ گۆڕین';

  @override
  String get postTapToPickFromGallery => 'دەست لێبدە بۆ هەڵبژاردن لە گەلەری';

  @override
  String get postAddPhoto => 'زیادکردنی وێنە';

  @override
  String get postChangePhoto => 'گۆڕینی وێنە';

  @override
  String get postILostSomething => 'شتێکم ون کردووە';

  @override
  String get postIFoundSomething => 'شتێکم دۆزیوەتەوە';

  @override
  String get postAskCommunityHelp => 'داوای یارمەتی لە کۆمەڵگە بکە';

  @override
  String get postHelpReturnHome => 'یارمەتی بدە بگەڕێتەوە بۆ خاوەنەکەی';

  @override
  String get postMyPosts => 'پۆستەکانم';

  @override
  String postOpenReturnedCount(int open, int returned) {
    return '$open کراوە · $returned گەڕێنراوە';
  }

  @override
  String get postNoOpenPosts => 'هیچ پۆستێکی کراوە نییە';

  @override
  String get postNoReturnedYet => 'هێشتا هیچ شتێک نەگەڕێنراوەتەوە';

  @override
  String get postCreateYourFirst => 'یەکەم پۆستت دروست بکە بۆ دەستپێکردن.';

  @override
  String get postReturnedAppearHere =>
      'ئەو پۆستانەی وەک گەڕێنراوە نیشانەیان دەکەیت لێرە دەردەکەون.';

  @override
  String get postMarkReturnedTitle => 'وەک گەڕێنراوە نیشانە بکرێت؟';

  @override
  String postMarkReturnedBody(String title) {
    return '\"$title\" وەک گەڕێنراوە نیشانە بکرێت؟ لە سەرەکی دەردەچێت بەڵام لە گەڕان دەمێنێتەوە.';
  }

  @override
  String get postErrLoad => 'پۆستەکانت بار نەکران.';

  @override
  String get postErrDelete => 'پۆستەکە نەسڕایەوە.';

  @override
  String get postErrResolve => 'دۆخی پۆستەکە نەگۆڕدرا.';

  @override
  String get postErrReopen => 'پۆستەکە دووبارە نەکرایەوە.';

  @override
  String get postErrSave => 'پۆستەکە پاشەکەوت نەکرا.';

  @override
  String get postSavedItems => 'شتە پاشەکەوتکراوەکان';

  @override
  String get postSavedSubtitle =>
      'ئەو شتانە بەدوادا بچۆ کە یارمەتی دەدەیت بگەڕێنەوە یان بدۆزرێنەوە.';

  @override
  String postSavedCount(int count) {
    return '$count پاشەکەوتکراو · ئەو شتانەی یارمەتی دەدەیت بگەڕێنەوە یان بدۆزرێنەوە';
  }

  @override
  String get postLoadingSaved => 'بارکردنی شتە پاشەکەوتکراوەکان...';

  @override
  String get postNoSavedTitle => 'هێشتا هیچ شتێک پاشەکەوت نەکراوە';

  @override
  String get postNoSavedSubtitle =>
      'دەست لە نیشانەی پاشەکەوت بدە لەسەر هەر پۆستێک تا لێرە بمێنێتەوە.';

  @override
  String get postSentForReview =>
      'بۆ پێداچوونەوە نێردرا. کاتێک بڵاوبووەوە ئاگادارت دەکەینەوە.';

  @override
  String get postWaitingForReview => 'چاوەڕێی پێداچوونەوە';

  @override
  String get postWaitingForReviewBody =>
      'بەڕێوەبەرێک هەموو پۆستێک پێش بڵاوبوونەوە دەپشکنێت، زۆربەی جار لە ماوەی چەند کاتژمێرێکدا.';

  @override
  String get postRejectedTitle => 'پەسەند نەکرا';

  @override
  String postRejectedReason(String reason) {
    return 'هۆکار: $reason';
  }

  @override
  String get postEditAndResubmit => 'دەستکاری و دووبارە ناردن';

  @override
  String get postBadgeRejected => 'پەسەند نەکراوە';

  @override
  String get postBadgeExpired => 'ئەرشیفکراو';

  @override
  String get postExpiredTitle => 'ئەرشیفکراو';

  @override
  String get postExpiredBody =>
      'ئەم پۆستە دوای ٩٠ ڕۆژ ئەرشیف کرا. ئەگەر هێشتا گرنگە دووبارە بیکەرەوە.';

  @override
  String get postTranslatedNote => 'بە شێوەی ئۆتۆماتیکی وەرگێڕدراوە';

  @override
  String get postSeeOriginal => 'بینینی دەقی ڕەسەن';

  @override
  String get postSeeTranslation => 'بینینی وەرگێڕان';

  @override
  String get postPostLostCta => 'بڵاوکردنەوەی شتی ونبوو';

  @override
  String get postPostFoundCta => 'بڵاوکردنەوەی شتی دۆزراوە';

  @override
  String get mapNearbyTitle => 'نزیک من';

  @override
  String mapNearbyCount(int count, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پۆست لە $km کم',
      one: '١ پۆست لە $km کم',
      zero: 'هیچ پۆستێک لە $km کم',
    );
    return '$_temp0';
  }

  @override
  String mapRadius(int km) {
    return '$km کم';
  }

  @override
  String get mapNearbyEmpty =>
      'هێشتا هیچ پۆستێک لێرە نییە. ماوەیەکی گەورەتر تاقی بکەرەوە.';

  @override
  String get repoUnableLogin => 'چوونەژوورەوە سەرکەوتوو نەبوو';

  @override
  String get repoUnableLoginGoogle => 'چوونەژوورەوە بە Google سەرکەوتوو نەبوو';

  @override
  String get repoUnableLogout => 'چوونەدەرەوە سەرکەوتوو نەبوو';

  @override
  String get repoUnableSignUp => 'تۆماربوون سەرکەوتوو نەبوو';

  @override
  String get repoUnableSendResetCode =>
      'ناردنی کۆدی نوێکردنەوەی وشەی نهێنی سەرکەوتوو نەبوو';

  @override
  String get repoUnableVerifyCode => 'پشتڕاستکردنەوەی کۆد سەرکەوتوو نەبوو';

  @override
  String get repoUnableResetPassword =>
      'نوێکردنەوەی وشەی نهێنی سەرکەوتوو نەبوو';

  @override
  String get repoUnableVerifyEmail => 'پشتڕاستکردنەوەی ئیمەیڵ سەرکەوتوو نەبوو';

  @override
  String get repoUnableResendCode =>
      'دووبارە ناردنی کۆدی پشتڕاستکردنەوە سەرکەوتوو نەبوو';

  @override
  String get repoUnableLoadNotifications => 'ئاگادارکردنەوەکان بار نەکران.';

  @override
  String get repoUnableUpdateNotification => 'ئاگادارکردنەوەکە نوێ نەکرایەوە.';

  @override
  String get repoUnableUpdateNotifications =>
      'ئاگادارکردنەوەکان نوێ نەکرانەوە.';

  @override
  String get repoUnableLoadProfile => 'پڕۆفایلەکەت بار نەکرا.';

  @override
  String get repoUnableUpdateProfile => 'پڕۆفایلەکەت نوێ نەکرایەوە.';

  @override
  String get repoUnableLoadPrivacy => 'ڕێکخستنەکانی تایبەتێتی بار نەکران.';

  @override
  String get repoUnableUpdatePrivacy => 'ڕێکخستنەکانی تایبەتێتی نوێ نەکرانەوە.';

  @override
  String get repoUnableLoadNotifSettings =>
      'ڕێکخستنەکانی ئاگادارکردنەوە بار نەکران.';

  @override
  String get repoUnableUpdateNotifSettings =>
      'ڕێکخستنەکانی ئاگادارکردنەوە نوێ نەکرانەوە.';

  @override
  String get repoUnableLoadBlocked => 'بەکارهێنەرە بلۆککراوەکان بار نەکران.';

  @override
  String get repoUnableBlock => 'ئەم بەکارهێنەرە بلۆک نەکرا.';

  @override
  String get repoUnableUnblock => 'بلۆکی ئەم بەکارهێنەرە لانەبرا.';

  @override
  String get repoUnableSubmitVerification =>
      'داواکاری پشتڕاستکردنەوەکەت نەنێردرا.';

  @override
  String get repoUnableLoadVerification => 'دۆخی پشتڕاستکردنەوە بار نەکرا.';

  @override
  String get repoUnableDeleteAccount => 'هەژمارەکەت نەسڕایەوە.';

  @override
  String get repoUnableLoadSaved => 'شتە پاشەکەوتکراوەکان بار نەکران.';

  @override
  String get repoUnableUpdateSaved => 'شتە پاشەکەوتکراوەکان نوێ نەکرانەوە.';

  @override
  String get repoLoginToSave => 'تکایە بچۆرە ژوورەوە بۆ پاشەکەوتکردنی شتەکان.';

  @override
  String get repoLoginToManageNotifications =>
      'تکایە بچۆرە ژوورەوە بۆ بەڕێوەبردنی ئاگادارکردنەوەکان.';

  @override
  String get repoActionBlockUsers => 'بلۆککردنی بەکارهێنەران';

  @override
  String get repoActionCheckVerification => 'پشکنینی پشتڕاستکردنەوە';

  @override
  String get repoActionDeleteAccount => 'سڕینەوەی هەژمارەکەت';

  @override
  String get repoActionSubmitVerification => 'ناردنی پشتڕاستکردنەوە';

  @override
  String get repoActionUpdateBlocked => 'نوێکردنەوەی بەکارهێنەرە بلۆککراوەکان';

  @override
  String get repoActionUpdateNotifSettings =>
      'نوێکردنەوەی ڕێکخستنەکانی ئاگادارکردنەوە';

  @override
  String get repoActionUpdatePrivacy => 'نوێکردنەوەی ڕێکخستنەکانی تایبەتێتی';

  @override
  String get repoActionUpdateProfile => 'نوێکردنەوەی پڕۆفایلەکەت';

  @override
  String get repoActionViewBlocked => 'بینینی بەکارهێنەرە بلۆککراوەکان';

  @override
  String get repoActionViewNotifSettings =>
      'بینینی ڕێکخستنەکانی ئاگادارکردنەوە';

  @override
  String get repoActionViewPrivacy => 'بینینی ڕێکخستنەکانی تایبەتێتی';

  @override
  String get repoActionViewProfile => 'بینینی پڕۆفایلەکەت';

  @override
  String repoPleaseLogInTo(String action) {
    return 'تکایە بچۆرە ژوورەوە بۆ $action.';
  }

  @override
  String get serverAccountDeleted => 'هەژمار سڕایەوە.';

  @override
  String get serverAccountIsAlreadyVerified =>
      'هەژمارەکە پێشتر پشتڕاستکراوەتەوە.';

  @override
  String get serverCouldNotApproveTheRequest => 'داواکارییەکە پەسەند نەکرا.';

  @override
  String get serverCouldNotDeleteTheAccount => 'هەژمارەکە نەسڕایەوە.';

  @override
  String get serverCouldNotDeleteThePost => 'پۆستەکە نەسڕایەوە.';

  @override
  String get serverCouldNotRegisterThisDevice => 'ئەم ئامێرە تۆمار نەکرا.';

  @override
  String get serverCouldNotRejectTheRequest => 'داواکارییەکە ڕەت نەکرایەوە.';

  @override
  String get serverCouldNotResolveTheReport => 'ڕاپۆرتەکە یەکلا نەکرایەوە.';

  @override
  String get serverCouldNotStoreTheImage => 'وێنەکە پاشەکەوت نەکرا.';

  @override
  String get serverCouldNotUpdateTheAccount => 'هەژمارەکە نوێ نەکرایەوە.';

  @override
  String get serverCouldNotUpdateThePost => 'پۆستەکە نوێ نەکرایەوە.';

  @override
  String get serverDatabaseErrorOccurredDuringLogin =>
      'لە کاتی چوونەژوورەوە هەڵەی بنکەی دراوە ڕوویدا.';

  @override
  String get serverDatabaseErrorOccurredDuringRegistration =>
      'لە کاتی تۆمارکردن هەڵەی بنکەی دراوە ڕوویدا.';

  @override
  String get serverDatabaseErrorOccurred => 'هەڵەی بنکەی دراوە ڕوویدا.';

  @override
  String get serverDatabaseError => 'هەڵەی بنکەی دراوە.';

  @override
  String get serverEmailAndCodeAreRequired => 'ئیمەیڵ و کۆد پێویستن.';

  @override
  String get serverEmailIsAlreadyRegistered => 'ئەم ئیمەیڵە پێشتر تۆمارکراوە.';

  @override
  String get serverEmailVerifiedSuccessfully =>
      'ئیمەیڵ بە سەرکەوتوویی پشتڕاستکرایەوە.';

  @override
  String get serverErrorBlockingUser => 'بلۆککردنی بەکارهێنەر سەرکەوتوو نەبوو.';

  @override
  String get serverErrorCreatingPost => 'دروستکردنی پۆست سەرکەوتوو نەبوو.';

  @override
  String get serverErrorDeletingAccount => 'سڕینەوەی هەژمار سەرکەوتوو نەبوو.';

  @override
  String get serverErrorDeletingMessage => 'سڕینەوەی نامە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorDeletingPost => 'سڕینەوەی پۆست سەرکەوتوو نەبوو.';

  @override
  String get serverErrorFetchingBlockedUsers =>
      'بارکردنی بەکارهێنەرە بلۆککراوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorFetchingProfile => 'بارکردنی پڕۆفایل سەرکەوتوو نەبوو.';

  @override
  String get serverErrorFetchingUserProfile =>
      'بارکردنی پڕۆفایلی بەکارهێنەر سەرکەوتوو نەبوو.';

  @override
  String get serverErrorInitiatingConversation =>
      'دەستپێکردنی گفتوگۆ سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingConversations =>
      'بارکردنی گفتوگۆکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingMatches =>
      'بارکردنی هاوشێوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingMessages => 'بارکردنی نامەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingNotificationSettings =>
      'بارکردنی ڕێکخستنی ئاگادارکردنەوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingNotifications =>
      'بارکردنی ئاگادارکردنەوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingPost => 'بارکردنی پۆست سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingPosts => 'بارکردنی پۆستەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingPrivacySettings =>
      'بارکردنی ڕێکخستنی تایبەتێتی سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingReports =>
      'بارکردنی ڕاپۆرتەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingSavedItems =>
      'بارکردنی شتە پاشەکەوتکراوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingSimilarPosts =>
      'بارکردنی پۆستە هاوشێوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingStatistics =>
      'بارکردنی ئامارەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingTheFile => 'بارکردنی فایلەکە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingTheRequest =>
      'بارکردنی داواکارییەکە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingTheUser =>
      'بارکردنی بەکارهێنەر سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingUsers =>
      'بارکردنی بەکارهێنەران سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingVerificationRequests =>
      'بارکردنی داواکارییەکانی پشتڕاستکردنەوە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorLoadingVerificationStatus =>
      'بارکردنی دۆخی پشتڕاستکردنەوە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorRemovingSavedPost =>
      'لابردنی پۆستی پاشەکەوتکراو سەرکەوتوو نەبوو.';

  @override
  String get serverErrorSavingPost => 'پاشەکەوتکردنی پۆست سەرکەوتوو نەبوو.';

  @override
  String get serverErrorSearchingUsers =>
      'گەڕان بۆ بەکارهێنەران سەرکەوتوو نەبوو.';

  @override
  String get serverErrorSendingMessage => 'ناردنی نامە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorSubmittingReport => 'ناردنی ڕاپۆرت سەرکەوتوو نەبوو.';

  @override
  String get serverErrorSubmittingVerification =>
      'ناردنی داواکاری پشتڕاستکردنەوە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUnblockingUser =>
      'لابردنی بلۆکی بەکارهێنەر سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUpdatingChat => 'نوێکردنەوەی گفتوگۆ سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUpdatingNotificationSettings =>
      'نوێکردنەوەی ڕێکخستنی ئاگادارکردنەوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUpdatingNotification =>
      'نوێکردنەوەی ئاگادارکردنەوە سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUpdatingNotifications =>
      'نوێکردنەوەی ئاگادارکردنەوەکان سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUpdatingPost => 'نوێکردنەوەی پۆست سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUpdatingPrivacySettings =>
      'نوێکردنەوەی ڕێکخستنی تایبەتێتی سەرکەوتوو نەبوو.';

  @override
  String get serverErrorUpdatingProfile =>
      'نوێکردنەوەی پڕۆفایل سەرکەوتوو نەبوو.';

  @override
  String get serverFileNoLongerExists => 'فایلەکە چیتر بوونی نییە.';

  @override
  String get serverFinderAdministratorsCannotBeBlocked =>
      'بەڕێوەبەرانی Finder بلۆک ناکرێن.';

  @override
  String get serverGoogleAuthenticationFailed =>
      'چوونەژوورەوە بە Google سەرکەوتوو نەبوو.';

  @override
  String get serverIfThatAddressIsRegisteredACode =>
      'ئەگەر ئەو ئیمەیڵە تۆمارکرابێت، کۆدەکە لە ڕێگایە.';

  @override
  String get serverIncorrectEmailOrPassword => 'ئیمەیڵ یان وشەی نهێنی هەڵەیە.';

  @override
  String get serverIncorrectPassword => 'وشەی نهێنی هەڵەیە.';

  @override
  String get serverInvalidOrExpiredToken =>
      'دانیشتنەکە نادروستە یان بەسەرچووە.';

  @override
  String get serverInvalidToken => 'دانیشتنەکە نادروستە.';

  @override
  String get serverInvalidVerificationCode => 'کۆدی پشتڕاستکردنەوە هەڵەیە.';

  @override
  String get serverLocationSearchIsUnavailableRightNowTry =>
      'گەڕانی شوێن ئێستا بەردەست نییە. دوای کەمێک هەوڵ بدەرەوە.';

  @override
  String get serverMessageCannotBeEmpty => 'نامە ناتوانێت بەتاڵ بێت.';

  @override
  String get serverMessageNotFound => 'نامەکە نەدۆزرایەوە.';

  @override
  String get serverNoImageReceived => 'هیچ وێنەیەک وەرنەگیرا.';

  @override
  String get serverNoVerificationRequest =>
      'هیچ داواکارییەکی پشتڕاستکردنەوە نییە.';

  @override
  String get serverNotAuthenticated => 'نەچوویتەتە ژوورەوە.';

  @override
  String get serverNotAuthorized => 'ڕێگەپێدراو نیت.';

  @override
  String get serverNotFound => 'نەدۆزرایەوە.';

  @override
  String get serverPasswordHasBeenResetSuccessfully =>
      'وشەی نهێنی بە سەرکەوتوویی نوێکرایەوە.';

  @override
  String get serverPasswordIsRequired => 'وشەی نهێنی پێویستە.';

  @override
  String get serverPleaseChooseAnImageUnder8Mb =>
      'تکایە وێنەیەک هەڵبژێرە کە لە ٨ مێگابایت کەمتر بێت.';

  @override
  String get serverPostDeletedSuccessfully => 'پۆستەکە بە سەرکەوتوویی سڕایەوە.';

  @override
  String get serverPostDeleted => 'پۆستەکە سڕایەوە.';

  @override
  String get serverPostNotFound => 'پۆستەکە نەدۆزرایەوە.';

  @override
  String get serverPostRemovedFromSavedList =>
      'پۆستەکە لە پاشەکەوتکراوەکان لابرا.';

  @override
  String get serverPostSavedSuccessfully => 'پۆستەکە پاشەکەوت کرا.';

  @override
  String get serverRemoveTheAdminRoleBeforeDeletingThis =>
      'پێش سڕینەوەی ئەم هەژمارە ڕۆڵی بەڕێوەبەر لابە.';

  @override
  String get serverRemoveTheAdminRoleBeforeSuspendingThis =>
      'پێش ڕاگرتنی ئەم هەژمارە ڕۆڵی بەڕێوەبەر لابە.';

  @override
  String get serverReportNotFound => 'ڕاپۆرتەکە نەدۆزرایەوە.';

  @override
  String get serverReportSubmittedSuccessfully =>
      'ڕاپۆرتەکە بە سەرکەوتوویی نێردرا.';

  @override
  String get serverRequestNotFound => 'داواکارییەکە نەدۆزرایەوە.';

  @override
  String get serverThatFileDoesNotLookLikeAn =>
      'ئەم فایلە وەک وێنەیەک ناخوێنرێتەوە.';

  @override
  String get serverTheMessageYouAreReplyingToIs =>
      'ئەو نامەیەی وەڵامی دەدەیتەوە لەم گفتوگۆیەدا نییە.';

  @override
  String get serverThisAccountHasBeenSuspendedContactSupport =>
      'ئەم هەژمارە ڕاگیراوە. ئەگەر پێت وایە هەڵەیە، پەیوەندی بە پشتگیری بکە.';

  @override
  String get serverThisUserDoesNotAcceptDirectMessages =>
      'ئەم بەکارهێنەرە نامەی ڕاستەوخۆ وەرناگرێت.';

  @override
  String get serverTooManyLocationLookupsPleaseSlowDown =>
      'گەڕانی شوێن زۆرە. تکایە کەمێک بوەستە.';

  @override
  String get serverUserBlockedSuccessfully => 'بەکارهێنەر بلۆک کرا.';

  @override
  String get serverUserNotFound => 'بەکارهێنەر نەدۆزرایەوە.';

  @override
  String get serverUserUnblockedSuccessfully => 'بلۆکی بەکارهێنەر لابرا.';

  @override
  String get serverVerificationCodeHasExpiredPleaseRequestA =>
      'کۆدی پشتڕاستکردنەوە بەسەرچووە. تکایە داوای کۆدێکی نوێ بکە.';

  @override
  String get serverVerificationCodeIsValid => 'کۆدی پشتڕاستکردنەوە دروستە.';

  @override
  String get serverVerificationCodeResentSuccessfully =>
      'کۆدی پشتڕاستکردنەوە دووبارە نێردرایەوە.';

  @override
  String get serverVerificationCodeSentSuccessfully =>
      'کۆدی پشتڕاستکردنەوە نێردرا.';

  @override
  String get serverYouAlreadyHaveAVerificationRequestUnder =>
      'پێشتر داواکارییەکی پشتڕاستکردنەوەت لە ژێر پێداچوونەوەدایە.';

  @override
  String get serverYouAlreadyReportedThisPost =>
      'پێشتر ڕاپۆرتی ئەم پۆستەت کردووە.';

  @override
  String get serverYouAreNotAParticipantInThis =>
      'تۆ بەشداری ئەم گفتوگۆیە نیت.';

  @override
  String get serverYouAreNotAParticipant => 'تۆ بەشدار نیت.';

  @override
  String get serverYouCanOnlyDeleteYourOwnMessages =>
      'تەنها دەتوانیت نامەکانی خۆت بسڕیتەوە.';

  @override
  String get serverYouCannotBlockYourself => 'ناتوانیت خۆت بلۆک بکەیت.';

  @override
  String get serverYouCannotDeleteYourOwnAccountHere =>
      'ناتوانیت لێرەوە هەژماری خۆت بسڕیتەوە.';

  @override
  String get serverYouCannotMessageThisUser =>
      'ناتوانیت نامە بۆ ئەم بەکارهێنەرە بنێریت.';

  @override
  String get serverYouCannotMessageYourself => 'ناتوانیت نامە بۆ خۆت بنێریت.';

  @override
  String get serverYouCannotRemoveYourOwnAdminRole =>
      'ناتوانیت ڕۆڵی بەڕێوەبەری خۆت لابەیت.';

  @override
  String get serverYouCannotSuspendYourOwnAccount =>
      'ناتوانیت هەژماری خۆت ڕابگریت.';

  @override
  String get serverYouDoNotOwnThisPost => 'ئەم پۆستە هی تۆ نییە.';

  @override
  String get serverYourAccountAndDataHaveBeenDeleted =>
      'هەژمار و زانیارییەکانت سڕانەوە.';

  @override
  String get serverYourIdentityIsAlreadyVerified =>
      'ناسنامەکەت پێشتر پشتڕاستکراوەتەوە.';

  @override
  String get serverThisRequestWasAlreadyHandled =>
      'ئەم داواکارییە پێشتر یەکلا کراوەتەوە.';

  @override
  String get serverRequestNotValid => 'داواکارییەکە دروست نییە.';

  @override
  String get serverSessionExpired =>
      'دانیشتنەکەت بەسەرچوو. تکایە دووبارە بچۆرە ژوورەوە.';

  @override
  String get serverNotAllowed => 'ڕێگەت پێنەدراوە ئەوە بکەیت.';

  @override
  String get serverProblem =>
      'ڕاژەکار تووشی کێشە بوو. تکایە دووبارە هەوڵ بدەرەوە.';

  @override
  String serverRequestFailed(int status) {
    return 'داواکاری سەرکەوتوو نەبوو ($status).';
  }

  @override
  String get serverTimeout =>
      'ڕاژەکار زۆری پێچوو بۆ وەڵامدانەوە. پەیوەندییەکەت بپشکنە و دووبارە هەوڵ بدەرەوە.';

  @override
  String get serverOffline =>
      'وا دیارە ئۆفلاینیت. پەیوەندییەکەت بپشکنە و دووبارە هەوڵ بدەرەوە.';

  @override
  String get serverThisPostIsAwaitingReview =>
      'ئەم پۆستە چاوەڕێی پێداچوونەوەیە.';

  @override
  String get serverApproveOrRejectThisPostFirst =>
      'سەرەتا ئەم پۆستە پەسەند بکە یان ڕەتی بکەرەوە.';

  @override
  String get serverCouldNotApproveThePost => 'پۆستەکە پەسەند نەکرا.';

  @override
  String get serverCouldNotRejectThePost => 'پۆستەکە ڕەت نەکرایەوە.';

  @override
  String get serverThatStatusIsNotPublic => 'ئەو دۆخە گشتی نییە.';

  @override
  String get serverNotAnApiKey => 'ئەمە وەک کلیلی API دیار نییە.';

  @override
  String get serverProviderRejectedTheKey => 'دابینکەرەکە کلیلەکەی ڕەتکردەوە.';

  @override
  String get serverModelNotFound => 'مۆدێلەکە نەدۆزرایەوە.';

  @override
  String get serverModelNameRequired => 'ناوی مۆدێل پێویستە.';

  @override
  String get serverBaseUrlRequired =>
      'لینکی بنەڕەتی و ناوی مۆدێل بۆ دابینکەری تایبەت پێویستن.';

  @override
  String get serverCouldNotReachProvider => 'نەتوانرا بگاتە دابینکەری AI.';

  @override
  String get serverCouldNotLoadAiSettings =>
      'نەتوانرا ڕێکخستنەکانی AI باربکرێن.';

  @override
  String get serverCouldNotRemoveAiSettings =>
      'نەتوانرا ڕێکخستنەکانی AI لاببرێن.';
}
