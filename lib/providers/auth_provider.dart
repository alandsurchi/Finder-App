import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/railway_auth_service.dart';
import '../app/di/app_providers.dart';

// Canonical authServiceProvider — used across the whole app
final authServiceProvider = Provider<AuthService>((ref) {
  return RailwayAuthService(apiClient: ref.read(apiClientProvider));
});
