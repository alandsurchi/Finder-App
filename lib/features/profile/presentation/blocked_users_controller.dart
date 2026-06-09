import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../domain/blocked_user.dart';

class BlockedUsersController extends StateNotifier<AsyncValue<List<BlockedUser>>> {
  final Ref ref;

  BlockedUsersController(this.ref) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getBlockedUsers();
    state = result.fold(
      onSuccess: (users) => AsyncValue.data(users),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<void> unblockUser(String userId) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.unblockUser(userId);
    await loadUsers();
  }
}

final blockedUsersProvider = StateNotifierProvider<BlockedUsersController, AsyncValue<List<BlockedUser>>>(
  (ref) => BlockedUsersController(ref),
);
