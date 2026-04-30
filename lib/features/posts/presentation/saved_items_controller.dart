import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../models/item_model.dart';

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

  Future<void> toggleSaved(ItemModel item) async {
    final current = List<ItemModel>.from(state.value ?? []);
    final exists = current.any((i) => i.id == item.id);
    if (exists) {
      current.removeWhere((i) => i.id == item.id);
    } else {
      current.add(item);
    }
    final repo = ref.read(savedItemsRepositoryProvider);
    await repo.updateSavedItems(current);
    state = AsyncValue.data(current);
  }
}

final savedItemsProvider = StateNotifierProvider<SavedItemsController, AsyncValue<List<ItemModel>>>(
  (ref) => SavedItemsController(ref),
);
