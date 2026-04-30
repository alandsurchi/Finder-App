import '../core/utils/pagination.dart';
import '../core/utils/result.dart';
import '../features/chat/domain/message.dart';
import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;

  const GetMessages(this.repository);

  Future<Result<PageResult<Message>>> call({
    required String chatId,
    PageRequest? pageRequest,
  }) {
    return repository.getMessages(chatId: chatId, pageRequest: pageRequest);
  }
}
