import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finder/models/conversation_model.dart';
import 'package:finder/features/chat/domain/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateChatId(String userA, String userB, String postId) {
    if (userA.compareTo(userB) < 0) {
      return '${postId}_${userA}_$userB';
    } else {
      return '${postId}_${userB}_$userA';
    }
  }

  Future<String> createOrGetChat(String currentUserId, String peerId, String postId, String itemName) async {
    final chatId = generateChatId(currentUserId, peerId, postId);
    
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!chatDoc.exists) {
      // Fetch user profiles to store names for UI display
      final userADoc = await _firestore.collection('users').doc(currentUserId).get();
      final userBDoc = await _firestore.collection('users').doc(peerId).get();
      
      final userAName = userADoc.data()?['fullName'] ?? 'User';
      final userBName = userBDoc.data()?['fullName'] ?? 'User';

      await _firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'postId': postId,
        'itemName': itemName,
        'participants': [currentUserId, peerId],
        'participantNames': {
          currentUserId: userAName,
          peerId: userBName,
        },
        'participantAvatars': {},
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'unreadCount': 0,
      });
    }
    
    return chatId;
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');
    
    final newMessageRef = messagesRef.doc();
    final messageId = newMessageRef.id;
    
    final batch = _firestore.batch();
    
    batch.set(newMessageRef, {
      'messageId': messageId,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    
    batch.update(chatRef, {
      'lastMessage': text,
      'lastMessageSenderId': senderId,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
  }

  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConversationModel.fromMap(doc.data(), doc.id, userId);
      }).toList();
    });
  }

  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
