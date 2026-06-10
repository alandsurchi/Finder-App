import '../core/utils/timestamp.dart';
import '../../core/network/api_client.dart';
import '../models/conversation_model.dart';
import '../features/chat/domain/message.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService({required ApiClient apiClient}) : _apiClient = apiClient;

  String generateChatId(String userA, String userB, String postId) {
    if (userA.compareTo(userB) < 0) {
      return '${postId}_${userA}_$userB';
    } else {
      return '${postId}_${userB}_$userA';
    }
  }

  Future<String> createOrGetChat(String currentUserId, String peerId, String postId, String itemName) async {
    try {
      final res = await _apiClient.post('/chats/initiate', {
        'peerId': peerId,
        'postId': postId,
        'itemName': itemName,
      });
      return res['chatId'] as String;
    } catch (e) {
      throw Exception('Failed to initiate chat: $e');
    }
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    try {
      await _apiClient.post('/chats/$chatId/messages', {
        'text': text,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ConversationModel>> getConversationsStream(String userId) async* {
    yield await _fetchConversations(userId);
    yield* Stream.periodic(const Duration(seconds: 4)).asyncMap((_) => _fetchConversations(userId));
  }

  Future<List<ConversationModel>> _fetchConversations(String userId) async {
    try {
      final res = await _apiClient.get('/chats');
      final list = res as List<dynamic>;
      return list.map((item) {
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString() ?? '';
        
        // Map backend properties back to format expected by fromMap
        final resolvedMap = {
          'postId': map['postId'],
          'participants': map['participants'],
          'participantNames': map['participantNames'],
          'participantAvatars': map['participantAvatars'],
          'lastMessage': map['lastMessageText'],
          'lastMessageSenderId': map['lastSenderId'],
          'lastUpdatedAt': Timestamp.fromMillisecondsSinceEpoch(map['updatedAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch),
          'createdAt': Timestamp.now(),
          'unreadCount': (map['unreadCounts'] as Map?)?[userId] ?? 0,
          'itemName': map['itemName'],
        };
        
        return ConversationModel.fromMap(resolvedMap, id, userId);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<Message>> getMessagesStream(String chatId) async* {
    yield await _fetchMessages(chatId);
    yield* Stream.periodic(const Duration(seconds: 3)).asyncMap((_) => _fetchMessages(chatId));
  }

  Future<List<Message>> _fetchMessages(String chatId) async {
    try {
      final res = await _apiClient.get('/chats/$chatId/messages?limit=50');
      final itemsList = res['items'] as List<dynamic>;
      
      // Reverse list to display oldest first (as messagesStream expects ascending order)
      final reversedList = List.from(itemsList.reversed);
      
      return reversedList.map((item) {
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString() ?? '';
        final createdAtMs = map['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch;
        
        final resolvedMap = {
          'senderId': map['senderId'],
          'receiverId': '', // Optional
          'text': map['text'],
          'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
          'isRead': map['isRead'] as bool? ?? false,
        };
        
        return Message.fromMap(resolvedMap, id);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
