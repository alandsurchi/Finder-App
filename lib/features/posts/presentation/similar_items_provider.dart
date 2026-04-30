import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/item_model.dart';

final similarItemsProvider = FutureProvider.family<List<ItemModel>, String>((ref, itemId) async {
  return const [];
});
