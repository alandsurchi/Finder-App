import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import 'post_provider.dart';
import '../features/auth/presentation/auth_state_provider.dart';

class MyPostsNotifier extends StateNotifier<AsyncValue<List<ItemModel>>> {
  final Ref ref;

  MyPostsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final authState = ref.read(authStateProvider);
    final user = authState.userId;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final posts = await ref.read(postServiceProvider).fetchItems(ownerId: user);
      state = AsyncValue.data(posts);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await ref.read(postServiceProvider).deletePost(postId);
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.where((p) => p.id != postId).toList(),
      );
    } catch (_) {}
  }

  Future<void> markResolved(String postId) async {
    try {
      await ref.read(postServiceProvider).markAsResolved(postId);
      final current = state.value ?? [];

      state = AsyncValue.data(current.map((p) {
        if (p.id == postId) {
          return ItemModel(
            id: p.id,
            ownerId: p.ownerId,
            title: p.title,
            description: p.description,
            createdAt: p.createdAt,
            location: p.location,
            timeAgo: p.timeAgo,
            imagePath: p.imagePath,
            isLost: p.isLost,
            reward: p.reward,
            isVerified: p.isVerified,
            category: p.category,
            lostOn: p.lostOn,
            lastSeenAt: p.lastSeenAt,
            ownerName: p.ownerName,
            ownerTrustScore: p.ownerTrustScore,
            isResolved: true,
          );
        }
        return p;
      }).toList());
    } catch (_) {}
  }

  Future<void> updatePost(ItemModel updated) async {
    try {
      final data = updated.toMap()
        ..['updatedAtMs'] = DateTime.now().millisecondsSinceEpoch;
      data.remove('createdAt'); // Not JSON-serializable
      await ref.read(postServiceProvider).updatePost(updated.id, data);

      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((p) => p.id == updated.id ? updated : p).toList(),
      );
    } catch (_) {}
  }
}

final myPostsProvider =
    StateNotifierProvider<MyPostsNotifier, AsyncValue<List<ItemModel>>>(
  (ref) => MyPostsNotifier(ref),
);
