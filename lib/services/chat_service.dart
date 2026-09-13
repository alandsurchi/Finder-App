import '../core/utils/timestamp.dart';
import '../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../features/chat/domain/message.dart';

/// Chats API. Methods throw typed exceptions; the polling streams keep the
/// last good value once something was loaded.
class ChatService {
  final ApiClient _apiClient;

  ChatService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const Duration conversationsInterval = Duration(seconds: 4);
  static const Duration messagesInterval = Duration(seconds: 3);

  /// Opens (or returns) the conversation with [peerId]. With a [postId] the
  /// chat is tied to that item; without one it is a direct chat.
  Future<String> createOrGetChat({
    required String peerId,
    String? postId,
    String? itemName,
  }) async {
    final res = await _apiClient.post('/chats/initiate', {
      'peerId': peerId,
      if (postId != null && postId.isNotEmpty) 'postId': postId,
      if (itemName != null && itemName.isNotEmpty) 'itemName': itemName,
    });
    return (res as Map)['chatId'].toString();
  }

  /// Sends a text and/or image message and returns the stored message.
  Future<Message> sendMessage(
    String chatId, {
    String? text,
    String? imageUrl,
  }) async {
    final res = await _apiClient.post('/chats/$chatId/messages', {
      if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    });
    return Message.fromApi(Map<String, dynamic>.from(res as Map));
  }

  Stream<List<ConversationModel>> getConversationsStream(String userId) async* {
    List<ConversationModel>? last;
    while (true) {
      try {
        last = await fetchConversations(userId);
        yield last;
      } catch (e, st) {
        if (last == null) yield* Stream<List<ConversationModel>>.error(e, st);
      }
      await Future<void>.delayed(conversationsInterval);
    }
  }

  Future<List<ConversationModel>> fetchConversations(String userId) async {
    final res = await _apiClient.get('/chats');
    final list = res as List<dynamic>? ?? [];
    return list.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final id = map['id']?.toString() ?? '';
      final updatedAtMs = (map['updatedAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch;
      final resolvedMap = {
        'postId': map['postId'],
        'participants': map['participants'],
        'participantNames': map['participantNames'],
        'participantAvatars': map['participantAvatars'],
        'lastMessage': map['lastMessageText'],
        'lastMessageSenderId': map['lastSenderId'],
        'lastUpdatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAtMs),
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(updatedAtMs),
        'unreadCount': (map['unreadCounts'] as Map?)?[userId] ?? 0,
        'itemName': map['itemName'],
      };
      return ConversationModel.fromMap(resolvedMap, id, userId);
    }).toList();
  }

  /// Oldest first.
  Future<List<Message>> fetchMessages(String chatId, {int limit = 100}) async {
    final res = await _apiClient.get('/chats/$chatId/messages?limit=$limit');
    final items = (res is Map ? res['items'] : res) as List<dynamic>? ?? [];
    final messages = items
        .map((e) => Message.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
    return messages.reversed.toList();
  }
}
