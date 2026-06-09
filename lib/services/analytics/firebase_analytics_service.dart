import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;

  const FirebaseAnalyticsService({required FirebaseAnalytics analytics})
    : _analytics = analytics;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    final safeParams = parameters == null
        ? null
        : Map<String, Object>.fromEntries(
            parameters.entries
                .where((entry) => entry.value != null)
                .map((entry) => MapEntry(entry.key, entry.value as Object)),
          );

    await _analytics.logEvent(name: name, parameters: safeParams);
  }

  @override
  Future<void> setUserProperty(String name, String value) {
    return _analytics.setUserProperty(name: name, value: value);
  }
}
