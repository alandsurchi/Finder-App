import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../models/item_model.dart';
import '../saved_items_repository.dart';

class SavedItemsRepositoryImpl implements SavedItemsRepository {
  final ApiClient _apiClient;

  const SavedItemsRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Result<List<ItemModel>>> getSavedItems() async {
    if (!_apiClient.isAuthenticated) {
      return Result.success(const []);
    }

    try {
      final res = await _apiClient.get('/profile/saved');
      final list = res as List<dynamic>? ?? [];
      final items = list
          .map((e) => ItemModel.fromApi(Map<String, dynamic>.from(e as Map)))
          .toList();
      return Result.success(items);
    } catch (e) {
      return Result.failure(
        failureFrom(e, fallback: 'Unable to load saved items.'),
      );
    }
  }

  @override
  Future<Result<void>> setSaved(String postId, bool saved) async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to save items.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      if (saved) {
        await _apiClient.post('/profile/saved', {'postId': postId});
      } else {
        await _apiClient.delete('/profile/saved/$postId');
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        failureFrom(e, fallback: 'Unable to update saved items.'),
      );
    }
  }
}
