import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../models/conversation_model.dart';

class ConversationsController extends StateNotifier<AsyncValue<List<ConversationModel>>> {
  final Ref ref;
  List<ConversationModel> _all = [];
  String _query = '';

  ConversationsController(this.ref) : super(const AsyncValue.loading()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    final usecase = ref.read(getConversationsProvider);
    final result = await usecase();
    state = result.fold(
      onSuccess: (items) {
        _all = items;
        return AsyncValue.data(_applyQuery(items, _query));
      },
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  void updateQuery(String query) {
    _query = query;
    state = AsyncValue.data(_applyQuery(_all, _query));
  }

  List<ConversationModel> _applyQuery(List<ConversationModel> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.message.toLowerCase().contains(q))
        .toList();
  }
}

final conversationsControllerProvider = StateNotifierProvider<ConversationsController, AsyncValue<List<ConversationModel>>>(
  (ref) => ConversationsController(ref),
);
