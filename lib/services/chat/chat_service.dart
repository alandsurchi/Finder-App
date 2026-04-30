import '../../core/utils/pagination.dart';
import '../../models/dto/message_dto.dart';

abstract class ChatService {
  Future<PageResult<MessageDto>> fetchMessages({
    required String chatId,
    required PageRequest request,
  });

  Future<MessageDto> sendMessage(MessageDto dto);
}
