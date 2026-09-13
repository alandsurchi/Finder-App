import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/post_service.dart';
import '../models/item_model.dart';
import '../app/di/app_providers.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(apiClient: ref.read(apiClientProvider));
});

/// The public feed: active posts, refreshed every few seconds.
final postsStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return postService.getPostsStream(status: 'active');
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
