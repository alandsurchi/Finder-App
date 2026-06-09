import '../core/utils/pagination.dart';
import '../core/utils/result.dart';
import '../features/chat/domain/message.dart';

abstract class ChatRepository {
  Future<Result<Message>> sendMessage(Message message);

  Future<Result<PageResult<Message>>> getMessages({
    required String chatId,
    PageRequest? pageRequest,
  });
}
