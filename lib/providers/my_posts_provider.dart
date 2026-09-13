import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/exceptions.dart';
import '../core/errors/failure.dart';
import '../core/utils/result.dart';
import '../models/item_model.dart';
import 'post_provider.dart';
import '../features/auth/presentation/auth_state_provider.dart';

/// The signed-in user's own posts (active and resolved).
class MyPostsNotifier extends StateNotifier<AsyncValue<List<ItemModel>>> {
  final Ref ref;

  MyPostsNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    if (!state.hasValue) state = const AsyncValue.loading();
    final user = ref.read(authStateProvider).userId;
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final posts = await ref.read(postServiceProvider).fetchItems(ownerId: user);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(
        failureFrom(e, fallback: 'Unable to load your posts.'),
        st,
      );
    }
  }

  List<ItemModel> get _current => List<ItemModel>.from(state.value ?? []);

  Future<Result<void>> deletePost(String postId) async {
    try {
      await ref.read(postServiceProvider).deletePost(postId);
      state = AsyncValue.data(_current.where((p) => p.id != postId).toList());
      ref.invalidate(postsStreamProvider);
      return Result.success(null);
    } catch (e) {
      return Result.failure(failureFrom(e, fallback: 'Unable to delete the post.'));
    }
  }

  Future<Result<void>> markResolved(String postId) async {
    try {
      final updated = await ref.read(postServiceProvider).markAsResolved(postId);
      state = AsyncValue.data(
        _current.map((p) => p.id == postId ? updated : p).toList(),
      );
      ref.invalidate(postsStreamProvider);
      return Result.success(null);
    } catch (e) {
      return Result.failure(failureFrom(e, fallback: 'Unable to resolve the post.'));
    }
  }

  Future<Result<void>> reopen(String postId) async {
    try {
      final updated = await ref.read(postServiceProvider).reopen(postId);
      state = AsyncValue.data(
        _current.map((p) => p.id == postId ? updated : p).toList(),
      );
      ref.invalidate(postsStreamProvider);
      return Result.success(null);
    } catch (e) {
      return Result.failure(failureFrom(e, fallback: 'Unable to reopen the post.'));
    }
  }

  Future<Result<ItemModel>> updatePost(ItemModel updated) async {
    try {
      final saved = await ref
          .read(postServiceProvider)
          .updatePost(updated.id, updated.toApiBody());
      state = AsyncValue.data(
        _current.map((p) => p.id == saved.id ? saved : p).toList(),
      );
      ref.invalidate(postsStreamProvider);
      return Result.success(saved);
    } catch (e) {
      return Result.failure(failureFrom(e, fallback: 'Unable to save the post.'));
    }
  }

  /// Adds a freshly created post to the top of the list.
  void prepend(ItemModel post) {
    state = AsyncValue.data([post, ..._current]);
  }
}

final myPostsProvider =
    StateNotifierProvider<MyPostsNotifier, AsyncValue<List<ItemModel>>>(
  (ref) => MyPostsNotifier(ref),
);

/// Convenience: a [Failure] message for `AsyncValue.error` values.
String describeError(Object error) {
  if (error is Failure) return error.message;
  if (error is AppException) return error.message;
  return 'Something went wrong. Please try again.';
}
