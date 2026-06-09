import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/pagination.dart';
import '../../core/utils/result.dart';
import '../../features/chat/domain/message.dart';
import '../../features/chat/mappers/message_mapper.dart';
import '../../services/chat/chat_service.dart';
import '../chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService service;
  final MessageMapper mapper;

  const ChatRepositoryImpl({required this.service, required this.mapper});

  @override
  Future<Result<PageResult<Message>>> getMessages({
    required String chatId,
    PageRequest? pageRequest,
  }) async {
    try {
      final request = pageRequest ?? const PageRequest();
      final page = await service.fetchMessages(chatId: chatId, request: request);
      final mapped = page.items.map(mapper.fromDto).toList();
      return Result.success(
        PageResult(items: mapped, nextCursor: page.nextCursor, hasMore: page.hasMore),
      );
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: 'Unable to load messages'));
    }
  }

  @override
  Future<Result<Message>> sendMessage(Message message) async {
    try {
      final dto = mapper.toDto(message);
      final created = await service.sendMessage(dto);
      return Result.success(mapper.fromDto(created));
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: 'Unable to send message'));
    }
  }
}
