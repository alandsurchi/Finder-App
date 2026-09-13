import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/item_model.dart';
import '../../../providers/post_provider.dart';

/// Posts in the same category as [itemId], opposite lost/found type first.
final similarItemsProvider =
    FutureProvider.autoDispose.family<List<ItemModel>, String>((ref, itemId) {
  if (itemId.isEmpty) return Future.value(const []);
  return ref.watch(postServiceProvider).fetchSimilar(itemId);
});
