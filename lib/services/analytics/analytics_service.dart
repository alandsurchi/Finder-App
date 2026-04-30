abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});

  Future<void> setUserProperty(String name, String value);
}
