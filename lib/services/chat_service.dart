import 'package:flutter/foundation.dart' show Uint8List;
import '../core/utils/timestamp.dart';
import '../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../features/chat/domain/message.dart';

/// Chats API. Methods throw typed exceptions; the polling streams keep the
/// last good value once something was loaded.
class ChatService {
  final ApiClient _apiClient;

  ChatService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const Duration conversationsInterval = Duration(seconds: 8);
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

  /// Sends a text, image or voice message and returns the stored message.
  Future<Message> sendMessage(
    String chatId, {
    String? text,
    String? imageUrl,
    String? audioUrl,
    int? audioMs,
    String? replyToId,
  }) async {
    final res = await _apiClient.post('/chats/$chatId/messages', {
      if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      if (audioUrl != null && audioUrl.isNotEmpty) 'audioUrl': audioUrl,
      if (audioUrl != null && audioUrl.isNotEmpty && audioMs != null && audioMs > 0) 'audioMs': audioMs,
      if (replyToId != null && replyToId.isNotEmpty) 'replyToId': replyToId,
    });
    return Message.fromApi(Map<String, dynamic>.from(res as Map));
  }

  /// Removes one of my messages for everyone; returns the tombstone.
  Future<Message> deleteMessage(String chatId, String messageId) async {
    final res = await _apiClient.delete('/chats/$chatId/messages/$messageId');
    return Message.fromApi(Map<String, dynamic>.from(res as Map));
  }

  /// The chat is on screen: clears its unread counter and settles its
  /// "new message" notifications.
  Future<void> markRead(String chatId) async {
    await _apiClient.put('/chats/$chatId/read', const {});
  }

  /// Uploads a recorded voice note and returns its public URL.
  Future<String> uploadVoice(Uint8List bytes) async {
    final res = await _apiClient.uploadFile(
      '/uploads',
      bytes: bytes,
      filename: 'voice.m4a',
      contentType: 'audio/mp4',
      fields: const {'folder': 'voice'},
    );
    return (res as Map)['url'].toString();
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
        'participantVerified': map['participantVerified'],
        'participantAdmin': map['participantAdmin'],
        'lastMessage': map['lastMessageText'],
        'lastMessageSenderId': map['lastSenderId'],
        'lastUpdatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAtMs),
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(updatedAtMs),
        'unreadCount': (map['unreadCounts'] as Map?)?[userId] ?? 0,
        'itemName': map['itemName'],
        'postOwnerId': map['postOwnerId'],
        'postStatus': map['postStatus'],
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
