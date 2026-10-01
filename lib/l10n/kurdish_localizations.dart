import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart' as date_symbols;
import 'package:intl/intl.dart' as intl;

/// Flutter ships no Central Kurdish (Sorani, `ckb`) translations for its
/// own widgets, so these delegates fill the gap: Kurdish labels for
/// dialogs, pickers and the text-selection menu, Kurdish month and weekday
/// names, right-to-left layout, and Arabic (the closest script) for the
/// few Cupertino strings this Material app never shows.
class KurdishLocalizations {
  KurdishLocalizations._();

  static const Locale locale = Locale('ckb');

  static const List<LocalizationsDelegate<dynamic>> delegates = [
    _KurdishMaterialDelegate(),
    _KurdishWidgetsDelegate(),
    _KurdishCupertinoDelegate(),
  ];

  static const List<String> months = [
    'کانوونی دووەم', 'شوبات', 'ئازار', 'نیسان', 'ئایار', 'حوزەیران',
    'تەممووز', 'ئاب', 'ئەیلوول', 'تشرینی یەکەم', 'تشرینی دووەم', 'کانوونی یەکەم',
  ];
  static const List<String> monthsShort = [
    'کانوونی ٢', 'شوبات', 'ئازار', 'نیسان', 'ئایار', 'حوزەیران',
    'تەممووز', 'ئاب', 'ئەیلوول', 'تشرینی ١', 'تشرینی ٢', 'کانوونی ١',
  ];
  // Sunday first, matching [MaterialLocalizations.narrowWeekdays].
  static const List<String> weekdays = [
    'یەکشەممە', 'دووشەممە', 'سێشەممە', 'چوارشەممە', 'پێنجشەممە', 'هەینی', 'شەممە',
  ];
  static const List<String> weekdaysNarrow = ['ی', 'د', 'س', 'چ', 'پ', 'هـ', 'ش'];
}

bool _isKurdish(Locale l) => l.languageCode == 'ckb' || l.languageCode == 'ku';

class _KurdishMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _KurdishMaterialDelegate();

  @override
  bool isSupported(Locale locale) => _isKurdish(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // Western digits as a base; the user-visible month and weekday names
    // are overridden below.
    await date_symbols.initializeDateFormatting('en', null);
    const n = 'en';
    return _KurdishMaterialLocalizations(
      fullYearFormat: intl.DateFormat.y(n),
      compactDateFormat: intl.DateFormat.yMd(n),
      shortDateFormat: intl.DateFormat.yMMMd(n),
      mediumDateFormat: intl.DateFormat.MMMEd(n),
      longDateFormat: intl.DateFormat.yMMMMEEEEd(n),
      yearMonthFormat: intl.DateFormat.yMMMM(n),
      shortMonthDayFormat: intl.DateFormat.MMMd(n),
      decimalFormat: intl.NumberFormat.decimalPattern(n),
      twoDigitZeroPaddedFormat: intl.NumberFormat('00', n),
    );
  }

  @override
  bool shouldReload(_KurdishMaterialDelegate old) => false;
}

class _KurdishMaterialLocalizations extends MaterialLocalizationAr {
  const _KurdishMaterialLocalizations({
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  }) : super(localeName: 'ckb');

  // ── Dates ────────────────────────────────────────────────────────────────
  @override
  List<String> get narrowWeekdays => KurdishLocalizations.weekdaysNarrow;

  /// Weeks start on Saturday in Iraq.
  @override
  int get firstDayOfWeekIndex => 6;

  @override
  String formatMediumDate(DateTime date) =>
      '${KurdishLocalizations.weekdays[date.weekday % 7]}، ${date.day} ${KurdishLocalizations.monthsShort[date.month - 1]}';

  @override
  String formatFullDate(DateTime date) =>
      '${KurdishLocalizations.weekdays[date.weekday % 7]}، ${date.day} ${KurdishLocalizations.months[date.month - 1]} ${date.year}';

  @override
  String formatMonthYear(DateTime date) =>
      '${KurdishLocalizations.months[date.month - 1]} ${date.year}';

  @override
  String formatShortMonthDay(DateTime date) =>
      '${date.day} ${KurdishLocalizations.monthsShort[date.month - 1]}';

  @override
  String formatShortDate(DateTime date) =>
      '${date.day} ${KurdishLocalizations.monthsShort[date.month - 1]} ${date.year}';

  @override
  String formatCompactDate(DateTime date) =>
      '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

  @override
  String get dateHelpText => 'ساڵ/مانگ/ڕۆژ';

  @override
  String get anteMeridiemAbbreviation => 'پ.ن';
  @override
  String get postMeridiemAbbreviation => 'د.ن';

  // ── Buttons and dialogs ──────────────────────────────────────────────────
  @override
  String get okButtonLabel => 'باشە';
  @override
  String get cancelButtonLabel => 'پاشگەزبوونەوە';
  @override
  String get closeButtonLabel => 'داخستن';
  @override
  String get continueButtonLabel => 'بەردەوامبوون';
  @override
  String get saveButtonLabel => 'پاشەکەوتکردن';
  @override
  String get deleteButtonTooltip => 'سڕینەوە';
  @override
  String get backButtonTooltip => 'گەڕانەوە';
  @override
  String get closeButtonTooltip => 'داخستن';
  @override
  String get moreButtonTooltip => 'زیاتر';
  @override
  String get showMenuTooltip => 'پیشاندانی مینیو';
  @override
  String get openAppDrawerTooltip => 'کردنەوەی مینیوی ڕێنیشاندەر';
  @override
  String get searchFieldLabel => 'گەڕان';
  @override
  String get modalBarrierDismissLabel => 'داخستن';
  @override
  String get scrimLabel => 'پەردە';
  @override
  String get bottomSheetLabel => 'شیتی خوارەوە';
  @override
  String get dialogLabel => 'دیالۆگ';
  @override
  String get alertDialogLabel => 'ئاگاداری';
  @override
  String get drawerLabel => 'مینیوی ڕێنیشاندەر';
  @override
  String get popupMenuLabel => 'مینیوی سەرهەڵدەر';
  @override
  String get menuBarMenuLabel => 'مینیو';
  @override
  String get refreshIndicatorSemanticLabel => 'نوێکردنەوە';
  @override
  String get expandedIconTapHint => 'داخستن';
  @override
  String get collapsedIconTapHint => 'کردنەوە';

