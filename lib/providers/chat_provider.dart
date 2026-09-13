import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/errors/exceptions.dart';
import 'package:finder/core/utils/result.dart';
import 'package:finder/core/utils/timestamp.dart';
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
  if (userId.isEmpty) return Stream.value(const []);
  return chatService.getConversationsStream(userId);
});

/// Total unread conversations, for the Messages tab badge.
final unreadConversationsCountProvider = Provider<int>((ref) {
  final convos = ref.watch(conversationsStreamProvider).value ?? const [];
  return convos.where((c) => c.unreadCount > 0).length;
});

/// Messages of one chat: polled from the server, merged with the messages
/// that are still being sent (optimistic) or failed to send.
class ChatMessagesController extends StateNotifier<AsyncValue<List<Message>>> {
  final Ref ref;
  final String chatId;
  Timer? _timer;
  List<Message> _server = const [];
  final List<Message> _pending = [];
  int _localSeq = 0;

  ChatMessagesController(this.ref, this.chatId)
      : super(const AsyncValue.loading()) {
    load();
    _timer = Timer.periodic(ChatService.messagesInterval, (_) => load());
  }

  ChatService get _service => ref.read(chatServiceProvider);

  Future<void> load() async {
    try {
      _server = await _service.fetchMessages(chatId);
      _publish();
    } catch (e, st) {
      if (!state.hasValue) {
        state = AsyncValue.error(
          failureFrom(e, fallback: 'Unable to load messages.'),
          st,
        );
      }
    }
  }

  void _publish() {
    if (!mounted) return;
    state = AsyncValue.data([..._server, ..._pending]);
  }

  /// Appends an optimistic bubble, sends, then swaps in the server copy.
  Future<Result<Message>> send({String? text, String? imageUrl}) async {
    final me = ref.read(authStateProvider).userId ?? '';
    final local = Message(
      messageId: 'local-${DateTime.now().millisecondsSinceEpoch}-${_localSeq++}',
      senderId: me,
      text: text?.trim() ?? '',
      imageUrl: imageUrl ?? '',
      createdAt: Timestamp.now(),
      isPending: true,
    );
    _pending.add(local);
    _publish();
    return _deliver(local);
  }

  Future<Result<Message>> _deliver(Message local) async {
    try {
      final sent = await _service.sendMessage(
        chatId,
        text: local.text,
        imageUrl: local.imageUrl,
      );
      _pending.removeWhere((m) => m.messageId == local.messageId);
      _server = [..._server, sent];
      _publish();
      return Result.success(sent);
    } catch (e) {
      final idx = _pending.indexWhere((m) => m.messageId == local.messageId);
      if (idx != -1) {
        _pending[idx] = local.copyWith(isPending: false, failed: true);
      }
      _publish();
      return Result.failure(failureFrom(e, fallback: 'Message not sent.'));
    }
  }

  Future<Result<Message>> retry(String localId) async {
    final idx = _pending.indexWhere((m) => m.messageId == localId);
    if (idx == -1) {
      return Result.failure(failureFrom(Object(), fallback: 'Nothing to retry.'));
    }
    final retrying = _pending[idx].copyWith(isPending: true, failed: false);
    _pending[idx] = retrying;
    _publish();
    return _deliver(retrying);
  }

  void discard(String localId) {
    _pending.removeWhere((m) => m.messageId == localId);
    _publish();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final chatMessagesProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesController, AsyncValue<List<Message>>, String>(
  (ref, chatId) => ChatMessagesController(ref, chatId),
);
