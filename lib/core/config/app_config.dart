import 'package:flutter/foundation.dart';

/// Build-time configuration.
///
/// Values come from `--dart-define`:
///   flutter build apk --dart-define=API_URL=https://api.example.com
///
/// Debug builds fall back to a local backend so `flutter run` just works.
/// Release builds must provide [apiUrl]; [configurationError] explains what
/// is missing so the app can show it instead of silently calling localhost.
class AppConfig {
  AppConfig._();

  static const String _apiUrlDefine = String.fromEnvironment('API_URL');
  static const String supportEmail =
      String.fromEnvironment('SUPPORT_EMAIL', defaultValue: 'support@finder.app');
  static const String privacyEmail =
      String.fromEnvironment('PRIVACY_EMAIL', defaultValue: 'privacy@finder.app');

  /// The backend base URL without a trailing slash.
  static String get apiUrl {
    if (_apiUrlDefine.isNotEmpty) return _stripSlash(_apiUrlDefine);
    if (kReleaseMode) return '';
    return _debugDefault();
  }

  /// Null when the build is usable; otherwise a message for the config screen.
  static String? get configurationError {
    if (apiUrl.isEmpty) {
      return 'This build has no API_URL. Rebuild with '
          '--dart-define=API_URL=https://your-backend.example.com';
    }
    if (kReleaseMode && !apiUrl.startsWith('https://')) {
      return 'Release builds must talk to the API over https. Got: $apiUrl';
    }
    return null;
  }

  /// Hosted legal pages, served by the backend.
  static String get privacyPolicyUrl => '$apiUrl/legal/privacy';
  static String get termsUrl => '$apiUrl/legal/terms';

  static String _debugDefault() {
    if (kIsWeb) return 'http://localhost:3001';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  static String _stripSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}
