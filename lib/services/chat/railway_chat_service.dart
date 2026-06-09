import '../../core/network/api_client.dart';
import '../../core/utils/pagination.dart';
import '../../models/dto/message_dto.dart';
import 'chat_service.dart';

class RailwayChatService implements ChatService {
  final ApiClient _apiClient;

  const RailwayChatService({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PageResult<MessageDto>> fetchMessages({
    required String chatId,
    required PageRequest request,
  }) async {
    try {
      final queryParams = 'limit=${request.limit}${request.cursor != null ? '&cursor=${request.cursor}' : ''}';
      final res = await _apiClient.get('/chats/$chatId/messages?$queryParams');

      final itemsList = res['items'] as List<dynamic>;
      final items = itemsList
          .map((item) => MessageDto.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      return PageResult(
        items: items,
        nextCursor: res['nextCursor']?.toString(),
        hasMore: res['hasMore'] as bool? ?? false,
      );
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  @override
  Future<MessageDto> sendMessage(MessageDto dto) async {
    try {
      final res = await _apiClient.post('/chats/${dto.chatId}/messages', {
        'text': dto.text,
      });
      return MessageDto.fromMap(Map<String, dynamic>.from(res));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
