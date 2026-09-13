import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/result.dart';
import '../../../models/item_model.dart';

/// The user's bookmarked posts. Toggling is optimistic: the list updates at
/// once and is rolled back if the server rejects the change.
class SavedItemsController extends StateNotifier<AsyncValue<List<ItemModel>>> {
  final Ref ref;

  SavedItemsController(this.ref) : super(const AsyncValue.loading()) {
    loadSavedItems();
  }

  Future<void> loadSavedItems() async {
    final repo = ref.read(savedItemsRepositoryProvider);
    final result = await repo.getSavedItems();
    state = result.fold(
      onSuccess: (items) => AsyncValue.data(items),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  bool isSaved(String postId) =>
      (state.value ?? const []).any((i) => i.id == postId);

  /// Returns the new saved state on success.
  Future<Result<bool>> toggleSaved(ItemModel item) async {
    final before = List<ItemModel>.from(state.value ?? []);
    final wasSaved = before.any((i) => i.id == item.id);
    final after = wasSaved
        ? before.where((i) => i.id != item.id).toList()
        : [item, ...before];
    state = AsyncValue.data(after);

    final repo = ref.read(savedItemsRepositoryProvider);
    final result = await repo.setSaved(item.id, !wasSaved);
    return result.fold(
      onSuccess: (_) => Result.success(!wasSaved),
      onFailure: (failure) {
        state = AsyncValue.data(before);
        return Result.failure(failure);
      },
    );
  }
}

final savedItemsProvider = StateNotifierProvider<SavedItemsController, AsyncValue<List<ItemModel>>>(
  (ref) => SavedItemsController(ref),
);
