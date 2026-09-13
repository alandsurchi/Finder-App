import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/result.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/post_provider.dart';
import '../domain/blocked_user.dart';

class BlockedUsersController extends StateNotifier<AsyncValue<List<BlockedUser>>> {
  final Ref ref;

  BlockedUsersController(this.ref) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getBlockedUsers();
    if (!mounted) return;
    state = result.fold(
      onSuccess: (users) => AsyncValue.data(users),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Blocking hides the other user's posts and conversations, so those
  /// lists are refreshed afterwards.
  Future<Result<void>> blockUser(String userId, {String? name, String avatarUrl = ''}) async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.blockUser(userId);
    if (result.isSuccess) {
      final current = List<BlockedUser>.from(state.value ?? const []);
      if (!current.any((u) => u.id == userId)) {
        final label = (name ?? '?').trim();
        current.insert(
          0,
          BlockedUser(
            id: userId,
            name: name ?? 'Member',
            avatarLabel: label.isEmpty ? '?' : label.substring(0, 1).toUpperCase(),
            avatarUrl: avatarUrl,
          ),
        );
      }
      if (mounted) state = AsyncValue.data(current);
      _refreshDependents();
      loadUsers();
    }
    return result;
  }

  Future<Result<void>> unblockUser(String userId) async {
    final repo = ref.read(profileRepositoryProvider);
    final before = List<BlockedUser>.from(state.value ?? const []);
    state = AsyncValue.data(before.where((u) => u.id != userId).toList());
    final result = await repo.unblockUser(userId);
    if (!result.isSuccess && mounted) {
      state = AsyncValue.data(before);
    } else {
      _refreshDependents();
    }
    return result;
  }

  void _refreshDependents() {
    ref.invalidate(postsStreamProvider);
    ref.invalidate(conversationsStreamProvider);
  }
}

final blockedUsersProvider = StateNotifierProvider<BlockedUsersController, AsyncValue<List<BlockedUser>>>(
  (ref) => BlockedUsersController(ref),
);
