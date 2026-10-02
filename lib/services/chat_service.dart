import 'package:flutter/foundation.dart' show Uint8List;
import '../core/utils/timestamp.dart';
import '../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../features/chat/domain/message.dart';

/// One page of a chat, newest first as the server sends it, plus the
/// receipt watermarks the bubbles need.
class MessagesPage {
  final List<Message> items;
  final String? nextCursor;
  final bool hasMore;
  final int? peerReadAtMs;
  final int? peerDeliveredAtMs;
  /// The viewer's read time before this fetch: messages after it are "new".
  final int? myReadAtMsBefore;

  const MessagesPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.peerReadAtMs,
    this.peerDeliveredAtMs,
    this.myReadAtMsBefore,
  });
}

/// Chats API. Methods throw typed exceptions; the polling streams keep the
/// last good value once something was loaded.
class ChatService {
  final ApiClient _apiClient;

  ChatService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const Duration conversationsInterval = Duration(seconds: 8);
  static const Duration messagesInterval = Duration(seconds: 3);
  /// Polling slows down to this while the realtime socket is connected.
  static const Duration messagesIntervalRealtime = Duration(seconds: 20);

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

  /// Sends a text, image or voice message (or forwards one) and returns
  /// the stored message.
  Future<Message> sendMessage(
    String chatId, {
    String? text,
    String? imageUrl,
    String? audioUrl,
    int? audioMs,
    List<int>? waveform,
    String? replyToId,
    String? forwardOf,
  }) async {
    final hasAudio = audioUrl != null && audioUrl.isNotEmpty;
    final res = await _apiClient.post('/chats/$chatId/messages', {
      if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      if (hasAudio) 'audioUrl': audioUrl,
      if (hasAudio && audioMs != null && audioMs > 0) 'audioMs': audioMs,
      if (hasAudio && waveform != null && waveform.isNotEmpty) 'waveform': waveform.take(64).toList(),
      if (replyToId != null && replyToId.isNotEmpty) 'replyToId': replyToId,
      if (forwardOf != null && forwardOf.isNotEmpty) 'forwardOf': forwardOf,
    });
    return Message.fromApi(Map<String, dynamic>.from(res as Map));
  }

  /// Removes one of my messages for everyone (returns the tombstone), or
  /// with [forMe] hides any message on this account only.
  Future<Message?> deleteMessage(String chatId, String messageId, {bool forMe = false}) async {
    final res = await _apiClient.delete('/chats/$chatId/messages/$messageId${forMe ? '?scope=me' : ''}');
    if (forMe) return null;
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

  Future<List<ConversationModel>> fetchConversations(String userId) async {
    final res = await _apiClient.get('/chats');
    final list = res as List<dynamic>? ?? [];
    return list.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final id = map['id']?.toString() ?? '';
      final updatedAtMs = (map['updatedAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch;
      final presence = map['peerPresence'];
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
        'lastMessageRead': map['lastMessageRead'] == true,
        'lastMessageDelivered': map['lastMessageDelivered'] == true,
        'peerOnline': presence is Map && presence['online'] == true,
        'peerLastSeenMs': presence is Map ? (presence['lastSeenMs'] as num?)?.toInt() : null,
      };
      return ConversationModel.fromMap(resolvedMap, id, userId);
    }).toList();
  }

  /// One page, oldest first. Without [cursor] it is the newest page and the
  /// server marks the chat read.
  Future<MessagesPage> fetchMessages(String chatId, {int limit = 50, String? cursor}) async {
    final query = cursor == null ? 'limit=$limit' : 'limit=$limit&cursor=$cursor';
    final res = await _apiClient.get('/chats/$chatId/messages?$query');
    final map = res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{'items': res};
    final items = (map['items'] as List<dynamic>? ?? [])
        .map((e) => Message.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList()
        .reversed
        .toList();
    return MessagesPage(
      items: items,
      nextCursor: map['nextCursor']?.toString(),
      hasMore: map['hasMore'] == true,
      peerReadAtMs: (map['peerReadAtMs'] as num?)?.toInt(),
      peerDeliveredAtMs: (map['peerDeliveredAtMs'] as num?)?.toInt(),
      myReadAtMsBefore: (map['myReadAtMsBefore'] as num?)?.toInt(),
    );
  }
}
