import '../core/utils/result.dart';
import '../features/chat/domain/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  const SendMessage(this.repository);

  Future<Result<Message>> call(Message message) {
    return repository.sendMessage(message);
  }
}
