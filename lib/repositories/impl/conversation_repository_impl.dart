import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../models/conversation_model.dart';
import '../conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ApiClient _apiClient;

  const ConversationRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Result<List<ConversationModel>>> getConversations() async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view conversations.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final res = await _apiClient.get('/chats');
      final list = res as List<dynamic>;
      
      // We need to resolve current userId to map unread count.
      // We can fetch token info or assume client filters/maps it.
      // The JWT token is verified in backend, and backend returns unread counts mapped by userId.
      // Wait, let's extract userId from client token if needed, or simply map it from response payload since we don't have user.uid.
      // Wait, the API client exposes `token` or we can find uid. But wait! The `/chats` endpoint returns `unreadCounts` mapped by userId.
      // If we don't have currentUserId locally, we can extract it or pass it. But wait, `apiClient` doesn't expose `userId`, it only stores `token`.
      // Can we decode JWT token to extract `userId` in Flutter?
      // Yes! A JWT token consists of three parts separated by `.`. The second part is a Base64URL encoded JSON containing the payload (including `userId`).
      // Let's write a helper to decode the JWT payload to get `userId`:
      String? getUserIdFromToken(String? token) {
        if (token == null || token.isEmpty) return null;
        try {
          final parts = token.split('.');
          if (parts.length != 3) return null;
          final payload = parts[1];
          // Base64URL decode
          var normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64.decode(normalized));
          final map = jsonDecode(decoded);
          return map['userId']?.toString();
        } catch (_) {
          return null;
        }
      }
      
      // But wait! Is there a simpler way?
      // Yes, the backend `/chats` returns:
      // `unreadCounts: { [userId]: chat.unread_count }`
      // Wait, the backend already knows req.userId, so it can just return `unreadCount: chat.unread_count` directly in the JSON response!
      // Let's check `backend/routes/chats.js`:
      // ```javascript
      // unreadCounts: {
      //   [userId]: chat.unread_count
      // }
      // ```
      // Yes, it returns exactly that.
      // To get the unread count, the client can just read the first value in `unreadCounts` map or read it by decoding the token!
      // Let's write a simple helper inside `ConversationRepositoryImpl` to decode token and find `userId`.
      
      String currentUserId = '';
      final token = _apiClient.token;
      if (token != null && token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            // Normalize base64
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64.decode(normalized));
            final map = jsonDecode(decoded);
            currentUserId = map['userId']?.toString() ?? '';
          }
        } catch (_) {}
      }

      final conversations = list.map((item) {
        final map = Map<String, dynamic>.from(item);
        final id = map['id']?.toString() ?? '';
        
        final resolvedMap = {
          'postId': map['postId'],
          'participants': map['participants'],
          'participantNames': map['participantNames'],
          'participantAvatars': map['participantAvatars'],
          'lastMessage': map['lastMessageText'],
          'lastMessageSenderId': map['lastSenderId'],
          'lastUpdatedAt': Timestamp.fromMillisecondsSinceEpoch(map['updatedAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch),
          'createdAt': Timestamp.now(),
          'unreadCount': (map['unreadCounts'] as Map?)?[currentUserId] ?? 0,
          'itemName': map['itemName'],
        };
        
        return ConversationModel.fromMap(resolvedMap, id, currentUserId);
      }).toList();

      return Result.success(conversations);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load conversations: $e',
          type: FailureType.network,
        ),
      );
    }
  }
}

// Simple base64 decoder helper
class base64Url {
  static String normalize(String base64) {
    var s = base64.replaceAll('-', '+').replaceAll('_', '/');
    switch (s.length % 4) {
      case 0:
        break;
      case 2:
        s += '==';
        break;
      case 3:
        s += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }
    return s;
  }
}
