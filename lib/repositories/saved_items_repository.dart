import '../core/utils/result.dart';
import '../models/item_model.dart';

abstract class SavedItemsRepository {
  Future<Result<List<ItemModel>>> getSavedItems();

  /// Saves ([saved] = true) or removes a single post from the list.
  Future<Result<void>> setSaved(String postId, bool saved);
}
