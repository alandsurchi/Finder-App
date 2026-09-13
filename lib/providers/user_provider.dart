import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/user_model.dart';
import '../app/di/app_providers.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>(
  (ref) => UserService(apiClient: ref.read(apiClientProvider)),
);

/// Another user's public profile (privacy-aware on the server). Null when
/// the id is empty or the user cannot be seen (blocked, deleted).
final userProfileProvider =
    FutureProvider.autoDispose.family<UserModel?, String>((ref, userId) async {
  if (userId.isEmpty) return null;
  try {
    return await ref.read(userServiceProvider).fetchProfile(userId);
  } catch (_) {
    return null;
  }
});
