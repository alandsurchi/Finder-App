import '../../core/utils/pagination.dart';
import '../../models/dto/message_dto.dart';
import 'chat_service.dart';

class MockChatService implements ChatService {
  @override
  Future<PageResult<MessageDto>> fetchMessages({
    required String chatId,
    required PageRequest request,
  }) async {
    return const PageResult(items: [], nextCursor: null, hasMore: false);
  }

  @override
  Future<MessageDto> sendMessage(MessageDto dto) async {
    final id = dto.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : dto.id;
    return MessageDto(
      id: id,
      chatId: dto.chatId,
      senderId: dto.senderId,
      text: dto.text,
      createdAtMs: dto.createdAtMs,
      isRead: dto.isRead,
    );
  }
}
