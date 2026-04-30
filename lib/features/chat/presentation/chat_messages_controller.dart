import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/pagination.dart';
import '../../../features/auth/presentation/auth_state_provider.dart';
import '../domain/message.dart';

class ChatMessagesController extends StateNotifier<AsyncValue<List<Message>>> {
  final Ref ref;
  final String chatId;

  ChatMessagesController({required this.ref, required this.chatId})
      : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    final usecase = ref.read(getMessagesProvider);
    final result = await usecase(chatId: chatId, pageRequest: const PageRequest());
    state = result.fold(
      onSuccess: (page) => AsyncValue.data(page.items),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<void> send(String text) async {
    final senderId = ref.read(authStateProvider).userId ?? '';
    if (senderId.isEmpty) return;

    // The legacy ChatMessagesController is superseded by the real-time
    // messagesStreamProvider in chat_provider.dart. This send() path is
    // kept here only for backward compatibility but is not used by ChatScreen.
    final message = Message(
      messageId: '',
      senderId: senderId,
      receiverId: '',
      text: text,
      createdAt: Timestamp.now(),
    );

    final usecase = ref.read(sendMessageProvider);
    final result = await usecase(message);
    result.fold(
      onSuccess: (created) {
        final current = state.value ?? [];
        state = AsyncValue.data([created, ...current]);
      },
      onFailure: (failure) => state = AsyncValue.error(failure, StackTrace.current),
    );
  }
}

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesController, AsyncValue<List<Message>>, String>(
  (ref, chatId) => ChatMessagesController(ref: ref, chatId: chatId),
);
