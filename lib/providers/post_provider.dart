import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/post_service.dart';
import '../models/item_model.dart';
import '../app/di/app_providers.dart';
import '../core/utils/polling.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(apiClient: ref.read(apiClientProvider));
});

/// The public feed (active and returned posts), refreshed while the app is
/// on screen. Home hides returned posts; Search shows them with a badge.
final postsStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return pollWhileVisible<List<ItemModel>>(
    ref,
    interval: PostService.pollInterval,
    fetch: () => postService.fetchItems(),
    equals: listsEqual,
  );
});

/// Posts that are still open, for the Home feed.
final activePostsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  return ref
      .watch(postsStreamProvider)
      .whenData((items) => items.where((p) => !p.isResolved).toList());
});

/// One post, fresh from the server (details screen).
final postByIdProvider =
    FutureProvider.autoDispose.family<ItemModel, String>((ref, id) {
  return ref.watch(postServiceProvider).fetchById(id);
});

/// Invalidates every provider that shows posts. Call after create, edit,
/// resolve or delete so lists refresh immediately instead of on next poll.
void refreshPostLists(Ref ref) {
  ref.invalidate(postsStreamProvider);
}
