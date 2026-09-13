import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/result.dart';
import '../../../models/user_model.dart';

/// The signed-in user's profile. Kept alive for the whole session so the
/// Home header, Profile tab and edit screen share one copy; it is
/// invalidated by the app when the session changes.
class ProfileController extends StateNotifier<AsyncValue<UserModel>> {
  final Ref ref;

  ProfileController(this.ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (!state.hasValue) state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getProfile();
    if (!mounted) return;
    result.fold(
      onSuccess: (profile) => state = AsyncValue.data(profile),
      onFailure: (failure) {
        if (!state.hasValue) {
          state = AsyncValue.error(failure, StackTrace.current);
        }
      },
    );
  }

  /// Saves and updates the shared copy in place. The previous profile is
  /// kept on failure.
  Future<Result<UserModel>> updateProfile(UserModel profile) async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(profile);
    if (mounted) {
      result.fold(
        onSuccess: (updated) => state = AsyncValue.data(updated),
        onFailure: (_) {},
      );
    }
    return result;
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<UserModel>>(
  (ref) => ProfileController(ref),
);
