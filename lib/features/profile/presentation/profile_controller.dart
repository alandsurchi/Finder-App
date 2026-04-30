import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../models/user_model.dart';

class ProfileController extends StateNotifier<AsyncValue<UserModel>> {
  final Ref ref;

  ProfileController(this.ref) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getProfile();
    state = result.fold(
      onSuccess: (profile) => AsyncValue.data(profile),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<void> updateProfile(UserModel profile) async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(profile);
    state = result.fold(
      onSuccess: (updated) => AsyncValue.data(updated),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }
}

// autoDispose ensures it freshly reloads after every login/signup
final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, AsyncValue<UserModel>>(
  (ref) => ProfileController(ref),
);
