import '../core/utils/result.dart';
import '../models/conversation_model.dart';

abstract class ConversationRepository {
  Future<Result<List<ConversationModel>>> getConversations();
}
