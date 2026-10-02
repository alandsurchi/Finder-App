import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/chat_provider.dart';
import '../providers/my_posts_provider.dart';
import '../providers/post_provider.dart';
import '../services/analytics/firebase_analytics_service.dart';
import 'l10n.dart';

const _kLocaleKey = 'app_language';

/// The language the user picked, or null to follow the phone. Persisted so
/// the choice survives restarts; read before the first frame in main().
class LocaleController extends Notifier<Locale?> {
  final Locale? _initial;
  LocaleController([this._initial]);

  @override
  Locale? build() {
    final l = _initial;
    if (l != null) L10n.use(l);
    return l;
  }

  Future<void> set(AppLanguage? language) async {
    state = language?.locale;
    L10n.use(resolveLocale(state, WidgetsBinding.instance.platformDispatcher.locales));
    // Post text is served in the app language: fetch it again.
    ref.invalidate(postsStreamProvider);
    ref.invalidate(conversationsStreamProvider);
    ref.read(myPostsProvider.notifier).load();
    ref.read(analyticsProvider).logEvent(AnalyticsEvents.languageChanged, parameters: {'language': language?.locale.languageCode ?? 'system'});
    final prefs = await SharedPreferences.getInstance();
    if (language == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, language.locale.languageCode);
    }
  }

  static Future<Locale?> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppLanguage.fromCode(prefs.getString(_kLocaleKey))?.locale;
    } catch (_) {
      return null;
    }
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
