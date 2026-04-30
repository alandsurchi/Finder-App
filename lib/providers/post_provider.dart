import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/post_service.dart';
import '../models/item_model.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService();
});

final postsStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return postService.getPostsStream();
});
