// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Finder';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonRemove => 'إزالة';

  @override
  String get commonDiscard => 'تجاهل';

  @override
  String get commonDone => 'تم';

  @override
  String get commonOk => 'حسنًا';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonTryAgain => 'حاول مرة أخرى';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonOpen => 'فتح';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonReport => 'إبلاغ';

  @override
  String get commonBlock => 'حظر';

  @override
  String get commonUnblock => 'إلغاء الحظر';

  @override
  String get commonSend => 'إرسال';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonSaving => 'جارٍ الحفظ…';

  @override
  String get commonSending => 'جارٍ الإرسال…';

  @override
  String get commonUploading => 'جارٍ الرفع…';

  @override
  String get commonSeeAll => 'عرض الكل';

  @override
  String get commonViewProfile => 'عرض الملف الشخصي';

  @override
  String get commonMoreOptions => 'خيارات إضافية';

  @override
  String get commonLogOut => 'تسجيل الخروج';

  @override
  String get commonLost => 'مفقود';

  @override
  String get commonFound => 'معثور عليه';

  @override
  String get commonReturned => 'تمت إعادته';

  @override
  String get commonMarkAsReturned => 'تحديد كمُعاد لصاحبه';

  @override
  String get commonMarkedAsReturned => 'تم تحديده كمُعاد لصاحبه.';

  @override
  String get commonReopen => 'إعادة فتح';

  @override
  String get commonPosts => 'المنشورات';

  @override
  String get commonMessages => 'الرسائل';

  @override
  String get commonNotifications => 'الإشعارات';

  @override
  String get commonProfile => 'الملف الشخصي';

  @override
  String get commonHome => 'الرئيسية';

  @override
  String get commonLocation => 'الموقع';

  @override
  String get commonLocationNotSpecified => 'الموقع غير محدد';

  @override
  String get commonFinderUser => 'مستخدم Finder';

  @override
  String get commonYou => 'أنت';

  @override
  String get commonSomethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String commonUploadFailed(String detail) {
    return 'فشل الرفع. $detail';
  }

  @override
  String get commonCopied => 'تم النسخ.';

  @override
  String get commonJustNow => 'الآن';

  @override
  String commonMinutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String commonHoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String commonDaysAgo(int count) {
    return 'منذ $count ي';
  }

  @override
  String commonWeeksAgo(int count) {
    return 'منذ $count أ';
  }

  @override
  String get commonToday => 'اليوم';

  @override
  String get commonYesterday => 'أمس';

  @override
  String commonMonthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'كانون الثاني',
      '2': 'شباط',
      '3': 'آذار',
      '4': 'نيسان',
      '5': 'أيار',
      '6': 'حزيران',
      '7': 'تموز',
      '8': 'آب',
      '9': 'أيلول',
      '10': 'تشرين الأول',
      '11': 'تشرين الثاني',
      '12': 'كانون الأول',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String commonWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'الاثنين',
      '2': 'الثلاثاء',
      '3': 'الأربعاء',
      '4': 'الخميس',
      '5': 'الجمعة',
      '6': 'السبت',
      '7': 'الأحد',
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
  String get languageTitle => 'اللغة';

  @override
  String get languageSubtitle => 'اختر اللغة التي يستخدمها Finder';

  @override
  String get languageSystem => 'استخدام لغة الهاتف';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageKurdish => 'کوردی';

  @override
  String get languageChanged => 'تم تغيير اللغة.';

  @override
  String get authLoginTitle => 'مرحبًا بعودتك';

  @override
  String get authLoginSubtitle => 'سجّل الدخول لتواصل العثور على ما يهمّك.';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHint => 'كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authSignIn => 'تسجيل الدخول';

  @override
  String get authOrContinueWith => 'أو المتابعة عبر';

  @override
  String get authContinueWithGoogle => 'المتابعة عبر Google';

  @override
  String get authNoAccountPrompt => 'ليس لديك حساب؟';

  @override
  String get authSignUp => 'إنشاء حساب';

  @override
  String get authInvalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get authPasswordMin6 =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get authSignupTitle => 'أنشئ حسابك';

  @override
  String get authSignupSubtitle =>
      'أبلغ عن المفقودات والموجودات وتابعها مع المجتمع.';

  @override
  String get authEmailAddressLabel => 'عنوان البريد الإلكتروني';

  @override
  String get authEmailAddressHint => 'yourname@example.com';

  @override
  String get authNameLabel => 'اسمك';

  @override
  String get authNameHint => 'بماذا نناديك؟';

  @override
  String get authPhoneLabel => 'رقم الهاتف';

  @override
  String get authPhoneHint => '+964 750 000 0000';

  @override
  String get authSignupPasswordHint => '8 أحرف على الأقل';

  @override
  String get authPasswordRule => 'استخدم 8 أحرف على الأقل تتضمن حرفًا ورقمًا.';

  @override
  String get authCreateAccount => 'إنشاء الحساب';

  @override
  String get authOrSignUpWith => 'أو التسجيل عبر';

  @override
  String get authSignUpWithGoogle => 'التسجيل عبر Google';

  @override
  String get authHaveAccountPrompt => 'لديك حساب بالفعل؟';

  @override
  String get authLogIn => 'تسجيل الدخول';

  @override
  String get authForgotInvalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get authForgotCodeSent => 'تم إرسال رمز التحقق! تحقق من بريدك الوارد.';

  @override
  String get authForgotCodeResent =>
      'تم إرسال رمز تحقق جديد! تحقق من بريدك الوارد.';

  @override
  String get authForgotEnterNumericCode =>
      'يرجى إدخال رمز التحقق المكوّن من 6 أرقام';

  @override
  String get authForgotCodeVerified => 'تم التحقق من الرمز بنجاح!';

  @override
  String get authForgotPasswordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authForgotPasswordUpdated =>
      'تم تحديث كلمة المرور بنجاح! يرجى تسجيل الدخول.';

  @override
  String get authForgotTitle => 'نسيت كلمة المرور';

  @override
  String get authForgotSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق من 6 أرقام.';

  @override
  String get authForgotCheckInboxTitle => 'تحقق من بريدك الوارد';

  @override
  String authForgotCheckInboxSubtitle(String email) {
    return 'أدخل رمز التحقق المكوّن من 6 أرقام المرسل إلى $email.';
  }

  @override
  String get authForgotNewPasswordTitle => 'عيّن كلمة مرور جديدة';

  @override
  String get authForgotNewPasswordSubtitle =>
      'أنشئ كلمة مرور جديدة وآمنة لحسابك.';

  @override
  String get authForgotSendCode => 'إرسال رمز التحقق';

  @override
  String get authForgotCancelAndLogIn => 'إلغاء وتسجيل الدخول';

  @override
  String get authVerificationCodeLabel => 'رمز التحقق';

  @override
  String get authVerificationCodeHint => 'رمز من 6 أرقام';

  @override
  String get authVerifyCode => 'تحقق من الرمز';

  @override
  String get authChangeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get authResendCode => 'إعادة إرسال الرمز';

  @override
  String get authNewPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get authNewPasswordHint => '6 أحرف على الأقل';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور الجديدة';

  @override
  String get authConfirmPasswordHint => 'أعد كتابة كلمة المرور الجديدة';

  @override
  String get authResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get authStartOver => 'البدء من جديد / تغيير البريد';

  @override
  String get authVerifyEnterCode => 'يرجى إدخال رمز التحقق المكوّن من 6 أرقام.';

  @override
  String get authVerifiedWelcome => 'تم توثيق الحساب. أهلًا بك في Finder!';

  @override
  String get authVerifyCodeResent =>
      'تم إرسال رمز تحقق جديد إلى بريدك الإلكتروني.';

  @override
  String get authVerifyTitle => 'وثّق بريدك الإلكتروني';

  @override
  String get authVerifySubtitle =>
      'أرسلنا رمز تحقق من 6 أرقام إلى بريدك الإلكتروني المسجّل. أدخله أدناه لتفعيل حسابك.';

  @override
  String get authVerifyAccount => 'توثيق الحساب';

  @override
  String get authGoogleCancelled => 'تم إلغاء تسجيل الدخول عبر Google.';

  @override
  String get authGoogleTokenFailed =>
      'تعذّر الحصول على بيانات تسجيل الدخول من Google.';

  @override
  String get authSessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get authSocialSemantic => 'المتابعة عبر حساب اجتماعي';

  @override
  String get authLegalAgreePrefix => 'بإنشاء حساب فإنك توافق على ';

  @override
  String get authLegalAgreeAnd => ' و';

  @override
  String get authLegalAgreeSuffix => '.';

  @override
  String get onboardLostTitle => 'فقدت شيئًا؟';

  @override
  String get onboardLostDescription =>
      'أبلغ عن أغراضك المفقودة في ثوانٍ. يربط Finder الأغراض الموجودة بأصحابها فورًا.';

  @override
  String get onboardFoundTitle => 'وجدت شيئًا؟';

  @override
  String get onboardFoundDescription =>
      'انشر الأغراض التي وجدتها وساعد في إعادتها إلى أصحابها. كل عمل طيب له قيمة.';

  @override
  String get onboardConnectTitle => 'تواصل\nوتحاور';

  @override
  String get onboardConnectDescription =>
      'تحدث، شارك التفاصيل، وأعد الأغراض بأمان. ابنِ الثقة داخل المجتمع.';

  @override
  String get onboardGetStarted => 'ابدأ الآن';

  @override
  String get onboardSkipForNow => 'التخطي الآن';

  @override
  String get onboardRewardSample => 'مكافأة 50\$';

  @override
  String get onboardTrustSecured => 'ثقة مضمونة';

  @override
  String get legalOpenWebVersion => 'فتح نسخة الويب';

  @override
  String legalCouldNotOpen(String url) {
    return 'تعذّر فتح $url';
  }

  @override
  String get legalPrivacyTitle => 'سياسة الخصوصية';

  @override
  String get legalTermsTitle => 'شروط الخدمة';

  @override
  String get legalUpdated => 'آخر تحديث: 13 أيلول 2026';

  @override
  String get legalPrivacyIntro =>
      'يساعد Finder الناس على الإبلاغ عن المفقودات والموجودات والتواصل فيما بينهم. توضح هذه السياسة البيانات التي يجمعها التطبيق، وسبب جمعها، وما تملكه من تحكم فيها.';

  @override
  String get legalPrivacy1Heading => '1. البيانات التي نجمعها';

  @override
  String get legalPrivacy1Body1 =>
      'بيانات الحساب: البريد الإلكتروني، كلمة المرور (تُخزَّن مشفّرة)، الاسم، الاسم المستعار، واختياريًا الهاتف والمدينة والمهنة.';

  @override
  String get legalPrivacy1Body2 =>
      'المنشورات: العنوان، الوصف، الفئة، نص الموقع، التاريخ، والصور التي ترفقها.';

  @override
  String get legalPrivacy1Body3 =>
      'الرسائل: النصوص والصور التي تتبادلها مع الأعضاء الآخرين.';

  @override
  String get legalPrivacy1Body4 =>
      'توثيق الهوية (اختياري): صور لوثيقة هوية وصورة شخصية، تُستخدم فقط لمنح شارة التوثيق.';

  @override
  String get legalPrivacy1Body5 =>
      'بيانات تقنية: سجلات الطلبات (عنوان IP، نقطة الاتصال، الوقت) تُحفظ لأغراض الأمان، إضافة إلى تقارير أعطال مجهولة وإحصاءات استخدام (الشاشات المستخدمة، وليس محتوى المنشورات أو الرسائل أبدًا).';

  @override
  String get legalPrivacy1Body6 =>
      'تسجيل الدخول عبر Google: نتلقى بريدك الإلكتروني واسمك وصورة ملفك من Google.';

  @override
  String get legalPrivacy2Heading => '2. كيف نستخدمها';

  @override
  String get legalPrivacy2Body1 =>
      'لتشغيل الخدمة: عرض المنشورات، وإيصال الرسائل والإشعارات، وتمكين الأعضاء من التواصل. للحفاظ على سلامة المجتمع: البلاغات والحظر وتوثيق الهوية. لإرسال رسائل البريد الضرورية مثل رموز التحقق وإعادة تعيين كلمة المرور. لا تُرسل أخبار المنتج إلا إذا اشتركت فيها.';

  @override
  String get legalPrivacy2Body2 =>
      'لا نبيع البيانات الشخصية ولا نعرض إعلانات من أطراف ثالثة.';

  @override
  String get legalPrivacy3Heading => '3. ما يمكن للأعضاء الآخرين رؤيته';

  @override
  String get legalPrivacy3Body =>
      'اسمك وصورتك ومنشوراتك مرئية للأعضاء المسجّلين. رقم هاتفك مخفي ما لم تفعّل مشاركته من الخصوصية والأمان. بريدك الإلكتروني لا يُعرض أبدًا للأعضاء الآخرين. الأعضاء الذين تحظرهم لا يمكنهم رؤية منشوراتك أو مراسلتك.';

  @override
  String get legalPrivacy4Heading => '4. أين تُخزَّن البيانات';

  @override
  String get legalPrivacy4Body =>
      'تُخزَّن البيانات على خوادم مزوّد الاستضافة والصور على Cloudinary، وكلاهما وفق شروط معالجة البيانات الخاصة به. تُنقل البيانات عبر HTTPS.';

  @override
  String get legalPrivacy5Heading => '5. مدة الاحتفاظ بالبيانات';

  @override
  String get legalPrivacy5Body =>
      'تُحفظ بيانات الحساب ما دام حسابك موجودًا. تُحذف وثائق التوثيق فور اتخاذ القرار، وبما لا يتجاوز 90 يومًا من رفعها. تُحفظ سجلات الطلبات لمدة 30 يومًا.';

  @override
  String get legalPrivacy6Heading => '6. حقوقك';

  @override
  String get legalPrivacy6Body1 =>
      'الوصول والتصحيح: عدّل ملفك الشخصي في التطبيق في أي وقت.';

  @override
  String get legalPrivacy6Body2 =>
      'الحذف: احذف حسابك من الخصوصية والأمان ← حذف الحساب. تُزال منشوراتك ومحادثاتك وإعداداتك وملفك فورًا، وتنتهي النسخ الاحتياطية خلال 30 يومًا.';

  @override
  String get legalPrivacy6Body3 =>
      'نقل البيانات والاستفسارات: راسلنا على privacy@finder.app.';

  @override
  String get legalPrivacy7Heading => '7. الأطفال';

  @override
  String get legalPrivacy7Body =>
      'Finder غير موجّه للأطفال دون 16 عامًا. نزيل الحسابات التي نعلم أنها تعود لأطفال.';

  @override
  String get legalPrivacy8Heading => '8. التغييرات';

  @override
  String get legalPrivacy8Body =>
      'سنعلن عن أي تغييرات جوهرية داخل التطبيق قبل سريانها. يوضح التاريخ في الأعلى آخر مراجعة لهذه السياسة.';

  @override
  String get legalTermsIntro =>
      'بإنشاء حساب أو استخدام Finder فإنك توافق على هذه الشروط. إذا كنت لا توافق، فلا تستخدم الخدمة.';

  @override
  String get legalTerms1Heading => '1. الخدمة';

  @override
  String get legalTerms1Body =>
      'Finder لوحة إعلانات مجتمعية للمفقودات والموجودات. نوفّر المكان للنشر والتحدث؛ ولا نشارك في عمليات التسليم، ولا نتحقق من أن غرضًا ما يخص عضوًا معيّنًا، ولسنا طرفًا في أي اتفاق مكافأة بين الأعضاء.';

  @override
  String get legalTerms2Heading => '2. حسابك';

  @override
  String get legalTerms2Body =>
      'يجب أن يكون عمرك 16 عامًا على الأقل. حافظ على سرية كلمة مرورك؛ فأنت مسؤول عن النشاط في حسابك. شخص واحد، حساب واحد. لا تنتحل شخصية الآخرين.';

  @override
  String get legalTerms3Heading => '3. محتواك';

  @override
  String get legalTerms3Body =>
      'تحتفظ بملكية ما تنشره. وتمنح Finder ترخيصًا لتخزينه وعرضه وتوزيعه داخل الخدمة ليتمكن الأعضاء الآخرون من رؤيته. انشر فقط الصور والمعلومات التي يحق لك مشاركتها.';

  @override
  String get legalTerms4Heading => '4. قواعد السلوك';

  @override
  String get legalTerms4Body1 =>
      'يُحظر عليك: نشر بلاغات كاذبة أو ادعاء ملكية غرض ليس لك؛ طلب المال قبل إعادة الغرض أو استخدام الخدمة للاحتيال؛ مضايقة الأعضاء الآخرين أو تهديدهم أو التمييز ضدهم؛ نشر محتوى غير قانوني أو ينتهك حقوق الآخرين؛ استخراج بيانات الخدمة أو اختبار واجهتها البرمجية أو التدخل في تشغيلها.';

  @override
  String get legalTerms4Body2 =>
      'يجوز لنا إزالة المحتوى، وتعليق أو حذف الحسابات التي تخالف هذه القواعد، والتعاون مع الجهات القانونية عند الاقتضاء.';

  @override
  String get legalTerms5Heading => '5. السلامة';

  @override
  String get legalTerms5Body =>
      'التقِ في أماكن عامة، واصطحب شخصًا معك، ولا تدفع أي مكافأة قبل استلام غرضك. استخدم محادثة التطبيق لتتمكن من الحظر والإبلاغ. لا يمكن لـ Finder ضمان أمانة أي عضو.';

  @override
  String get legalTerms6Heading => '6. توثيق الهوية';

  @override
  String get legalTerms6Body =>
      'تعني شارة التوثيق أن العضو قدّم وثيقة هوية راجعها فريقنا. وهي ليست ضمانًا للهوية أو حسن النية.';

  @override
  String get legalTerms7Heading => '7. التوفر والتغييرات';

  @override
  String get legalTerms7Body =>
      'يجوز لنا تغيير الميزات أو إيقافها في أي وقت. نسعى لإبقاء الخدمة متاحة لكننا لا نعد بتشغيل دون انقطاع.';

  @override
  String get legalTerms8Heading => '8. المسؤولية';

  @override
  String get legalTerms8Body =>
      'في الحدود التي يسمح بها القانون، يُقدَّم Finder \"كما هو\" ولسنا مسؤولين عن الخسائر الناتجة عن استخدامك للخدمة، أو عن سلوك الأعضاء الآخرين، أو عن الأغراض التي لا يتم استردادها.';

  @override
  String get legalTerms9Heading => '9. الإنهاء';

  @override
  String get legalTerms9Body =>
      'يمكنك حذف حسابك في أي وقت من الخصوصية والأمان. ويمكننا إنهاء الحسابات التي تخالف هذه الشروط.';

  @override
  String get legalTerms10Heading => '10. التواصل';

  @override
  String get legalTerms10Body => 'للاستفسار عن هذه الشروط: support@finder.app';

  @override
  String get adminConsoleTitle => 'لوحة الإشراف';

  @override
  String get adminConsoleSubtitle => 'المستخدمون والمنشورات والبلاغات والتوثيق';

  @override
  String get adminModeration => 'الإشراف';

  @override
  String get adminUsersTitle => 'المستخدمون';

  @override
  String get adminUsersTileSubtitle =>
      'البحث والتوثيق والتعليق والترقية وحذف الحسابات';

  @override
  String get adminPostsTileSubtitle =>
      'كل منشورات المفقودات والموجودات، المفتوحة والمُعادة';

  @override
  String get adminReportsTitle => 'البلاغات';

  @override
  String get adminReportsSubtitle => 'المنشورات التي أبلغ عنها الأعضاء';

  @override
  String get adminVerificationTitle => 'توثيق الهوية';

  @override
  String get adminVerificationTileSubtitle => 'مراجعة الوثائق والصور الشخصية';

  @override
  String get adminStatMembers => 'الأعضاء';

  @override
  String get adminVerifiedLabel => 'موثّق';

  @override
  String get adminStatOpenPosts => 'منشورات مفتوحة';

  @override
  String get adminStatToVerify => 'بانتظار التوثيق';

  @override
  String get adminSuspendedLabel => 'معلّق';

  @override
  String get adminStatMessages24h => 'رسائل آخر 24 س';

  @override
  String get adminPostsSubtitle => 'كل ما في الصفحة الرئيسية';

  @override
  String get adminPostsSearchHint => 'العنوان أو الوصف أو المالك';

  @override
  String get adminFilterAll => 'الكل';

  @override
  String get adminFilterOpen => 'مفتوح';

  @override
  String get adminFilterReported => 'مُبلَّغ عنه';

  @override
  String get adminFilterHandled => 'تمت معالجته';

  @override
  String get adminFilterAdmins => 'المشرفون';

  @override
  String get adminFilterPending => 'قيد الانتظار';

  @override
  String get adminFilterApproved => 'مقبول';

  @override
  String get adminFilterRejected => 'مرفوض';

  @override
  String get adminNoPostsHere => 'لا توجد منشورات هنا';

  @override
  String adminPostSheetSubtitle(String owner, String status) {
    return 'بواسطة $owner · $status';
  }

  @override
  String get adminStatusReturned => 'تمت إعادته';

  @override
  String get adminStatusOpen => 'مفتوح';

  @override
  String get adminOpenThePost => 'فتح المنشور';

  @override
  String get adminReopenThePost => 'إعادة فتح المنشور';

  @override
  String get adminPostReopened => 'تمت إعادة فتح المنشور.';

  @override
  String get adminRemoveThePost => 'إزالة المنشور';

  @override
  String get adminRemovePostOwnerNotified =>
      'يتم إشعار المالك بالسبب الذي تذكره';

  @override
  String get adminPostRemoved => 'تمت إزالة المنشور.';

  @override
  String get adminRemovePostTitle => 'إزالة هذا المنشور؟';

  @override
  String get adminRemovePostReasonSubtitle => 'يُرسل سبب مختصر إلى المالك.';

  @override
  String get adminReasonOptionalLabel => 'السبب (اختياري)';

  @override
  String get adminReasonPostHint => 'مثال: ليس غرضًا مفقودًا أو موجودًا';

  @override
  String get adminNoOpenReports => 'لا توجد بلاغات مفتوحة';

  @override
  String get adminNothingHandledYet => 'لم تتم معالجة أي بلاغ بعد';

  @override
  String get adminBadgeOpen => 'مفتوح';

  @override
  String get adminBadgeHandled => 'تمت المعالجة';

  @override
  String get adminNoReasonGiven => 'لم يُذكر سبب';

  @override
  String adminQuotedReason(String reason) {
    return '\"$reason\"';
  }

  @override
  String adminReportedBy(String name, String time) {
    return 'أبلغ عنه $name · $time';
  }

  @override
  String adminPostBySuffix(String name) {
    return ' · منشور بواسطة $name';
  }

  @override
  String get adminDismissReport => 'رفض البلاغ';

  @override
  String get adminPostStaysUp => 'يبقى المنشور منشورًا';

  @override
  String get adminRemovePostSettles =>
      'يغلق كل البلاغات عليه؛ ويتم إشعار المالك';

  @override
  String adminRemovePostConfirmBody(String title) {
    return 'سيتم حذف \"$title\" ومحادثاته. لا يمكن التراجع عن هذا.';
  }

  @override
  String get adminReportDismissed => 'تم رفض البلاغ.';

  @override
  String get adminUsersSubtitle => 'الحسابات على Finder';

  @override
  String get adminUsersSearchHint => 'الاسم أو الاسم المستعار أو البريد';

  @override
  String get adminNoAccountsMatch => 'لا توجد حسابات مطابقة';

  @override
  String get adminRemoveVerifiedBadge => 'إزالة شارة التوثيق';

  @override
  String get adminMarkAsVerified => 'تحديد كموثّق';

  @override
  String get adminRemoveBadgeSubtitle => 'تختفي العلامة من ملفه ومنشوراته';

  @override
  String get adminGrantBadgeSubtitle => 'يمنح العلامة دون مراجعة وثيقة';

  @override
  String get adminVerifiedBadgeRemoved => 'تمت إزالة شارة التوثيق.';

  @override
  String get adminMarkedAsVerified => 'تم التحديد كموثّق.';

  @override
  String get adminRemoveAdminRole => 'إزالة صلاحية المشرف';

  @override
  String get adminMakeAdministrator => 'تعيين كمشرف';

  @override
  String get adminLoseConsoleAccess => 'يفقد الوصول إلى هذه اللوحة';

  @override
  String get adminFullAccess => 'وصول كامل إلى المستخدمين والمنشورات والبلاغات';

  @override
  String get adminRemoveAdminRoleTitle => 'إزالة صلاحية المشرف؟';

  @override
  String adminMakeAdminTitle(String name) {
    return 'تعيين $name مشرفًا؟';
  }

  @override
  String adminRemoveAdminBody(String name) {
    return 'لن يتمكن $name من الإشراف على Finder بعد الآن.';
  }

  @override
  String get adminMakeAdminBody =>
      'يمكن للمشرفين تعليق أو حذف أي حساب وإزالة أي منشور.';

  @override
  String get adminRemoveRole => 'إزالة الصلاحية';

  @override
  String get adminMakeAdmin => 'تعيين مشرفًا';

  @override
  String get adminRoleRemoved => 'تمت إزالة صلاحية المشرف.';

  @override
  String adminNowAdmin(String name) {
    return '$name أصبح مشرفًا الآن.';
  }

  @override
  String get adminLiftSuspension => 'رفع التعليق';

  @override
  String get adminSuspendAccount => 'تعليق الحساب';

  @override
  String get adminCanSignInAgain => 'يمكنه تسجيل الدخول مجددًا';

  @override
  String get adminSignedOutCannotSignIn => 'يتم تسجيل خروجه ولا يمكنه الدخول';

  @override
  String get adminLiftSuspensionTitle => 'رفع التعليق؟';

  @override
  String adminSuspendTitle(String name) {
    return 'تعليق $name؟';
  }

  @override
  String get adminLiftBody => 'يعود الحساب للعمل بشكل طبيعي.';

  @override
  String get adminSuspendBody =>
      'تبقى منشوراته مرئية. يفقد الوصول حتى ترفع التعليق.';

  @override
  String get adminLift => 'رفع';

  @override
  String get adminSuspend => 'تعليق';

  @override
  String get adminSuspensionLifted => 'تم رفع التعليق.';

  @override
  String get adminAccountSuspended => 'تم تعليق الحساب.';

  @override
  String get adminDeleteAccount => 'حذف الحساب';

  @override
  String get adminDeleteAccountSubtitle =>
      'يزيل الحساب ومنشوراته ومحادثاته. لا يمكن التراجع عن هذا.';

  @override
  String adminDeleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get adminDeleteBody =>
      'يُمحى كل ما نشره وكل محادثة شارك فيها نهائيًا.';

  @override
  String get adminAccountDeleted => 'تم حذف الحساب.';

  @override
  String adminYouSuffix(String name) {
    return '$name (أنت)';
  }

  @override
  String adminPostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور',
      many: '$count منشورًا',
      few: '$count منشورات',
      two: 'منشوران',
      one: 'منشور واحد',
      zero: 'لا منشورات',
    );
    return '$_temp0';
  }

  @override
  String adminReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بلاغ',
      many: '$count بلاغًا',
      few: '$count بلاغات',
      two: 'بلاغان',
      one: 'بلاغ واحد',
      zero: 'لا بلاغات',
    );
    return '$_temp0';
  }

  @override
  String adminJoined(String time) {
    return 'انضم $time';
  }

  @override
  String get adminBadgeSuspended => 'معلّق';

  @override
  String get adminQueueTitle => 'قائمة المراجعة';

  @override
  String get adminQueueSubtitle => 'طلبات توثيق الهوية';

  @override
  String get adminNothingToReview => 'لا شيء للمراجعة';

  @override
  String get adminNoRequestsHere => 'لا توجد طلبات هنا';

  @override
  String get adminNewRequestsShowHere => 'ستظهر طلبات التوثيق الجديدة هنا.';

  @override
  String get adminBadgeRejected => 'مرفوض';

  @override
  String get adminBadgePending => 'قيد الانتظار';

  @override
  String get adminDocIdCard => 'بطاقة هوية';

  @override
  String get adminDocDriversLicense => 'رخصة قيادة';

  @override
  String get adminDocPassport => 'جواز سفر';

  @override
  String get adminDocDocument => 'وثيقة';

  @override
  String adminSubmitted(String doc, String time) {
    return '$doc · أُرسل $time';
  }

  @override
  String adminReviewedStatus(String status, String time) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'approved': 'قُبل $time',
      'rejected': 'رُفض $time',
      'other': '$status $time',
    });
    return '$_temp0';
  }

  @override
  String adminReasonPrefix(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get adminDocumentSection => 'الوثيقة';

  @override
  String get adminStep1 => 'الخطوة 1';

  @override
  String get adminLiveSelfie => 'صورة شخصية مباشرة';

  @override
  String get adminStep2 => 'الخطوة 2';

  @override
  String get adminFrontOfId => 'وجه الهوية';

  @override
  String get adminPhotoPage => 'صفحة الصورة';

  @override
  String get adminBackOfId => 'ظهر الهوية';

  @override
  String get adminSelfieCaption => 'صورة شخصية ملتقطة بالكاميرا الأمامية';

  @override
  String get adminReviewGuidance =>
      'قارن الوجه في الوثيقة بالصورة الشخصية، وتأكد من تطابق الاسم مع الحساب، ومن أن الوثيقة غير منتهية أو معدّلة.';

  @override
  String adminTapToZoom(String caption) {
    return '$caption · انقر للتكبير';
  }

  @override
  String get adminReject => 'رفض';

  @override
  String get adminApprove => 'قبول';

  @override
  String get adminApproveTitle => 'قبول هذه الهوية؟';

  @override
  String adminApproveBody(String name) {
    return 'يحصل $name على شارة التوثيق وإشعارًا بذلك.';
  }

  @override
  String get adminIdentityApproved => 'تم قبول الهوية.';

  @override
  String get adminRejectRequestTitle => 'رفض الطلب';

  @override
  String adminRejectReasonSubtitle(String name) {
    return 'يُرسل السبب إلى $name ليتمكن من تصحيحه.';
  }

  @override
  String get adminReasonLabel => 'السبب';

  @override
  String get adminRejectReasonHint =>
      'مثال: الصورة الشخصية داكنة جدًا لمقارنتها بالوثيقة.';

  @override
  String get adminRequestRejected => 'تم رفض الطلب.';

  @override
  String get stateErrorTitle => 'حدث خطأ ما';

  @override
  String get stateLoading => 'جارٍ التحميل';

  @override
  String get uiShowPassword => 'إظهار كلمة المرور';

  @override
  String get uiHidePassword => 'إخفاء كلمة المرور';

  @override
  String get uiCouldNotLoad => 'تعذّر التحميل';

  @override
  String get adminStatToApprove => 'بانتظار الموافقة';

  @override
  String get adminStatRejected => 'مرفوضة';

  @override
  String adminFilterPendingCount(int count) {
    return 'قيد الانتظار ($count)';
  }

  @override
  String get adminNothingToApprove => 'لا شيء بانتظار الموافقة';

  @override
  String get adminNothingToApproveBody =>
      'تظهر المنشورات الجديدة هنا قبل أن يراها أي شخص آخر.';

  @override
  String get adminReviewTitle => 'مراجعة هذا المنشور';

  @override
  String adminRiskLabel(int score) {
    return 'خطر الذكاء الاصطناعي $score';
  }

  @override
  String get adminRiskUnavailable => 'فحص الذكاء الاصطناعي غير متاح';

  @override
  String get adminRiskLow => 'يبدو سليمًا';

  @override
  String get adminRiskMedium => 'راجع بعناية';

  @override
  String get adminRiskHigh => 'يُرجّح رفضه';

  @override
  String adminOriginalText(String lang) {
    return 'النص الأصلي ($lang)';
  }

  @override
  String get adminRejectPostTitle => 'رفض هذا المنشور؟';

  @override
  String get adminRejectPostSubtitle =>
      'يُرسل السبب إلى المالك ليتمكن من تصحيحه وإعادة الإرسال.';

  @override
  String get adminRejectPostHint => 'مثال: الصورة لا تُظهر الغرض.';

  @override
  String get adminPostApproved =>
      'تمت الموافقة على المنشور. أصبح منشورًا الآن.';

  @override
  String get adminPostRejected => 'تم رفض المنشور. تم إبلاغ المالك.';

  @override
  String get adminStatusPending => 'قيد الانتظار';

  @override
  String get adminStatusRejected => 'مرفوض';

  @override
  String get adminStatusExpired => 'مؤرشف';

  @override
  String get adminAiTitle => 'مساعد الذكاء الاصطناعي';

  @override
  String get adminAiSubtitle => 'مفتاح Gemini للترجمة والفحص المسبق';

  @override
  String adminAiConfigured(String model) {
    return 'مُفعّل · $model';
  }

  @override
  String get adminAiNotConfigured =>
      'غير مُفعّل. لا تتم ترجمة المنشورات أو فحصها مسبقًا.';

  @override
  String get adminAiKeyLabel => 'مفتاح Google AI Studio';

  @override
  String get adminAiKeyHint => 'الصق المفتاح من aistudio.google.com';

  @override
  String get adminAiKeySaved => 'تم حفظ مفتاح الذكاء الاصطناعي والتحقق منه.';

  @override
  String get adminAiKeyBody =>
      'يُخزَّن المفتاح على الخادم فقط. يكلّف كل منشور جديد نحو سنت واحد للترجمة وفحص الخطر.';

  @override
  String get chatConversationTitle => 'المحادثة';

  @override
  String get chatNotFoundTitle => 'المحادثة غير موجودة';

  @override
  String get chatNotFoundSubtitle => 'افتح محادثة من منشور أو من الرسائل.';

  @override
  String get chatLoadingMessages => 'جارٍ تحميل الرسائل...';

  @override
  String chatSayHello(String name) {
    return 'ألقِ التحية على $name';
  }

  @override
  String get chatStartSubtitle => 'ابدأ المحادثة بإرسال رسالة.';

  @override
  String chatAskAbout(String item) {
    return 'اسأل عن \"$item\" أو رتّب تسليمًا آمنًا.';
  }

  @override
  String get chatDirectMessageViewProfile => 'رسالة مباشرة · عرض الملف الشخصي';

  @override
  String get chatDirectMessage => 'رسالة مباشرة';

  @override
  String chatAboutItem(String item) {
    return 'بخصوص \"$item\"';
  }

  @override
  String get chatReopenPost => 'إعادة فتح المنشور';

  @override
  String get chatReopenSubtitle => 'أظهره في الرئيسية مجددًا';

  @override
  String get chatReturnedSubtitle => 'عاد العنصر إلى صاحبه';

  @override
  String get chatViewPost => 'عرض المنشور';

  @override
  String get chatReportPost => 'الإبلاغ عن المنشور';

  @override
  String get chatPostReported => 'شكرًا، تم الإبلاغ عن المنشور.';

  @override
  String get chatReopenTitle => 'إعادة فتح هذا المنشور؟';

  @override
  String get chatMarkReturnedTitle => 'تحديد كمُعاد؟';

  @override
  String chatReopenBody(String item) {
    return 'سيظهر \"$item\" في الرئيسية مجددًا كمنشور مفتوح.';
  }

  @override
  String chatMarkReturnedBody(String item) {
    return 'سيختفي \"$item\" من الرئيسية لكنه يبقى ظاهرًا في البحث. سيصل تنبيه إلى الجميع في هذه المحادثة.';
  }

  @override
  String get chatPostReopened => 'تمت إعادة فتح المنشور.';

  @override
  String get chatAutoReopened => 'أعدت فتح هذا المنشور.';

  @override
  String get chatAutoReturned => 'حددت هذا العنصر كمُعاد. شكرًا لك!';

  @override
  String get chatYourMessage => 'رسالتك';

  @override
  String get chatMessage => 'رسالة';

  @override
  String get chatReply => 'رد';

  @override
  String get chatCopyText => 'نسخ النص';

  @override
  String get chatDeleteForEveryone => 'حذف لدى الجميع';

  @override
  String get chatDeleteTitle => 'حذف هذه الرسالة؟';

  @override
  String get chatDeleteBody =>
      'ستُحذف لدى الجميع في هذه المحادثة. لا يمكن التراجع عن هذا.';

  @override
  String get chatSendPhoto => 'إرسال صورة';

  @override
  String get chatWriteReplyHint => 'اكتب ردًا…';

  @override
  String get chatTypeMessageHint => 'اكتب رسالة…';

  @override
  String get chatMicPermission =>
      'اسمح بالوصول إلى الميكروفون لإرسال رسائل صوتية.';

  @override
  String get chatSendMessage => 'إرسال الرسالة';

  @override
  String get chatNotSent => 'لم تُرسل';

  @override
  String get chatYouSaid => 'أنت قلت';

  @override
  String get chatTheySaid => 'هو قال';

  @override
  String get chatCancelReply => 'إلغاء الرد';

  @override
  String chatNewCount(int count) {
    return '$count جديدة';
  }

  @override
  String get chatLatest => 'الأحدث';

  @override
  String get chatSignInToMessage => 'يرجى تسجيل الدخول لإرسال الرسائل.';

  @override
  String get chatOwnPost => 'هذا منشورك أنت.';

  @override
  String get chatOpenFailed => 'تعذّر فتح المحادثة.';

  @override
  String get chatLoadFailed => 'تعذّر تحميل الرسائل.';

  @override
  String get chatNotSentFailure => 'لم تُرسل الرسالة.';

  @override
  String get chatNothingToRetry => 'لا شيء لإعادة المحاولة.';

  @override
  String get chatDeleteFailed => 'تعذّر حذف الرسالة.';

  @override
  String get msgDeleted => 'تم حذف هذه الرسالة';

  @override
  String get msgVoiceMessage => 'رسالة صوتية';

  @override
  String get msgPhoto => 'صورة';

  @override
  String get msgNoMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get msgNewConversation => 'محادثة جديدة';

  @override
  String get msgNewChat => 'محادثة جديدة';

  @override
  String msgUnreadConversations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محادثة غير مقروءة',
      many: '$count محادثة غير مقروءة',
      few: '$count محادثات غير مقروءة',
      two: 'محادثتان غير مقروءتين',
      one: 'محادثة واحدة غير مقروءة',
      zero: 'لا محادثات غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String get msgSubtitle => 'تحدث بأمان مع المالكين ومن وجدوا الأغراض';

  @override
  String get msgSearchHint => 'ابحث في المحادثات…';

  @override
  String get msgLoading => 'جارٍ تحميل المحادثات...';

  @override
  String get msgNoConversations => 'لا توجد محادثات بعد';

  @override
  String get msgNoConversationsFound => 'لم يتم العثور على محادثات';

  @override
  String get msgEmptySubtitle =>
      'تواصل مع مالك أو من وجد الغرض من أي منشور، أو ابدأ محادثة جديدة.';

  @override
  String get msgTryAnother => 'جرّب اسمًا أو كلمة أخرى.';

  @override
  String notifUnreadCount(int count) {
    return '$count غير مقروءة';
  }

  @override
  String get notifCaughtUp => 'اطلعت على كل شيء';

  @override
  String get notifMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notifLoading => 'جارٍ تحميل الإشعارات...';

  @override
  String get notifEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get notifEmptySubtitle =>
      'سنخبرك عندما يراسلك أحد، أو يحدث نشاط على منشورك، أو يُعاد عنصر.';

  @override
  String get notifUnreadSemantics => 'إشعار غير مقروء';

  @override
  String get notifLoadingPreferences => 'جارٍ تحميل التفضيلات...';

  @override
  String get notifStayConnected => 'ابقَ على تواصل';

  @override
  String get notifStayConnectedBody =>
      'اختر اللحظات التي تنشئ إشعارًا. تُحفظ التغييرات فورًا.';

  @override
  String get notifAll => 'كل الإشعارات';

  @override
  String get notifAllMuted => 'كل شيء مكتوم';

  @override
  String get notifAllOff => 'إيقاف كل شيء دفعة واحدة';

  @override
  String get notifConversations => 'المحادثات';

  @override
  String get notifNewMessage => 'رسالة جديدة';

  @override
  String get notifNewMessageSubtitle => 'عندما يراسلك أحد بخصوص منشور';

  @override
  String get notifSmartMatching => 'المطابقة الذكية';

  @override
  String get notifItemMatch => 'تنبيهات تطابق العناصر';

  @override
  String get notifItemMatchSubtitle =>
      'عندما يشبه منشور جديد شيئًا فقدته أو وجدته';

  @override
  String get notifSmartBadge => 'ذكي';

  @override
  String get notifPostUpdates => 'تحديثات المنشورات';

  @override
  String get notifPostUpdatesSubtitle => 'عندما يُعاد عنصر تحدثت بشأنه';

  @override
  String get notifFromFinder => 'من Finder';

  @override
  String get notifTips => 'نصائح وأخبار';

  @override
  String get notifTipsSubtitle => 'تحديثات متفرقة عن المنتج. متوقفة افتراضيًا.';

  @override
  String get notifEmailCopies => 'نسخ بالبريد الإلكتروني';

  @override
  String get notifEmailCopiesSubtitle => 'إرسال الإشعارات المهمة بالبريد أيضًا';

  @override
  String get notifFooter =>
      'تصل الإشعارات داخل التطبيق. تتبع إشعارات الهاتف التفضيلات نفسها.';

  @override
  String get privacyTitle => 'الخصوصية والأمان';

  @override
  String get privacyBlockMemberTitle => 'حظر عضو';

  @override
  String get privacyAdminCannotBlock => 'لا يمكن حظر مشرفي Finder.';

  @override
  String get privacyDeleteAccountTitle => 'حذف حسابك؟';

  @override
  String get privacyDeleteAccountBody =>
      'تُزال منشوراتك ومحادثاتك وعناصرك المحفوظة وملفك فورًا. لا يمكن التراجع عن هذا.';

  @override
  String get privacyTypeDeleteLabel => 'اكتب DELETE للتأكيد';

  @override
  String get privacyPasswordLabel => 'كلمة المرور';

  @override
  String get privacyTypeDeleteHint => 'DELETE';

  @override
  String get privacyPasswordHint => 'كلمة المرور';

  @override
  String get privacyDeleteAccount => 'حذف الحساب';

  @override
  String get privacyTypeDeleteError => 'اكتب DELETE للتأكيد.';

  @override
  String get privacyEnterPassword => 'يرجى إدخال كلمة المرور.';

  @override
  String get privacyAccountDeleted => 'تم حذف حسابك.';

  @override
  String get privacyLoadingSettings => 'جارٍ تحميل الإعدادات...';

  @override
  String get privacyHeadline => 'بياناتك تحت سيطرتك';

  @override
  String get privacyIntro =>
      'حدد ما يراه الأعضاء الآخرون ومن يمكنه التواصل معك. تُطبّق التغييرات فورًا.';

  @override
  String get privacyVisibility => 'الظهور';

  @override
  String get privacyShowProfile => 'إظهار ملفي الشخصي';

  @override
  String get privacyShowProfileSubtitle =>
      'عند الإيقاف يظهر اسمك وصورتك فقط على المنشورات؛ وتبقى المهنة والهاتف والموقع مخفية.';

  @override
  String get privacyAllowMessages => 'السماح بالرسائل المباشرة';

  @override
  String get privacyAllowMessagesSubtitle =>
      'دع الأعضاء يبدؤون محادثة معك. المحادثات الحالية تبقى مفتوحة.';

  @override
  String get privacyShowCity => 'إظهار مدينتي';

  @override
  String get privacyShowCitySubtitle =>
      'يشارك العنوان من ملفك الشخصي مع الأعضاء الآخرين.';

  @override
  String get privacyHidePhone => 'إخفاء رقم هاتفي';

  @override
  String get privacyHidePhoneSubtitle =>
      'عند التفعيل لا يمكن للأعضاء الوصول إليك إلا عبر محادثة التطبيق.';

  @override
  String get privacyBlockedMembersLabel => 'الأعضاء المحظورون';

  @override
  String get privacyBlockedMembers => 'الأعضاء المحظورون';

  @override
  String get privacyBlockedMembersBody =>
      'لا يرى الأعضاء المحظورون منشوراتك ولا يمكنهم مراسلتك، ولن ترى منشوراتهم.';

  @override
  String privacyBlockedTotal(int count) {
    return '$count إجمالًا';
  }

  @override
  String get privacyLoadingBlocked => 'جارٍ تحميل الأعضاء المحظورين...';

  @override
  String get privacyNoBlocked => 'لا يوجد أعضاء محظورون';

  @override
  String get privacyNoBlockedSubtitle => 'سيظهر هنا الأعضاء الذين تحظرهم.';

  @override
  String get privacyBlockAnother => 'حظر عضو آخر';

  @override
  String get privacyDeleteAccountSubtitle =>
      'إزالة حسابك ومنشوراتك ومحادثاتك نهائيًا.';

  @override
  String blockUserLabel(String name) {
    return 'حظر $name';
  }

  @override
  String blockUserTitle(String name) {
    return 'حظر $name؟';
  }

  @override
  String blockUserDone(String name) {
    return 'تم حظر $name.';
  }

  @override
  String blockUnblocked(String name) {
    return 'يمكن لـ $name التواصل معك مجددًا.';
  }

  @override
  String get blockChatConfirmBody =>
      'ستختفي هذه المحادثة ولن يتمكن أي منكما من مراسلة الآخر. يمكنك التراجع في أي وقت من الخصوصية والأمان.';

  @override
  String get blockProfileSubtitle => 'لن يرى أي منكما الآخر أو يراسله';

  @override
  String get blockProfileConfirmBody =>
      'يمكنك التراجع في أي وقت من الخصوصية والأمان.';

  @override
  String get blockStaffSubtitle => 'لا يمكن حظر حسابات فريق العمل';

  @override
  String get blockMemberFallback => 'عضو';

  @override
  String get profileFinderMember => 'عضو في Finder';

  @override
  String get profileChangePhoto => 'تغيير الصورة';

  @override
  String get profileStatActive => 'نشط';

  @override
  String get profileStatResolved => 'مُعاد';

  @override
  String get profileStatSaved => 'محفوظ';

  @override
  String profileShareLine(String id) {
    return 'جدني على Finder · معرّف العضو $id';
  }

  @override
  String get profileCopied => 'تم نسخ تفاصيل الملف الشخصي.';

  @override
  String get profileEdit => 'تعديل الملف الشخصي';

  @override
  String get profileCopyDetails => 'نسخ تفاصيل الملف الشخصي';

  @override
  String get profileAboutTitle => 'عن Finder';

  @override
  String get profileAboutVersion => 'الإصدار 1.0 · تصميم Beacon';

  @override
  String get profileAboutBody =>
      'يساعد Finder المجتمع على إعادة الممتلكات المفقودة إلى أصحابها. أبلغ عما فقدته أو وجدته، وتحدث بأمان داخل التطبيق، وحدد العناصر كمُعادة عند عودتها.';

  @override
  String get profileSafetyFirst => 'السلامة أولًا';

  @override
  String get profileSafetyBody =>
      'التقِ في أماكن عامة، ولا تدفع مكافأة قبل استلام غرضك، واستخدم محادثة التطبيق لتتمكن من الحظر والإبلاغ.';

  @override
  String get profileAccount => 'الحساب';

  @override
  String get profileMyPosts => 'منشوراتي';

  @override
  String get profileMyPostsSubtitle => 'إدارة ما أبلغت عنه';

  @override
  String get profileSavedItems => 'العناصر المحفوظة';

  @override
  String get profileSavedItemsSubtitle => 'العناصر التي تتابعها';

  @override
  String get profileAdminConsole => 'لوحة الإشراف';

  @override
  String get profileAdminConsoleSubtitle =>
      'المستخدمون والمنشورات والبلاغات والتوثيق';

  @override
  String get profilePreferences => 'التفضيلات';

  @override
  String get profileDarkMode => 'الوضع الداكن';

  @override
  String get profileNightTheme => 'مظهر ليلي';

  @override
  String get profileDayTheme => 'مظهر نهاري';

  @override
  String get profileSupportLegal => 'الدعم والقانوني';

  @override
  String get profileTerms => 'شروط الخدمة';

  @override
  String get profilePrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get profileLogOutTitle => 'تسجيل الخروج؟';

  @override
  String get profileLogOutBody => 'يمكنك تسجيل الدخول مجددًا في أي وقت.';

  @override
  String get profileDiscardTitle => 'تجاهل التغييرات؟';

  @override
  String get profileDiscardBody => 'لم تُحفظ تعديلاتك.';

  @override
  String get profileKeepEditing => 'متابعة التعديل';

  @override
  String get profileLoading => 'جارٍ تحميل ملفك الشخصي...';

  @override
  String get profileFullName => 'الاسم الكامل';

  @override
  String get profileFullNameHint => 'اسمك';

  @override
  String get profileNickname => 'الاسم المستعار';

  @override
  String get profileNicknameHint => 'كيف يعرفك أصدقاؤك';

  @override
  String get profilePhone => 'الهاتف';

  @override
  String get profilePhoneHint => '+964 750 000 0000';

  @override
  String get profileCity => 'المدينة';

  @override
  String get profileCityHint => 'المدينة، البلد';

  @override
  String get profileJob => 'المهنة / العمل';

  @override
  String get profileJobHint => 'ما هو عملك؟';

  @override
  String get profileSignInEmailLabel => 'بريد تسجيل الدخول';

  @override
  String get profileEmailNote =>
      'يُستخدم بريدك الإلكتروني لتسجيل الدخول ولا يمكن تغييره من هنا.';

  @override
  String get profileSaveChanges => 'حفظ التغييرات';

  @override
  String get profileEnterName => 'يرجى إدخال اسمك.';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي.';

  @override
  String get profileLoadingOther => 'جارٍ تحميل الملف الشخصي…';

  @override
  String get profileUnavailableTitle => 'هذا العضو غير متاح';

  @override
  String get profileUnavailableSubtitle =>
      'ربما أُزيل الحساب، أو لا يمكن لكما رؤية بعضكما.';

  @override
  String get profileMore => 'المزيد';

  @override
  String profileMemberSince(String time) {
    return 'عضو منذ $time';
  }

  @override
  String profilePostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور',
      many: '$count منشورًا',
      few: '$count منشورات',
      two: 'منشوران',
      one: 'منشور واحد',
      zero: 'لا منشورات',
    );
    return '$_temp0';
  }

  @override
  String profileMessageFirstName(String name) {
    return 'مراسلة $name';
  }

  @override
  String profileItemsReported(String name) {
    return 'العناصر التي أبلغ عنها $name';
  }

  @override
  String get profileNoPosts => 'لا توجد منشورات بعد';

  @override
  String get profileSendMessage => 'إرسال رسالة';

  @override
  String get profileFinderAdmin => 'مشرف Finder';

  @override
  String get profileAdminBadge => 'مشرف';

  @override
  String get profileFindMember => 'البحث عن عضو';

  @override
  String get profileSearchMemberHint => 'ابحث بالاسم أو البريد…';

  @override
  String get profileSelect => 'اختيار';

  @override
  String get profileSearchFailed => 'فشل البحث.';

  @override
  String get profileSearchSubtitle =>
      'اكتب حرفين على الأقل من الاسم أو البريد الإلكتروني.';

  @override
  String get profileSearchBlockedNote => 'لن يظهر هنا الأعضاء الذين حظرتهم.';

  @override
  String profileSearchNoMatch(String query) {
    return 'لا يوجد أعضاء يطابقون \"$query\".';
  }

  @override
  String profileUserRowSemantics(String name, String action) {
    return '$name، $action';
  }

  @override
  String get verifyVerifiedIdentity => 'هوية موثّقة';

  @override
  String get verifyGetVerified => 'وثّق حسابك';

  @override
  String get verifyBadgeVisible => 'شارتك ظاهرة للمجتمع';

  @override
  String get verifyBuildTrust => 'ابنِ الثقة بشارة التوثيق';

  @override
  String get verifyPassport => 'جواز سفر';

  @override
  String get verifyIdentityCard => 'بطاقة هوية';

  @override
  String get verifyDriversLicense => 'رخصة قيادة';

  @override
  String get verifyTitle => 'توثيق الهوية';

  @override
  String get verifyApprovedSubtitle => 'هويتك موثّقة';

  @override
  String get verifyUnderReview => 'قيد المراجعة';

  @override
  String get verifyNeedsNewPhotos => 'يحتاج إلى صور جديدة';

  @override
  String verifyStepsComplete(int count) {
    return 'اكتملت $count من 3 خطوات';
  }

  @override
  String get verifyCheckingStatus => 'جارٍ التحقق من حالتك...';

  @override
  String get verifyVerifiedMember => 'عضو موثّق';

  @override
  String get verifyReviewedByPerson => 'تتم المراجعة بواسطة شخص';

  @override
  String get verifyThanks => 'شكرًا لمساعدتك في جعل Finder موثوقًا.';

  @override
  String get verifyHeroHeadline =>
      'الحسابات الموثّقة تساعد في بناء مجتمع أكثر أمانًا للجميع.';

  @override
  String get verifyApprovedBody =>
      'تظهر شارة التوثيق الآن على منشوراتك ورسائلك.';

  @override
  String get verifyHeroBody =>
      'تُخزَّن صورك بشكل خاص ولا يراها إلا عضو فريق Finder الذي يراجعها. تستغرق المراجعة يومًا عادةً.';

  @override
  String get verifyHowItWorks => 'كيف يعمل';

  @override
  String get verifyStep1Title => 'صوّر هويتك';

  @override
  String get verifyStep1Body =>
      'بالكاميرا أو من المعرض. كل الزوايا داخل الإطار، دون انعكاس.';

  @override
  String get verifyStep2Title => 'التقط صورة شخصية مباشرة';

  @override
  String get verifyStep2Body => 'بالكاميرا الأمامية فقط، لنتأكد أنك أنت فعلًا.';

  @override
  String get verifyStep3Title => 'يراجعها شخص';

  @override
  String get verifyStep3Body =>
      'يقارن الوجه في الهوية بصورتك الشخصية والاسم في حسابك. تصلك إشعار في الحالتين.';

  @override
  String get verifyIdentityVerified => 'تم توثيق الهوية';

  @override
  String get verifyPending => 'التوثيق قيد الانتظار';

  @override
  String get verifyPendingBadge => 'قيد الانتظار';

  @override
  String verifyVerifiedWith(String doc) {
    return 'تم التوثيق باستخدام $doc.';
  }

  @override
  String verifyReceived(String doc, String time) {
    return 'استلمنا $doc $time. يراجعه أحد أعضاء فريق Finder؛ سيصلك إشعار عند الانتهاء.';
  }

  @override
  String get verifyNotApproved => 'لم تتم الموافقة بعد';

  @override
  String get verifyNeedsPhotosBadge => 'يحتاج إلى صور';

  @override
  String get verifyPhotosRejected => 'تعذّر التحقق من الصور.';

  @override
  String verifyReviewedAt(String time) {
    return 'تمت المراجعة $time';
  }

  @override
  String get verifySubmitNewPhotos => 'إرسال صور جديدة';

  @override
  String verifyDocTypeLower(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'id_card': 'بطاقة الهوية',
      'drivers_license': 'رخصة القيادة',
      'passport': 'جواز السفر',
      'other': 'الوثيقة',
    });
    return '$_temp0';
  }

  @override
  String get verifyDocSelection => 'اختيار الوثيقة';

  @override
  String get verifyDocSelectionSubtitle =>
      'اختر الهوية التي تريد استخدامها للتوثيق';

  @override
  String get verifyDocPhotos => 'صور الوثيقة';

  @override
  String get verifyBothSides => 'وجها هويتك، بالكاميرا أو من المعرض';

  @override
  String get verifyPhotoPage => 'صفحة الصورة، بالكاميرا أو من المعرض';

  @override
  String get verifyFrontOfId => 'وجه الهوية';

  @override
  String get verifyPhotoPageLabel => 'صفحة الصورة';

  @override
  String get verifyBackOfId => 'ظهر الهوية';

  @override
  String get verifyLiveSelfie => 'صورة شخصية مباشرة';

  @override
  String get verifyLiveSelfieSubtitle =>
      'تُلتقط الآن بالكاميرا الأمامية؛ لا تُقبل صور المعرض.';

  @override
  String get verifyRetakeSelfie => 'إعادة التقاط الصورة';

  @override
  String get verifyTakeSelfie => 'التقط صورة شخصية';

  @override
  String get verifyTip =>
      'استخدم مكانًا جيد الإضاءة، وأبقِ الوثيقة كاملة داخل الإطار، وانزع القبعة أو النظارة الشمسية للصورة الشخصية.';

  @override
  String get verifyFrontOfYourId => 'وجه هويتك';

  @override
  String get verifyBackOfYourId => 'ظهر هويتك';

  @override
  String get verifyStoredPrivately => 'تُخزَّن بشكل خاص ولا يراها إلا المراجع.';

  @override
  String verifyAddDocumentFirst(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يرجى إضافة صور الوثيقة أولًا.',
      one: 'يرجى إضافة صورة الوثيقة أولًا.',
    );
    return '$_temp0';
  }

  @override
  String get verifyTakeSelfieFirst => 'يرجى التقاط صورة شخصية للإنهاء.';

  @override
  String get verifySubmitted => 'تم الإرسال. سيصلك إشعار بعد المراجعة.';

  @override
  String verifyStepLabel(int index) {
    return 'الخطوة $index';
  }

  @override
  String get verifySubmitForReview => 'إرسال للمراجعة';

  @override
  String get verifyConfirmOwnership => 'بالإرسال تؤكد أن الوثائق تخصك.';

  @override
  String get verifyAddToContinue => 'أضف صور وثيقتك وصورة شخصية للمتابعة.';

  @override
  String verifyUploadAddedSemantics(String label) {
    return 'تمت إضافة $label، انقر للاستبدال';
  }

  @override
  String verifyUploadAddSemantics(String label) {
    return 'إضافة $label';
  }

  @override
  String verifyUploadAdded(String label) {
    return 'تمت إضافة $label';
  }

  @override
  String get verifyTapToReplace => 'انقر للاستبدال';

  @override
  String get verifyCameraOrGallery => 'الكاميرا أو المعرض';

  @override
  String get helpTitle => 'المساعدة والدعم';

  @override
  String get helpHeroPrefix => 'كيف يمكننا ';

  @override
  String get helpHeroAccent => 'مساعدتك';

  @override
  String get helpHeroSuffix => ' اليوم؟';

  @override
  String get helpIntro =>
      'سواء فقدت شيئًا ثمينًا أو وجدت ذكرى لأحدهم، تغطي الإجابات أدناه معظم الأسئلة.';

  @override
  String get helpSearchHint => 'ابحث في الأسئلة (مثال: \'كلمة المرور\')';

  @override
  String helpNoAnswers(String query) {
    return 'لا توجد إجابات تطابق \"$query\". جرّب كلمة أخرى أو تواصل معنا أدناه.';
  }

  @override
  String helpAnswersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجابة',
      many: '$count إجابة',
      few: '$count إجابات',
      two: 'إجابتان',
      one: 'إجابة واحدة',
      zero: 'لا إجابات',
    );
    return '$_temp0';
  }

  @override
  String get helpBrowseByTopic => 'تصفح حسب الموضوع';

  @override
  String get helpStillQuestions => 'ما زالت لديك أسئلة؟';

  @override
  String get helpEmailReply => 'راسلنا بالبريد ونرد خلال يوم عمل واحد.';

  @override
  String get helpEmailSupport => 'مراسلة الدعم';

  @override
  String get helpEmailSubject => 'طلب دعم Finder';

  @override
  String get helpEmailBody => 'مرحبًا فريق Finder،\n\n';

  @override
  String get helpCopyAddress => 'نسخ عنوان الدعم';

  @override
  String helpAddressCopied(String email) {
    return 'تم نسخ $email.';
  }

  @override
  String get helpTechnicalFeedback => 'ملاحظات تقنية';

  @override
  String get helpFoundGlitch => 'وجدت خللًا؟';

  @override
  String get helpGlitchBody =>
      'أخبرنا بما فعلته، وما توقعته، وما حدث بدلًا من ذلك. لقطات الشاشة تساعد كثيرًا.';

  @override
  String get helpReportIssue => 'الإبلاغ عن مشكلة تقنية';

  @override
  String get helpBugSubject => 'بلاغ خلل في Finder';

  @override
  String get helpBugBody =>
      'ما فعلته:\n\nما توقعته:\n\nما حدث:\n\nالجهاز / النظام:\n';

  @override
  String helpNoEmailApp(String email) {
    return 'لم يُعثر على تطبيق بريد. تم نسخ $email إلى الحافظة.';
  }

  @override
  String get helpGotIt => 'فهمت';

  @override
  String get helpTopicAccountSubtitle => 'الملف الشخصي والتوثيق وكلمات المرور';

  @override
  String get helpFaqChangeNameQ => 'كيف أغيّر اسمي أو صورتي؟';

  @override
  String get helpFaqChangeNameA =>
      'افتح الملف الشخصي، وانقر \"تعديل الملف الشخصي\"، وغيّر الحقول ثم احفظ. تظهر الصورة الجديدة على كل منشوراتك ورسائلك.';

  @override
  String get helpFaqForgotPasswordQ => 'نسيت كلمة المرور.';

  @override
  String get helpFaqForgotPasswordA =>
      'في شاشة تسجيل الدخول انقر \"نسيت كلمة المرور؟\". يُرسل رمز إعادة التعيين إلى بريدك؛ أدخله مع كلمة المرور الجديدة.';

  @override
  String get helpFaqVerifiedBadgeQ => 'ماذا تعني شارة التوثيق؟';

  @override
  String get helpFaqVerifiedBadgeA =>
      'العضو الموثّق أكّد هويته بوثيقة هوية وصورة شخصية. ابدأ من الملف الشخصي ← وثّق حسابك. تستغرق المراجعة نحو يوم.';

  @override
  String get helpFaqDeleteAccountQ => 'كيف أحذف حسابي؟';

  @override
  String get helpFaqDeleteAccountA =>
      'اذهب إلى الخصوصية والأمان ← حذف الحساب. نزيل منشوراتك ومحادثاتك وملفك خلال 30 يومًا.';

  @override
  String get helpTopicSafety => 'السلامة';

  @override
  String get helpTopicSafetySubtitle => 'اللقاءات والحظر';

  @override
  String get helpFaqMeetQ => 'أين ألتقي لتسليم غرض؟';

  @override
  String get helpFaqMeetA =>
      'اختر مكانًا عامًا مزدحمًا في وضح النهار، مثل مقهى أو مركز شرطة أو مركز تسوق. اصطحب صديقًا إن أمكن.';

  @override
  String get helpFaqBotheringQ => 'شخص يضايقني.';

  @override
  String get helpFaqBotheringA =>
      'افتح المحادثة، وانقر القائمة في الزاوية العلوية واختر \"حظر\". لن يتمكن من رؤية منشوراتك أو مراسلتك. أبلغ عن المنشور أيضًا إذا بدا مزيفًا.';

  @override
  String get helpFaqRewardQ => 'هل أدفع المكافأة قبل استلام غرضي؟';

  @override
  String get helpFaqRewardA =>
      'لا. لا ترسل المال أبدًا قبل أن يكون الغرض بين يديك. المكافآت طوعية وتُدفع عند التسليم.';

  @override
  String get helpTopicPosting => 'نشر العناصر';

  @override
  String get helpTopicPostingSubtitle => 'كتابة بلاغات تحصل على تطابقات';

  @override
  String get helpFaqGoodPostQ => 'ما الذي يجعل المنشور جيدًا؟';

  @override
  String get helpFaqGoodPostA =>
      'صورة واضحة، وموقع دقيق، والتاريخ والوقت، وتفاصيل مميزة (خدوش، ملصقات، نقوش). أبقِ الأرقام التسلسلية سرية حتى يثبت أحدهم ملكيته.';

  @override
  String get helpFaqMarkReturnedQ => 'كيف أحدد عنصرًا كمُعاد؟';

  @override
  String get helpFaqMarkReturnedA =>
      'افتح المنشور أو اذهب إلى منشوراتي واختر \"تحديد كمُعاد\". يصل إشعار إلى كل من تحدث معك بشأنه.';

  @override
  String get helpFaqEditPostQ => 'هل يمكنني تعديل منشور أو حذفه؟';

  @override
  String get helpFaqEditPostA =>
      'نعم. من منشوراتي انقر تعديل، أو افتح المنشور واستخدم القائمة في الزاوية العلوية لتعديله أو تحديده كمُعاد أو حذفه.';

  @override
  String get helpTopicMessaging => 'المراسلة';

  @override
  String get helpTopicMessagingSubtitle =>
      'التواصل مع المالكين ومن وجدوا الأغراض';

  @override
  String get helpFaqContactOwnerQ => 'كيف أتواصل مع صاحب منشور؟';

  @override
  String get helpFaqContactOwnerA =>
      'افتح المنشور وانقر \"محادثة المالك\" (أو \"وجدت هذا العنصر\"). تُفتح محادثة عن ذلك العنصر في الرسائل.';

  @override
  String get helpFaqSendPhotosQ => 'هل يمكنني إرسال صور؟';

  @override
  String get helpFaqSendPhotosA =>
      'نعم. في المحادثة انقر زر الصورة بجانب حقل الرسالة لإرسال صورة كدليل.';

  @override
  String get helpFaqCantMessageQ => 'لماذا لا أستطيع مراسلة شخص ما؟';

  @override
  String get helpFaqCantMessageA =>
      'إما أن أحدكما حظر الآخر، أو أنه أوقف الرسائل المباشرة في إعدادات الخصوصية.';

  @override
  String helpComingSoon(String feature) {
    return '$feature قريبًا.';
  }

  @override
  String get helpThisFeature => 'هذه الميزة';

  @override
  String get voicePlay => 'تشغيل الرسالة الصوتية';

  @override
  String get voicePause => 'إيقاف الرسالة الصوتية مؤقتًا';

  @override
  String get voiceHoldHint => 'اضغط مطولًا على الميكروفون لتسجيل رسالة صوتية.';

  @override
  String get voiceHoldTap => 'اضغط مطولًا لتسجيل رسالة صوتية.';

  @override
  String get voiceSlideToCancel => 'اسحب للإلغاء';

  @override
  String get voiceCancelRecording => 'إلغاء التسجيل';

  @override
  String get photoAddTitle => 'إضافة صورة';

  @override
  String get photoTakePhoto => 'التقاط صورة';

  @override
  String get photoOpenCamera => 'فتح الكاميرا';

  @override
  String get photoChooseGallery => 'الاختيار من المعرض';

  @override
  String get photoPickExisting => 'اختر صورة موجودة';

  @override
  String get photoOpenFailed => 'تعذّر فتح هذه الصورة.';

  @override
  String get photoPrepareFailed => 'تعذّر تجهيز الصورة. حاول مجددًا.';

  @override
  String get photoAdjustAvatar => 'اضبط صورتك';

  @override
  String get photoAdjustCover => 'اضبط صورة الغلاف';

  @override
  String get photoUse => 'استخدام الصورة';

  @override
  String get photoGestureHint =>
      'قرّب بإصبعين · اسحب للتحريك · انقر مرتين للتكبير';

  @override
  String get photoRotate => 'تدوير';

  @override
  String get photoReset => 'إعادة ضبط';

  @override
  String get photoRemoveCover => 'إزالة صورة الغلاف';

  @override
  String get photoAddCover => 'إضافة صورة غلاف';

  @override
  String get photoChangeCover => 'تغيير صورة الغلاف';

  @override
  String get photoChangeProfile => 'تغيير الصورة الشخصية';

  @override
  String get photoAddProfile => 'إضافة صورة شخصية';

  @override
  String get photoProfileTitle => 'الصورة الشخصية';

  @override
  String get photoCoverTitle => 'صورة الغلاف';

  @override
  String photoUploadFailed(String detail) {
    return 'فشل رفع الصورة. $detail';
  }

  @override
  String get photoFileEmpty => 'الملف المحدد فارغ.';

  @override
  String get photoTooLarge => 'يرجى اختيار صورة حجمها أقل من 8 ميغابايت.';

  @override
  String get photoNoFileId => 'لم يُرجع الخادم معرّف الملف.';

  @override
  String get photoNoUrl => 'لم يُرجع الخادم رابط الصورة.';

  @override
  String get photoCameraDenied =>
      'تم رفض الوصول إلى الكاميرا. اسمح به من إعدادات هاتفك أو اختر صورة من المعرض.';

  @override
  String get photoAccessDenied =>
      'تم رفض الوصول إلى الصور. اسمح به من إعدادات هاتفك وحاول مجددًا.';

  @override
  String get photoCameraOpenFailed => 'تعذّر فتح الكاميرا.';

  @override
  String get photoPickerOpenFailed => 'تعذّر فتح منتقي الصور.';

  @override
  String get pushMessagesChannelDesc => 'رسائل محادثة جديدة';

  @override
  String get pushUpdatesChannel => 'التحديثات';

  @override
  String get pushUpdatesChannelDesc => 'تحديثات المنشورات والحساب';

  @override
  String get chatTyping => 'يكتب…';

  @override
  String get chatOnline => 'متصل الآن';

  @override
  String chatLastSeen(String when) {
    return 'آخر ظهور $when';
  }

  @override
  String get chatYouPrefix => 'أنت: ';

  @override
  String get chatAddCaption => 'أضف تعليقًا…';

  @override
  String get chatLoadingOlder => 'جارٍ تحميل الرسائل الأقدم…';

  @override
  String get voiceTapToLock => 'انقر للتسجيل دون إمساك، أو اضغط مطولًا للتسجيل';

  @override
  String get voiceSlideUpToLock => 'اسحب للأعلى للقفل';

  @override
  String get voiceSend => 'إرسال الرسالة الصوتية';

  @override
  String get voiceDiscard => 'تجاهل التسجيل';

  @override
  String voiceSpeed(String speed) {
    return '$speed×';
  }

  @override
  String get chatForwarded => 'مُعاد توجيهها';

  @override
  String get chatDeleteForMe => 'حذف لديّ';

  @override
  String get chatForward => 'إعادة توجيه';

  @override
  String get chatForwardTo => 'إعادة التوجيه إلى';

  @override
  String get chatForwardSent => 'تمت إعادة التوجيه.';

  @override
  String chatUnreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رسالة غير مقروءة',
      many: '$count رسالة غير مقروءة',
      few: '$count رسائل غير مقروءة',
      two: 'رسالتان غير مقروءتين',
      one: 'رسالة واحدة غير مقروءة',
      zero: 'لا رسائل غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenPhoto => 'فتح الصورة';

  @override
  String get navPost => 'نشر';

  @override
  String navTab(String label) {
    return 'تبويب $label';
  }

  @override
  String get categoryAllItems => 'كل العناصر';

  @override
  String get categoryAll => 'الكل';

  @override
  String get categoryNearby => 'القريبة';

  @override
  String get categoryRecent => 'الأحدث';

  @override
  String get categoryWithReward => 'بمكافأة';

  @override
  String get categoryElectronics => 'إلكترونيات';

  @override
  String get categoryWatchesJewelry => 'ساعات ومجوهرات';

  @override
  String get categoryWalletsBags => 'محافظ وحقائب';

  @override
  String get categoryKeys => 'مفاتيح';

  @override
  String get categoryPets => 'حيوانات أليفة';

  @override
  String get categoryClothing => 'ملابس';

  @override
  String get categoryDocuments => 'مستندات';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get categoryWallets => 'محافظ';

  @override
  String get categoryBags => 'حقائب';

  @override
  String get categoryWallet => 'محفظة';

  @override
  String get categoryJewelry => 'مجوهرات';

  @override
  String get categoryOthers => 'أخرى';

  @override
  String get categoryVisibilityPublic => 'عام';

  @override
  String get categoryVisibilityFriendsOnly => 'الأصدقاء فقط';

  @override
  String get categoryVisibilityPrivate => 'خاص';

  @override
  String get filterTitle => 'التصفية';

  @override
  String get filterSubtitle => 'حدّد نطاق ما تبحث عنه';

  @override
  String get filterReset => 'إعادة ضبط';

  @override
  String get filterApply => 'تطبيق التصفية';

  @override
  String get filterType => 'النوع';

  @override
  String get filterLocationHint => 'أدخل المدينة أو المنطقة';

  @override
  String get filterDateRange => 'الفترة الزمنية';

  @override
  String get filterFrom => 'من';

  @override
  String get filterTo => 'إلى';

  @override
  String get filterSelectDate => 'اختر التاريخ';

  @override
  String get filterRewardOffered => 'بمكافأة';

  @override
  String get filterRewardSubtitle => 'المنشورات التي تقدم مكافأة فقط';

  @override
  String get filterVerifiedOnly => 'المستخدمون الموثّقون فقط';

  @override
  String get filterVerifiedSubtitle => 'منشورات من أعضاء موثّقي الهوية';

  @override
  String get filterSortBy => 'الترتيب حسب';

  @override
  String get filterMostRecent => 'الأحدث';

  @override
  String get filterNearest => 'الأقرب إليّ';

  @override
  String get filterAnyTime => 'أي وقت';

  @override
  String get filterLast24h => 'آخر 24 ساعة';

  @override
  String get filterLastWeek => 'آخر أسبوع';

  @override
  String get filterLastMonth => 'آخر شهر';

  @override
  String filterDate(int day, String month, int year) {
    return '$day $month، $year';
  }

  @override
  String get searchSubtitle => 'ابحث عن المفقودات والموجودات بالقرب منك';

  @override
  String get searchHint => 'ابحث عن عناصر أو أماكن…';

  @override
  String get searchClear => 'مسح البحث';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get searchClearFilters => 'مسح التصفية';

  @override
  String get searchResetFilters => 'إعادة ضبط التصفية';

  @override
  String get searchNoResultsTitle => 'لا توجد عناصر مطابقة';

  @override
  String get searchNoResultsSubtitle =>
      'جرّب كلمة مختلفة أو عدّل خيارات التصفية.';

  @override
  String get homeReportLost => 'الإبلاغ عن مفقود';

  @override
  String get homeReportLostSubtitle => 'اطلب مساعدة المجتمع';

  @override
  String get homeReportFound => 'الإبلاغ عن موجود';

  @override
  String get homeReportFoundSubtitle => 'أعده إلى صاحبه';

  @override
  String get homeLoadingPosts => 'جارٍ تحميل المنشورات...';

  @override
  String get homeNoLostItems => 'لا توجد مفقودات';

  @override
  String get homeNoFoundItems => 'لا توجد موجودات';

  @override
  String get homeNoPostsYet => 'لا توجد منشورات بعد';

  @override
  String get homeCreateFirstPost => 'أنشئ أول منشور للبدء.';

  @override
  String get homeTrySwitchingAll => 'جرّب التبديل إلى كل العناصر.';

  @override
  String get homeOpenProfile => 'فتح الملف الشخصي';

  @override
  String get homeContactOwner => 'التواصل مع المالك';

  @override
  String get homeContactFinder => 'التواصل مع من وجده';

  @override
  String get homeGoodMorning => 'صباح الخير';

  @override
  String get homeGoodAfternoon => 'طاب يومك';

  @override
  String get homeGoodEvening => 'مساء الخير';

  @override
  String get homeGuest => 'زائر';

  @override
  String homeNotificationsUnread(int count) {
    return 'الإشعارات، $count غير مقروءة';
  }

  @override
  String get mapPickLocation => 'اختر موقعًا';

  @override
  String get mapSearchHint => 'ابحث عن مكان أو عنوان';

  @override
  String get mapSearching => 'جارٍ البحث…';

  @override
  String get mapMoveToPlacePin => 'حرّك الخريطة لوضع الدبوس';

  @override
  String get mapUseMyLocation => 'استخدام موقعي الحالي';

  @override
  String get mapFindingAddress => 'جارٍ تحديد العنوان…';

  @override
  String get mapUseThisLocation => 'استخدام هذا الموقع';

  @override
  String get mapAttribution => 'بيانات الخريطة © مساهمو OpenStreetMap';

  @override
  String get mapErrGpsOff => 'فعّل خدمات الموقع (GPS) لاستخدام موقعك الحالي.';

  @override
  String get mapErrBlocked =>
      'الوصول إلى الموقع محظور. اسمح به من إعدادات هاتفك لاستخدام موقعك الحالي.';

  @override
  String get mapErrDenied => 'لم يتم منح إذن الوصول إلى الموقع.';

  @override
  String get mapErrNoFix =>
      'تعذّر تحديد موقع GPS. انتقل إلى مكان مكشوف أكثر وحاول مجددًا.';

  @override
  String shareKindTitle(String kind, String title) {
    return '$kind: $title';
  }

  @override
  String shareFindMe(String id) {
    return 'جدني على Finder · معرّف العضو $id';
  }

  @override
  String shareProfileSubject(String name) {
    return '$name على Finder';
  }

  @override
  String get postItemDetailsTitle => 'تفاصيل العنصر';

  @override
  String get postItemDetails => 'تفاصيل العنصر';

  @override
  String get postNoDescription => 'لم يُضف وصف بعد.';

  @override
  String get postReward => 'مكافأة';

  @override
  String postRewardAmount(String amount) {
    return 'مكافأة $amount';
  }

  @override
  String get postIFoundThis => 'وجدت هذا العنصر';

  @override
  String get postThisIsMine => 'هذا لي';

  @override
  String get postReturnedOwnerNote =>
      'تم تحديده كمُعاد. لم يعد يظهر في الرئيسية، لكنه يبقى في البحث ليرى الناس النتيجة.';

  @override
  String get postRemoveFromSaved => 'إزالة من المحفوظات';

  @override
  String get postSaveItem => 'حفظ العنصر';

  @override
  String get postMoreActions => 'إجراءات أخرى';

  @override
  String get postLinkCopied => 'تم نسخ الرابط.';

  @override
  String get postDetailsCopied => 'تم نسخ تفاصيل العنصر.';

  @override
  String get postSavedToList => 'تم الحفظ في قائمتك.';

  @override
  String get postRemovedFromSaved => 'تمت الإزالة من المحفوظات.';

  @override
  String get postManageSheetTitle => 'إدارة المنشور';

  @override
  String get postMoreSheetTitle => 'المزيد';

  @override
  String get postShareSubtitle => 'أرسل الصورة ورابطًا إلى أي شخص';

  @override
  String get postCopyLink => 'نسخ الرابط';

  @override
  String get postEditPost => 'تعديل المنشور';

  @override
  String get postReopenPost => 'إعادة فتح المنشور';

  @override
  String get postDeletePost => 'حذف المنشور';

  @override
  String get postReportPost => 'الإبلاغ عن المنشور';

  @override
  String get postBlockThisMember => 'حظر هذا العضو';

  @override
  String get postBlockMember => 'حظر العضو';

  @override
  String get postActiveAgain => 'المنشور نشط مجددًا.';

  @override
  String get postDeleteTitle => 'حذف المنشور؟';

  @override
  String postDeleteBody(String title) {
    return 'سيتم حذف \"$title\" للجميع. لا يمكن التراجع عن هذا.';
  }

  @override
  String postDeleteBodyConfirm(String title) {
    return 'هل أنت متأكد من حذف \"$title\"؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get postDeleted => 'تم حذف المنشور.';

  @override
  String get postReportReasonSpam => 'رسائل مزعجة أو احتيال';

  @override
  String get postReportReasonInappropriate => 'محتوى غير لائق';

  @override
  String get postReportReasonMisleading => 'معلومات خاطئة أو مضللة';

  @override
  String get postReportReasonOther => 'سبب آخر';

  @override
  String get postReportSheetTitle => 'الإبلاغ عن هذا المنشور';

  @override
  String get postReportSheetSubtitle =>
      'أخبرنا بما هو خاطئ. يراجع الفريق البلاغات.';

  @override
  String get postReported => 'شكرًا، تم الإبلاغ عن المنشور.';

  @override
  String get postThisMember => 'هذا العضو';

  @override
  String postBlockTitle(String name) {
    return 'حظر $name؟';
  }

  @override
  String get postBlockBody =>
      'لن يرى أي منكما منشورات الآخر أو رسائله. يمكنك التراجع من الخصوصية والأمان.';

  @override
  String postBlocked(String name) {
    return 'تم حظر $name.';
  }

  @override
  String get postCategory => 'الفئة';

  @override
  String get postLostOn => 'فُقد في';

  @override
  String get postFoundOn => 'وُجد في';

  @override
  String get postOpenInMaps => 'فتح في الخرائط';

  @override
  String get postCouldNotOpenMaps => 'تعذّر فتح تطبيق الخرائط.';

  @override
  String get postNotProvided => 'غير متوفر';

  @override
  String get postPostedByOwner => 'نشره المالك';

  @override
  String get postPostedByFinder => 'نشره من وجده';

  @override
  String get postLoadingProfile => 'جارٍ تحميل الملف الشخصي…';

  @override
  String get postProfileNotAvailable => 'الملف الشخصي غير متاح';

  @override
  String get postVerifiedMember => 'عضو موثّق';

  @override
  String postMemberSince(String date) {
    return 'عضو منذ $date';
  }

  @override
  String postPostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور',
      many: '$count منشورًا',
      few: '$count منشورات',
      two: 'منشوران',
      one: 'منشور واحد',
      zero: 'لا منشورات',
    );
    return '$_temp0';
  }

  @override
  String postMonthYear(String month, int year) {
    return '$month $year';
  }

  @override
  String get postPhone => 'الهاتف';

  @override
  String get postCouldNotOpenDialer => 'تعذّر فتح تطبيق الاتصال.';

  @override
  String get postChatWithOwner => 'محادثة المالك';

  @override
  String get postChatWithFinder => 'محادثة من وجده';

  @override
  String get postCall => 'اتصال';

  @override
  String get postPhoneNotShared =>
      'رقم الهاتف غير مشارك. محادثة التطبيق هي الطريقة الأكثر أمانًا للتنسيق.';

  @override
  String get postOwnerActions => 'إجراءات المالك';

  @override
  String get postSafety => 'السلامة';

  @override
  String get postPossibleMatches => 'تطابقات محتملة';

  @override
  String get postMatchesEyebrowLost => 'عناصر موجودة تشبه عنصرك';

  @override
  String get postMatchesEyebrowFound => 'عناصر مفقودة تشبه هذا العنصر';

  @override
  String get postNoMatchesLost =>
      'لا تطابقات بعد. نواصل مقارنة المنشورات الجديدة للموجودات بهذا المنشور وسنُعلمك فور ظهور شيء مشابه.';

  @override
  String get postNoMatchesFound =>
      'لا تطابقات بعد. نواصل مقارنة المنشورات الجديدة للمفقودات بهذا المنشور وسنُعلمك فور ظهور شيء مشابه.';

  @override
  String get postSimilarItems => 'عناصر مشابهة';

  @override
  String get postSimilarEyebrowLost => 'عناصر موجودة في هذه الفئة';

  @override
  String get postSimilarEyebrowFound => 'عناصر مفقودة في هذه الفئة';

  @override
  String get postViewAll => 'عرض الكل';

  @override
  String get postLoadingSimilar => 'جارٍ تحميل العناصر المشابهة...';

  @override
  String get postNoSimilarTitle => 'لا توجد عناصر مشابهة بعد';

  @override
  String get postNoSimilarSubtitle =>
      'عد لاحقًا للاطلاع على التطابقات القريبة.';

  @override
  String get postMatchBannerTitleLost =>
      'هل يمكن أن يكون هذا العنصر الذي وجدته؟';

  @override
  String get postMatchBannerTitleFound => 'هل يمكن أن يكون هذا عنصرك؟';

  @override
  String get postMatchBannerBodyLost =>
      'أبلغ أحدهم عن فقدان شيء يشبه العنصر الذي وجدته. قارن التفاصيل وراسله.';

  @override
  String get postMatchBannerBodyFound =>
      'أبلغ أحدهم عن العثور على شيء يشبه ما فقدته. قارن التفاصيل وراسله.';

  @override
  String get postMessageOwner => 'مراسلة المالك';

  @override
  String get postMessageFinder => 'مراسلة من وجده';

  @override
  String postItemSemantics(String status, String title) {
    return 'عنصر $status، $title';
  }

  @override
  String get postLocationNotSet => 'الموقع غير محدد';

  @override
  String get postNewPost => 'منشور جديد';

  @override
  String get postHeaderLost => 'أخبر المجتمع بما فقدته.';

  @override
  String get postHeaderFound => 'ساعد في إعادة ما وجدته.';

  @override
  String get postReadyToPost => 'جاهز للنشر';

  @override
  String postDetailsAdded(int count) {
    return 'تمت إضافة $count من 5 تفاصيل';
  }

  @override
  String get postPhotos => 'الصور';

  @override
  String get postPhoto => 'صورة';

  @override
  String postStep(int number) {
    return 'الخطوة $number';
  }

  @override
  String get postPhotosHint =>
      'الصور الواضحة تساعد الآخرين على التعرف على العنصر.';

  @override
  String get postCamera => 'الكاميرا';

  @override
  String get postGallery => 'المعرض';

  @override
  String get postRemovePhoto => 'إزالة الصورة';

  @override
  String get postUploadingPhoto => 'جارٍ رفع الصورة';

  @override
  String postAddPhotoFrom(String source) {
    return 'إضافة صورة من $source';
  }

  @override
  String get postItemName => 'اسم العنصر';

  @override
  String get postItemNameHint => 'مثال: حقيبة ظهر زرقاء';

  @override
  String get postItemNameHintEdit => 'مثال: محفظة سوداء';

  @override
  String get postChooseCategory => 'اختر فئة';

  @override
  String get postChooseCategoryTitle => 'اختيار الفئة';

  @override
  String get postDescription => 'الوصف';

  @override
  String get postDescriptionHint =>
      'مثال: شوهد آخر مرة قرب النافورة في الحديقة المركزية. فيه خدش صغير في الأمام…';

  @override
  String postDescriptionHelper(int count) {
    return '$count/500 · 10 أحرف على الأقل';
  }

  @override
  String get postDescriptionHintEdit => 'صف العنصر بالتفصيل…';

  @override
  String get postDescriptionHelperEdit => '10 أحرف على الأقل';

  @override
  String get postRewardOptional => 'المكافأة (اختياري)';

  @override
  String get postRewardHint => 'مثال: 100\$';

  @override
  String get postRewardHintEdit => 'مثال: 50';

  @override
  String get postRewardNote => 'تظهر المكافأة كشارة كهرمانية على منشورك.';

  @override
  String get postLocationTime => 'الموقع والوقت';

  @override
  String get postNoLocationSelected => 'لم يتم اختيار موقع';

  @override
  String get postLocateMe => 'حدد موقعي';

  @override
  String get postOpenMap => 'فتح الخريطة';

  @override
  String get postMovePin => 'تحريك الدبوس';

  @override
  String get postPickOnMap => 'اختيار على الخريطة';

  @override
  String get postMovePinOnMap => 'تحريك الدبوس على الخريطة';

  @override
  String get postTypeAddress => 'اكتب عنوانًا بدلًا من ذلك';

  @override
  String get postDate => 'التاريخ';

  @override
  String get postTime => 'الوقت';

  @override
  String get postDateTime => 'التاريخ / الوقت';

  @override
  String get postTapToPickDate => 'انقر لاختيار التاريخ';

  @override
  String get postLocationHint => 'أين فُقد أو وُجد؟';

  @override
  String get postHowPeopleReachYou => 'كيف يتواصل الناس معك';

  @override
  String get postInAppChat => 'محادثة داخل التطبيق';

  @override
  String get postInAppChatNote =>
      'مفعّلة دائمًا. يتواصل الأعضاء معك عبر رسائل Finder.';

  @override
  String get postOn => 'مفعّل';

  @override
  String get postShowPhone => 'إظهار رقم هاتفي';

  @override
  String get postShowPhoneNote => 'يظهر في ملفك الشخصي للأعضاء المسجّلين';

  @override
  String get postPhoneNumber => 'رقم الهاتف';

  @override
  String get postPhoneHint => 'مثال: +964 750 000 0000';

  @override
  String get postPhoneHelper =>
      'يُحفظ في ملفك الشخصي ويُشارك مع الأعضاء المسجّلين.';

  @override
  String get postPostNow => 'نشر الآن';

  @override
  String get postSaveDraft => 'حفظ كمسودة';

  @override
  String get postSaveChanges => 'حفظ التغييرات';

  @override
  String postLocationSetTo(String label) {
    return 'تم تحديد الموقع: $label.';
  }

  @override
  String get postEnterLocation => 'أدخل الموقع';

  @override
  String get postEnterLocationHint => 'المدينة أو الشارع أو المنطقة';

  @override
  String get postErrTitleRequired => 'يرجى إدخال اسم العنصر قبل النشر.';

  @override
  String get postErrDescriptionShort =>
      'يرجى كتابة 10 أحرف على الأقل في الوصف.';

  @override
  String get postErrPhoneRequired =>
      'يرجى إدخال رقم هاتف أو إيقاف مشاركة الهاتف.';

  @override
  String get postErrLoginRequired => 'يجب تسجيل الدخول للنشر.';

  @override
  String get postErrTitleRequiredEdit => 'يرجى إدخال عنوان.';

  @override
  String get postErrDescriptionShortEdit =>
      'يجب أن يتكون الوصف من 10 أحرف على الأقل.';

  @override
  String get postLive => 'تم نشر منشورك.';

  @override
  String get postUpdated => 'تم تحديث المنشور.';

  @override
  String get postPhotoAdded => 'تمت إضافة الصورة.';

  @override
  String get postDraftSaved => 'تم حفظ المسودة على الجهاز.';

  @override
  String get postUploadingImage => 'جارٍ رفع الصورة…';

  @override
  String get postTapToChange => 'انقر للتغيير';

  @override
  String get postTapToPickFromGallery => 'انقر للاختيار من المعرض';

  @override
  String get postAddPhoto => 'إضافة صورة';

  @override
  String get postChangePhoto => 'تغيير الصورة';

  @override
  String get postILostSomething => 'فقدت شيئًا';

  @override
  String get postIFoundSomething => 'وجدت شيئًا';

  @override
  String get postAskCommunityHelp => 'اطلب مساعدة المجتمع';

  @override
  String get postHelpReturnHome => 'ساعد في إعادته إلى صاحبه';

  @override
  String get postMyPosts => 'منشوراتي';

  @override
  String postOpenReturnedCount(int open, int returned) {
    return '$open مفتوح · $returned مُعاد';
  }

  @override
  String get postNoOpenPosts => 'لا توجد منشورات مفتوحة';

  @override
  String get postNoReturnedYet => 'لا توجد عناصر مُعادة بعد';

  @override
  String get postCreateYourFirst => 'أنشئ أول منشور لك للبدء.';

  @override
  String get postReturnedAppearHere =>
      'ستظهر هنا المنشورات التي تحددها كمُعادة.';

  @override
  String get postMarkReturnedTitle => 'تحديد كمُعاد؟';

  @override
  String postMarkReturnedBody(String title) {
    return 'تحديد \"$title\" كمُعاد؟ سيختفي من الرئيسية لكنه يبقى ظاهرًا في البحث.';
  }

  @override
  String get postErrLoad => 'تعذّر تحميل منشوراتك.';

  @override
  String get postErrDelete => 'تعذّر حذف المنشور.';

  @override
  String get postErrResolve => 'تعذّر تحديث حالة المنشور.';

  @override
  String get postErrReopen => 'تعذّر إعادة فتح المنشور.';

  @override
  String get postErrSave => 'تعذّر حفظ المنشور.';

  @override
  String get postSavedItems => 'العناصر المحفوظة';

  @override
  String get postSavedSubtitle =>
      'تابع العناصر التي تساعد في إعادتها أو العثور عليها.';

  @override
  String postSavedCount(int count) {
    return '$count محفوظ · عناصر تساعد في إعادتها أو العثور عليها';
  }

  @override
  String get postLoadingSaved => 'جارٍ تحميل العناصر المحفوظة...';

  @override
  String get postNoSavedTitle => 'لا توجد عناصر محفوظة بعد';

  @override
  String get postNoSavedSubtitle =>
      'انقر على أيقونة الحفظ في أي منشور لإبقائه هنا.';

  @override
  String get postSentForReview => 'تم الإرسال للمراجعة. سنخبرك عندما يُنشر.';

  @override
  String get postWaitingForReview => 'بانتظار المراجعة';

  @override
  String get postWaitingForReviewBody =>
      'يراجع مشرف كل منشور قبل نشره، عادةً خلال ساعات قليلة.';

  @override
  String get postRejectedTitle => 'لم تتم الموافقة';

  @override
  String postRejectedReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get postEditAndResubmit => 'تعديل وإعادة الإرسال';

  @override
  String get postBadgeRejected => 'غير مقبول';

  @override
  String get postBadgeExpired => 'مؤرشف';

  @override
  String get postExpiredTitle => 'مؤرشف';

  @override
  String get postExpiredBody =>
      'تمت أرشفة هذا المنشور بعد 90 يومًا. أعد فتحه إذا كان لا يزال قائمًا.';

  @override
  String get postTranslatedNote => 'تمت الترجمة تلقائيًا';

  @override
  String get postSeeOriginal => 'عرض النص الأصلي';

  @override
  String get postSeeTranslation => 'عرض الترجمة';

  @override
  String get postPostLostCta => 'نشر المفقود';

  @override
  String get postPostFoundCta => 'نشر الموجود';

  @override
  String get mapNearbyTitle => 'بالقرب مني';

  @override
  String mapNearbyCount(int count, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منشور ضمن $km كم',
      many: '$count منشورًا ضمن $km كم',
      few: '$count منشورات ضمن $km كم',
      two: 'منشوران ضمن $km كم',
      one: 'منشور واحد ضمن $km كم',
      zero: 'لا منشورات ضمن $km كم',
    );
    return '$_temp0';
  }

  @override
  String mapRadius(int km) {
    return '$km كم';
  }

  @override
  String get mapNearbyEmpty => 'لا توجد منشورات هنا بعد. جرّب نطاقًا أوسع.';

  @override
  String get repoUnableLogin => 'تعذّر تسجيل الدخول';

  @override
  String get repoUnableLoginGoogle => 'تعذّر تسجيل الدخول عبر Google';

  @override
  String get repoUnableLogout => 'تعذّر تسجيل الخروج';

  @override
  String get repoUnableSignUp => 'تعذّر إنشاء الحساب';

  @override
  String get repoUnableSendResetCode =>
      'تعذّر إرسال رمز إعادة تعيين كلمة المرور';

  @override
  String get repoUnableVerifyCode => 'تعذّر التحقق من الرمز';

  @override
  String get repoUnableResetPassword => 'تعذّر إعادة تعيين كلمة المرور';

  @override
  String get repoUnableVerifyEmail => 'تعذّر توثيق البريد الإلكتروني';

  @override
  String get repoUnableResendCode => 'تعذّر إعادة إرسال رمز التحقق';

  @override
  String get repoUnableLoadNotifications => 'تعذّر تحميل الإشعارات.';

  @override
  String get repoUnableUpdateNotification => 'تعذّر تحديث الإشعار.';

  @override
  String get repoUnableUpdateNotifications => 'تعذّر تحديث الإشعارات.';

  @override
  String get repoUnableLoadProfile => 'تعذّر تحميل ملفك الشخصي.';

  @override
  String get repoUnableUpdateProfile => 'تعذّر تحديث ملفك الشخصي.';

  @override
  String get repoUnableLoadPrivacy => 'تعذّر تحميل إعدادات الخصوصية.';

  @override
  String get repoUnableUpdatePrivacy => 'تعذّر تحديث إعدادات الخصوصية.';

  @override
  String get repoUnableLoadNotifSettings => 'تعذّر تحميل إعدادات الإشعارات.';

  @override
  String get repoUnableUpdateNotifSettings => 'تعذّر تحديث إعدادات الإشعارات.';

  @override
  String get repoUnableLoadBlocked => 'تعذّر تحميل المستخدمين المحظورين.';

  @override
  String get repoUnableBlock => 'تعذّر حظر هذا المستخدم.';

  @override
  String get repoUnableUnblock => 'تعذّر إلغاء حظر هذا المستخدم.';

  @override
  String get repoUnableSubmitVerification => 'تعذّر إرسال طلب التوثيق.';

  @override
  String get repoUnableLoadVerification => 'تعذّر تحميل حالة التوثيق.';

  @override
  String get repoUnableDeleteAccount => 'تعذّر حذف حسابك.';

  @override
  String get repoUnableLoadSaved => 'تعذّر تحميل العناصر المحفوظة.';

  @override
  String get repoUnableUpdateSaved => 'تعذّر تحديث العناصر المحفوظة.';

  @override
  String get repoLoginToSave => 'يرجى تسجيل الدخول لحفظ العناصر.';

  @override
  String get repoLoginToManageNotifications =>
      'يرجى تسجيل الدخول لإدارة الإشعارات.';

  @override
  String get repoActionBlockUsers => 'حظر المستخدمين';

  @override
  String get repoActionCheckVerification => 'التحقق من حالة التوثيق';

  @override
  String get repoActionDeleteAccount => 'حذف حسابك';

  @override
  String get repoActionSubmitVerification => 'إرسال طلب التوثيق';

  @override
  String get repoActionUpdateBlocked => 'تحديث المستخدمين المحظورين';

  @override
  String get repoActionUpdateNotifSettings => 'تحديث إعدادات الإشعارات';

  @override
  String get repoActionUpdatePrivacy => 'تحديث إعدادات الخصوصية';

  @override
  String get repoActionUpdateProfile => 'تحديث ملفك الشخصي';

  @override
  String get repoActionViewBlocked => 'عرض المستخدمين المحظورين';

  @override
  String get repoActionViewNotifSettings => 'عرض إعدادات الإشعارات';

  @override
  String get repoActionViewPrivacy => 'عرض إعدادات الخصوصية';

  @override
  String get repoActionViewProfile => 'عرض ملفك الشخصي';

  @override
  String repoPleaseLogInTo(String action) {
    return 'يرجى تسجيل الدخول من أجل $action.';
  }

  @override
  String get serverAccountDeleted => 'تم حذف الحساب.';

  @override
  String get serverAccountIsAlreadyVerified => 'الحساب موثّق بالفعل.';

  @override
  String get serverCouldNotApproveTheRequest => 'تعذّرت الموافقة على الطلب.';

  @override
  String get serverCouldNotDeleteTheAccount => 'تعذّر حذف الحساب.';

  @override
  String get serverCouldNotDeleteThePost => 'تعذّر حذف المنشور.';

  @override
  String get serverCouldNotRegisterThisDevice => 'تعذّر تسجيل هذا الجهاز.';

  @override
  String get serverCouldNotRejectTheRequest => 'تعذّر رفض الطلب.';

  @override
  String get serverCouldNotResolveTheReport => 'تعذّر إغلاق البلاغ.';

  @override
  String get serverCouldNotStoreTheImage => 'تعذّر حفظ الصورة.';

  @override
  String get serverCouldNotUpdateTheAccount => 'تعذّر تحديث الحساب.';

  @override
  String get serverCouldNotUpdateThePost => 'تعذّر تحديث المنشور.';

  @override
  String get serverDatabaseErrorOccurredDuringLogin =>
      'حدث خطأ في قاعدة البيانات أثناء تسجيل الدخول.';

  @override
  String get serverDatabaseErrorOccurredDuringRegistration =>
      'حدث خطأ في قاعدة البيانات أثناء إنشاء الحساب.';

  @override
  String get serverDatabaseErrorOccurred => 'حدث خطأ في قاعدة البيانات.';

  @override
  String get serverDatabaseError => 'خطأ في قاعدة البيانات.';

  @override
  String get serverEmailAndCodeAreRequired =>
      'البريد الإلكتروني والرمز مطلوبان.';

  @override
  String get serverEmailIsAlreadyRegistered =>
      'البريد الإلكتروني مسجّل بالفعل.';

  @override
  String get serverEmailVerifiedSuccessfully =>
      'تم توثيق البريد الإلكتروني بنجاح.';

  @override
  String get serverErrorBlockingUser => 'تعذّر حظر المستخدم.';

  @override
  String get serverErrorCreatingPost => 'تعذّر إنشاء المنشور.';

  @override
  String get serverErrorDeletingAccount => 'تعذّر حذف الحساب.';

  @override
  String get serverErrorDeletingMessage => 'تعذّر حذف الرسالة.';

  @override
  String get serverErrorDeletingPost => 'تعذّر حذف المنشور.';

  @override
  String get serverErrorFetchingBlockedUsers =>
      'تعذّر تحميل المستخدمين المحظورين.';

  @override
  String get serverErrorFetchingProfile => 'تعذّر تحميل الملف الشخصي.';

  @override
  String get serverErrorFetchingUserProfile => 'تعذّر تحميل ملف المستخدم.';

  @override
  String get serverErrorInitiatingConversation => 'تعذّر بدء المحادثة.';

  @override
  String get serverErrorLoadingConversations => 'تعذّر تحميل المحادثات.';

  @override
  String get serverErrorLoadingMatches => 'تعذّر تحميل التطابقات.';

  @override
  String get serverErrorLoadingMessages => 'تعذّر تحميل الرسائل.';

  @override
  String get serverErrorLoadingNotificationSettings =>
      'تعذّر تحميل إعدادات الإشعارات.';

  @override
  String get serverErrorLoadingNotifications => 'تعذّر تحميل الإشعارات.';

  @override
  String get serverErrorLoadingPost => 'تعذّر تحميل المنشور.';

  @override
  String get serverErrorLoadingPosts => 'تعذّر تحميل المنشورات.';

  @override
  String get serverErrorLoadingPrivacySettings =>
      'تعذّر تحميل إعدادات الخصوصية.';

  @override
  String get serverErrorLoadingReports => 'تعذّر تحميل البلاغات.';

  @override
  String get serverErrorLoadingSavedItems => 'تعذّر تحميل العناصر المحفوظة.';

  @override
  String get serverErrorLoadingSimilarPosts =>
      'تعذّر تحميل المنشورات المشابهة.';

  @override
  String get serverErrorLoadingStatistics => 'تعذّر تحميل الإحصائيات.';

  @override
  String get serverErrorLoadingTheFile => 'تعذّر تحميل الملف.';

  @override
  String get serverErrorLoadingTheRequest => 'تعذّر تحميل الطلب.';

  @override
  String get serverErrorLoadingTheUser => 'تعذّر تحميل المستخدم.';

  @override
  String get serverErrorLoadingUsers => 'تعذّر تحميل المستخدمين.';

  @override
  String get serverErrorLoadingVerificationRequests =>
      'تعذّر تحميل طلبات التوثيق.';

  @override
  String get serverErrorLoadingVerificationStatus =>
      'تعذّر تحميل حالة التوثيق.';

  @override
  String get serverErrorRemovingSavedPost => 'تعذّر إزالة المنشور المحفوظ.';

  @override
  String get serverErrorSavingPost => 'تعذّر حفظ المنشور.';

  @override
  String get serverErrorSearchingUsers => 'تعذّر البحث عن المستخدمين.';

  @override
  String get serverErrorSendingMessage => 'تعذّر إرسال الرسالة.';

  @override
  String get serverErrorSubmittingReport => 'تعذّر إرسال البلاغ.';

  @override
  String get serverErrorSubmittingVerification => 'تعذّر إرسال طلب التوثيق.';

  @override
  String get serverErrorUnblockingUser => 'تعذّر إلغاء حظر المستخدم.';

  @override
  String get serverErrorUpdatingChat => 'تعذّر تحديث المحادثة.';

  @override
  String get serverErrorUpdatingNotificationSettings =>
      'تعذّر تحديث إعدادات الإشعارات.';

  @override
  String get serverErrorUpdatingNotification => 'تعذّر تحديث الإشعار.';

  @override
  String get serverErrorUpdatingNotifications => 'تعذّر تحديث الإشعارات.';

  @override
  String get serverErrorUpdatingPost => 'تعذّر تحديث المنشور.';

  @override
  String get serverErrorUpdatingPrivacySettings =>
      'تعذّر تحديث إعدادات الخصوصية.';

  @override
  String get serverErrorUpdatingProfile => 'تعذّر تحديث الملف الشخصي.';

  @override
  String get serverFileNoLongerExists => 'الملف لم يعد موجودًا.';

  @override
  String get serverFinderAdministratorsCannotBeBlocked =>
      'لا يمكن حظر مشرفي Finder.';

  @override
  String get serverGoogleAuthenticationFailed => 'فشل تسجيل الدخول عبر Google.';

  @override
  String get serverIfThatAddressIsRegisteredACode =>
      'إذا كان هذا البريد مسجّلًا، فالرمز في طريقه إليك.';

  @override
  String get serverIncorrectEmailOrPassword =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get serverIncorrectPassword => 'كلمة المرور غير صحيحة.';

  @override
  String get serverInvalidOrExpiredToken => 'الجلسة غير صالحة أو منتهية.';

  @override
  String get serverInvalidToken => 'الجلسة غير صالحة.';

  @override
  String get serverInvalidVerificationCode => 'رمز التحقق غير صحيح.';

  @override
  String get serverLocationSearchIsUnavailableRightNowTry =>
      'البحث عن المواقع غير متاح حاليًا. حاول بعد قليل.';

  @override
  String get serverMessageCannotBeEmpty => 'لا يمكن إرسال رسالة فارغة.';

  @override
  String get serverMessageNotFound => 'الرسالة غير موجودة.';

  @override
  String get serverNoImageReceived => 'لم يتم استلام أي صورة.';

  @override
  String get serverNoVerificationRequest => 'لا يوجد طلب توثيق.';

  @override
  String get serverNotAuthenticated => 'لم يتم تسجيل الدخول.';

  @override
  String get serverNotAuthorized => 'غير مصرّح لك.';

  @override
  String get serverNotFound => 'غير موجود.';

  @override
  String get serverPasswordHasBeenResetSuccessfully =>
      'تمت إعادة تعيين كلمة المرور بنجاح.';

  @override
  String get serverPasswordIsRequired => 'كلمة المرور مطلوبة.';

  @override
  String get serverPleaseChooseAnImageUnder8Mb =>
      'يرجى اختيار صورة حجمها أقل من 8 ميغابايت.';

  @override
  String get serverPostDeletedSuccessfully => 'تم حذف المنشور بنجاح.';

  @override
  String get serverPostDeleted => 'تم حذف المنشور.';

  @override
  String get serverPostNotFound => 'المنشور غير موجود.';

  @override
  String get serverPostRemovedFromSavedList =>
      'تمت إزالة المنشور من المحفوظات.';

  @override
  String get serverPostSavedSuccessfully => 'تم حفظ المنشور.';

  @override
  String get serverRemoveTheAdminRoleBeforeDeletingThis =>
      'أزل صلاحية المشرف قبل حذف هذا الحساب.';

  @override
  String get serverRemoveTheAdminRoleBeforeSuspendingThis =>
      'أزل صلاحية المشرف قبل تعليق هذا الحساب.';

  @override
  String get serverReportNotFound => 'البلاغ غير موجود.';

  @override
  String get serverReportSubmittedSuccessfully => 'تم إرسال البلاغ بنجاح.';

  @override
  String get serverRequestNotFound => 'الطلب غير موجود.';

  @override
  String get serverThatFileDoesNotLookLikeAn =>
      'لا يبدو أن هذا الملف صورة يمكن قراءتها.';

  @override
  String get serverTheMessageYouAreReplyingToIs =>
      'الرسالة التي تردّ عليها ليست في هذه المحادثة.';

  @override
  String get serverThisAccountHasBeenSuspendedContactSupport =>
      'تم تعليق هذا الحساب. تواصل مع الدعم إذا كنت تعتقد أن هذا خطأ.';

  @override
  String get serverThisUserDoesNotAcceptDirectMessages =>
      'هذا المستخدم لا يستقبل الرسائل المباشرة.';

  @override
  String get serverTooManyLocationLookupsPleaseSlowDown =>
      'عمليات بحث كثيرة عن المواقع. يرجى التمهّل قليلًا.';

  @override
  String get serverUserBlockedSuccessfully => 'تم حظر المستخدم.';

  @override
  String get serverUserNotFound => 'المستخدم غير موجود.';

  @override
  String get serverUserUnblockedSuccessfully => 'تم إلغاء حظر المستخدم.';

  @override
  String get serverVerificationCodeHasExpiredPleaseRequestA =>
      'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد.';

  @override
  String get serverVerificationCodeIsValid => 'رمز التحقق صحيح.';

  @override
  String get serverVerificationCodeResentSuccessfully =>
      'تمت إعادة إرسال رمز التحقق.';

  @override
  String get serverVerificationCodeSentSuccessfully => 'تم إرسال رمز التحقق.';

  @override
  String get serverYouAlreadyHaveAVerificationRequestUnder =>
      'لديك بالفعل طلب توثيق قيد المراجعة.';

  @override
  String get serverYouAlreadyReportedThisPost =>
      'لقد أبلغت عن هذا المنشور من قبل.';

  @override
  String get serverYouAreNotAParticipantInThis =>
      'أنت لست طرفًا في هذه المحادثة.';

  @override
  String get serverYouAreNotAParticipant => 'أنت لست طرفًا في المحادثة.';

  @override
  String get serverYouCanOnlyDeleteYourOwnMessages => 'يمكنك حذف رسائلك فقط.';

  @override
  String get serverYouCannotBlockYourself => 'لا يمكنك حظر نفسك.';

  @override
  String get serverYouCannotDeleteYourOwnAccountHere =>
      'لا يمكنك حذف حسابك من هنا.';

  @override
  String get serverYouCannotMessageThisUser => 'لا يمكنك مراسلة هذا المستخدم.';

  @override
  String get serverYouCannotMessageYourself => 'لا يمكنك مراسلة نفسك.';

  @override
  String get serverYouCannotRemoveYourOwnAdminRole =>
      'لا يمكنك إزالة صلاحية المشرف عن نفسك.';

  @override
  String get serverYouCannotSuspendYourOwnAccount => 'لا يمكنك تعليق حسابك.';

  @override
  String get serverYouDoNotOwnThisPost => 'هذا المنشور ليس لك.';

  @override
  String get serverYourAccountAndDataHaveBeenDeleted =>
      'تم حذف حسابك وبياناتك.';

  @override
  String get serverYourIdentityIsAlreadyVerified => 'هويتك موثّقة بالفعل.';

  @override
  String get serverThisRequestWasAlreadyHandled =>
      'تمت معالجة هذا الطلب من قبل.';

  @override
  String get serverRequestNotValid => 'الطلب غير صالح.';

  @override
  String get serverSessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get serverNotAllowed => 'غير مسموح لك بذلك.';

  @override
  String get serverProblem => 'واجه الخادم مشكلة. يرجى المحاولة مرة أخرى.';

  @override
  String serverRequestFailed(int status) {
    return 'فشل الطلب ($status).';
  }

  @override
  String get serverTimeout =>
      'استغرق الخادم وقتًا طويلًا للرد. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get serverOffline =>
      'يبدو أنك غير متصل بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get serverThisPostIsAwaitingReview => 'هذا المنشور بانتظار المراجعة.';

  @override
  String get serverApproveOrRejectThisPostFirst =>
      'وافق على هذا المنشور أو ارفضه أولًا.';

  @override
  String get serverCouldNotApproveThePost => 'تعذّرت الموافقة على المنشور.';

  @override
  String get serverCouldNotRejectThePost => 'تعذّر رفض المنشور.';

  @override
  String get serverThatStatusIsNotPublic => 'هذه الحالة غير متاحة للعامة.';

  @override
  String get serverNotAGoogleKey => 'لا يبدو هذا مفتاح Google AI Studio.';

  @override
  String get serverGoogleRejectedTheKey => 'رفض Google AI Studio المفتاح.';
}
