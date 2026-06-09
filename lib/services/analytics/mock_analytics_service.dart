import 'analytics_service.dart';

class MockAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {}

  @override
  Future<void> setUserProperty(String name, String value) async {}
}
