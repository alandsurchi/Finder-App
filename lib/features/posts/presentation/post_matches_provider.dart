import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/item_model.dart';
import '../../../providers/post_provider.dart';

/// Smart matches for one of my posts: lost/found counterparts the server
/// scored on category, words, distance and dates (`GET /posts/:id/matches`).
final postMatchesProvider =
    FutureProvider.autoDispose.family<List<ItemModel>, String>((ref, itemId) {
  if (itemId.isEmpty) return Future.value(const []);
  return ref.watch(postServiceProvider).fetchMatches(itemId);
});