  // ── Text selection ───────────────────────────────────────────────────────
  @override
  String get copyButtonLabel => 'لەبەرگرتنەوە';
  @override
  String get cutButtonLabel => 'بڕین';
  @override
  String get pasteButtonLabel => 'لکاندن';
  @override
  String get selectAllButtonLabel => 'هەموو دیاری بکە';
  @override
  String get lookUpButtonLabel => 'سەیرکردن';
  @override
  String get searchWebButtonLabel => 'گەڕان لە وێب';
  @override
  String get shareButtonLabel => 'هاوبەشکردن';
  @override
  String get scanTextButtonLabel => 'سکانکردنی دەق';
  @override
  String get clearButtonTooltip => 'سڕینەوەی دەق';

  // ── Pickers ──────────────────────────────────────────────────────────────
  @override
  String get datePickerHelpText => 'ڕێکەوت هەڵبژێرە';
  @override
  String get dateInputLabel => 'ڕێکەوت بنووسە';
  @override
  String get dateRangePickerHelpText => 'ماوە هەڵبژێرە';
  @override
  String get dateRangeStartLabel => 'ڕێکەوتی دەستپێک';
  @override
  String get dateRangeEndLabel => 'ڕێکەوتی کۆتایی';
  @override
  String get invalidDateFormatLabel => 'شێوازی ڕێکەوت هەڵەیە.';
  @override
  String get invalidDateRangeLabel => 'ماوەکە هەڵەیە.';
  @override
  String get dateOutOfRangeLabel => 'دەرەوەی ماوەیە.';
  @override
  String get unspecifiedDate => 'ڕێکەوت';
  @override
  String get unspecifiedDateRange => 'ماوەی ڕێکەوت';
  @override
  String get calendarModeButtonLabel => 'گۆڕین بۆ ڕۆژژمێر';
  @override
  String get inputDateModeButtonLabel => 'گۆڕین بۆ نووسین';
  @override
  String get nextMonthTooltip => 'مانگی داهاتوو';
  @override
  String get previousMonthTooltip => 'مانگی پێشوو';
  @override
  String get selectYearSemanticsLabel => 'ساڵ هەڵبژێرە';
  @override
  String get currentDateLabel => 'ئەمڕۆ';
  @override
  String get selectedDateLabel => 'هەڵبژێردراو';
  @override
  String get timePickerDialHelpText => 'کات هەڵبژێرە';
  @override
  String get timePickerInputHelpText => 'کات بنووسە';
  @override
  String get timePickerHourLabel => 'کاتژمێر';
  @override
  String get timePickerMinuteLabel => 'خولەک';
  @override
  String get timePickerHourModeAnnouncement => 'کاتژمێر هەڵبژێرە';
  @override
  String get timePickerMinuteModeAnnouncement => 'خولەک هەڵبژێرە';
  @override
  String get dialModeButtonLabel => 'گۆڕین بۆ هەڵبژاردنی کاتژمێر';
  @override
  String get inputTimeModeButtonLabel => 'گۆڕین بۆ نووسینی کات';
  @override
  String get invalidTimeLabel => 'کاتێکی دروست بنووسە';

  // ── Paging and misc ──────────────────────────────────────────────────────
  @override
  String get firstPageTooltip => 'یەکەم لاپەڕە';
  @override
  String get lastPageTooltip => 'دوا لاپەڕە';
  @override
  String get nextPageTooltip => 'لاپەڕەی داهاتوو';
  @override
  String get previousPageTooltip => 'لاپەڕەی پێشوو';
  @override
  String get rowsPerPageTitle => 'ڕیز بۆ هەر لاپەڕەیەک:';
  @override
  String get licensesPageTitle => 'مۆڵەتەکان';
  @override
  String get viewLicensesButtonLabel => 'بینینی مۆڵەتەکان';
  @override
  String get signedInLabel => 'چوونەژوورەوە کراوە';
  @override
  String get hideAccountsLabel => 'شاردنەوەی هەژمارەکان';
  @override
  String get showAccountsLabel => 'پیشاندانی هەژمارەکان';
  @override
  String get reorderItemToStart => 'بیبە بۆ سەرەتا';
  @override
  String get reorderItemToEnd => 'بیبە بۆ کۆتایی';
  @override
  String get reorderItemUp => 'بیبە سەرەوە';
  @override
  String get reorderItemDown => 'بیبە خوارەوە';
  @override
  String get reorderItemLeft => 'بیبە چەپ';
  @override
  String get reorderItemRight => 'بیبە ڕاست';
}

class _KurdishWidgetsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _KurdishWidgetsDelegate();

  @override
  bool isSupported(Locale locale) => _isKurdish(locale);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      SynchronousFuture(getWidgetsTranslation(const Locale('ar'))!);

  @override
  bool shouldReload(_KurdishWidgetsDelegate old) => false;
}

class _KurdishCupertinoDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KurdishCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => _isKurdish(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_KurdishCupertinoDelegate old) => false;
}
