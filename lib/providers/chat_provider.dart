import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/services/chat_service.dart';
import 'package:finder/models/conversation_model.dart';
import 'package:finder/features/chat/domain/message.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import '../app/di/app_providers.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(apiClient: ref.read(apiClientProvider));
});

final conversationsStreamProvider = StreamProvider<List<ConversationModel>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final userId = ref.watch(authStateProvider).userId ?? '';
  
  if (userId.isEmpty) {
    return Stream.value([]);
  }
  
  return chatService.getConversationsStream(userId);
});

final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.getMessagesStream(chatId);
});
