import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';
import 'mock_analytics_service.dart';

/// Product analytics through Firebase. Every call is fire-and-forget and
/// swallows errors: analytics must never break a user action.
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    try {
      final params = <String, Object>{};
      parameters?.forEach((k, v) {
        if (v != null) params[k] = v is num || v is String ? v : v.toString();
      });
      await _fa.logEvent(name: name, parameters: params.isEmpty ? null : params);
    } catch (e) {
      debugPrint('Analytics: $e');
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _fa.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics: $e');
    }
  }
}

/// Firebase on phones, a no-op elsewhere (web preview, tests).
final analyticsProvider = Provider<AnalyticsService>((ref) {
  if (kIsWeb) return MockAnalyticsService();
  return FirebaseAnalyticsService();
});

/// The handful of moments worth counting.
abstract final class AnalyticsEvents {
  static const postCreated = 'post_created';
  static const postApproved = 'post_approved';
  static const postRejected = 'post_rejected';
  static const postResolved = 'post_resolved';
  static const chatStarted = 'chat_started';
  static const voiceSent = 'voice_message_sent';
  static const languageChanged = 'language_changed';
  static const nearbyOpened = 'nearby_map_opened';
}
