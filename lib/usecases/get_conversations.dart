import '../core/utils/result.dart';
import '../models/conversation_model.dart';
import '../repositories/conversation_repository.dart';

class GetConversations {
  final ConversationRepository repository;

  const GetConversations(this.repository);

  Future<Result<List<ConversationModel>>> call() {
    return repository.getConversations();
  }
}
