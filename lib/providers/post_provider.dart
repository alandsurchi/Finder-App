import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/post_service.dart';
import '../models/item_model.dart';
import '../app/di/app_providers.dart';

final postServiceProvider = Provider<PostService>((ref) {
  return PostService(apiClient: ref.read(apiClientProvider));
});

final postsStreamProvider = StreamProvider<List<ItemModel>>((ref) {
  final postService = ref.watch(postServiceProvider);
  return postService.getPostsStream();
});
