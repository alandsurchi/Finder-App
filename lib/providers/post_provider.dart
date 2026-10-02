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

/// Older pages below the polled first page. [loadMore] appends the next
/// page; the first page keeps refreshing on its own.
class FeedPager extends StateNotifier<FeedPagerState> {
  FeedPager(this.ref) : super(const FeedPagerState());
  final Ref ref;

  Future<void> loadMore(List<ItemModel> visible) async {
    if (state.loading || state.exhausted || visible.isEmpty) return;
    state = state.copyWith(loading: true);
    try {
      final cursor = visible.last.createdAt.millisecondsSinceEpoch.toString();
      final page = await ref.read(postServiceProvider).fetchPage(cursor: cursor, limit: 30);
      final known = visible.map((p) => p.id).toSet()..addAll(state.extra.map((p) => p.id));
      state = state.copyWith(
        extra: [...state.extra, ...page.items.where((p) => !known.contains(p.id))],
        exhausted: !page.hasMore,
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void reset() => state = const FeedPagerState();
}

class FeedPagerState {
  final List<ItemModel> extra;
  final bool loading;
  final bool exhausted;
  const FeedPagerState({this.extra = const [], this.loading = false, this.exhausted = false});
  FeedPagerState copyWith({List<ItemModel>? extra, bool? loading, bool? exhausted}) => FeedPagerState(
        extra: extra ?? this.extra,
        loading: loading ?? this.loading,
        exhausted: exhausted ?? this.exhausted,
      );
}

final feedPagerProvider = StateNotifierProvider<FeedPager, FeedPagerState>((ref) => FeedPager(ref));

/// Posts that are still open, for the Home feed: the polled first page
/// followed by the pages the user scrolled into.
final activePostsProvider = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final extra = ref.watch(feedPagerProvider).extra;
  return ref.watch(postsStreamProvider).whenData((items) {
    final ids = items.map((p) => p.id).toSet();
    return [...items, ...extra.where((p) => !ids.contains(p.id))].where((p) => !p.isResolved).toList();
  });
});

/// Server search over every language, used once the query has 2+ letters.
final searchPostsProvider = FutureProvider.autoDispose.family<List<ItemModel>, String>((ref, q) {
  return ref.read(postServiceProvider).fetchItems(q: q, limit: 100);
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
  ref.read(feedPagerProvider.notifier).reset();
}
