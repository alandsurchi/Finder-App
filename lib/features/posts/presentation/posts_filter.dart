import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/item_model.dart';
import 'posts_controller.dart';

class PostsFilterState {
  final String category;
  final String subFilter;

  const PostsFilterState({
    required this.category,
    required this.subFilter,
  });

  PostsFilterState copyWith({String? category, String? subFilter}) {
    return PostsFilterState(
      category: category ?? this.category,
      subFilter: subFilter ?? this.subFilter,
    );
  }
}

class PostsFilterController extends StateNotifier<PostsFilterState> {
  PostsFilterController()
      : super(const PostsFilterState(category: 'All Items', subFilter: 'Nearby'));

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setSubFilter(String filter) {
    state = state.copyWith(subFilter: filter);
  }
}

final postsFilterProvider = StateNotifierProvider<PostsFilterController, PostsFilterState>(
  (ref) => PostsFilterController(),
);

final filteredPostsProvider = Provider<List<ItemModel>>((ref) {
  final filter = ref.watch(postsFilterProvider);
  final postsState = ref.watch(postsControllerProvider);
  final items = postsState.value ?? [];

  return items.where((item) {
    if (filter.category == 'All Items') return true;
    if (filter.category == 'Lost') return item.isLost;
    if (filter.category == 'Found') return !item.isLost;
    return true;
  }).toList();
});
