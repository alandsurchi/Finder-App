import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// The languages Finder ships in. Kurdish is Central Kurdish (Sorani),
/// written in the Arabic script and read right-to-left.
enum AppLanguage {
  english(Locale('en'), 'English'),
  arabic(Locale('ar'), 'العربية'),
  kurdish(Locale('ckb'), 'کوردی');

  final Locale locale;
  final String nativeName;
  const AppLanguage(this.locale, this.nativeName);

  bool get isRtl => this != AppLanguage.english;

  static AppLanguage? fromCode(String? code) {
    if (code == null) return null;
    for (final l in values) {
      if (l.locale.languageCode == code) return l;
    }
    // Android reports Sorani as "ckb"; some devices still use "ku".
    if (code == 'ku') return AppLanguage.kurdish;
    return null;
  }

  /// Best match for a device locale (null when the phone speaks neither).
  static AppLanguage? forDevice(Locale device) => fromCode(device.languageCode);
}

const List<Locale> kSupportedLocales = [Locale('en'), Locale('ar'), Locale('ckb')];

/// Resolves the app locale: a saved choice wins, then the phone language,
/// then English. Flutter calls this with the phone locales on startup.
Locale resolveLocale(Locale? saved, List<Locale>? device) {
  if (saved != null) return saved;
  for (final d in device ?? const <Locale>[]) {
    final match = AppLanguage.forDevice(d);
    if (match != null) return match.locale;
  }
  return const Locale('en');
}

/// Access to the strings outside the widget tree (services, providers,
/// error mapping). Kept in sync by the locale controller.
class L10n {
  L10n._();
  static AppLocalizations current = lookupAppLocalizations(const Locale('en'));
  static Locale locale = const Locale('en');

  static void use(Locale l) {
    locale = l;
    current = lookupAppLocalizations(l);
  }

  static bool get isRtl => AppLanguage.fromCode(locale.languageCode)?.isRtl ?? false;
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
