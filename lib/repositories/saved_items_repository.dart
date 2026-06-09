import '../core/utils/result.dart';
import '../models/item_model.dart';

abstract class SavedItemsRepository {
  Future<Result<List<ItemModel>>> getSavedItems();

  Future<Result<void>> updateSavedItems(List<ItemModel> items);
}
