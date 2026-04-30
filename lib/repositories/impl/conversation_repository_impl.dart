import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../models/conversation_model.dart';
import '../conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const ConversationRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<Result<List<ConversationModel>>> getConversations() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to view conversations.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .get();

      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aMs = _asInt(a.data()['updatedAtMs']) ?? 0;
        final bMs = _asInt(b.data()['updatedAtMs']) ?? 0;
        return bMs.compareTo(aMs);
      });

      final conversations = docs
          .map((doc) => _toConversation(doc: doc, currentUserId: user.uid))
          .toList(growable: false);

      return Result.success(conversations);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load conversations right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  ConversationModel _toConversation({
    required QueryDocumentSnapshot<Map<String, dynamic>> doc,
    required String currentUserId,
  }) {
    final data = doc.data();

    final participants =
        (data['participants'] as List<dynamic>? ?? const <dynamic>[])
            .map((e) => e.toString())
            .toList(growable: false);

    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => currentUserId,
    );

    final namesMap = Map<String, dynamic>.from(
      data['participantNames'] as Map? ?? const {},
    );
    final avatarMap = Map<String, dynamic>.from(
      data['participantAvatars'] as Map? ?? const {},
    );
    final unreadMap = Map<String, dynamic>.from(
      data['unreadCounts'] as Map? ?? const {},
    );

    final name = namesMap[otherUserId]?.toString().trim() ?? '';
    final fallbackName =
        namesMap[currentUserId]?.toString().trim() ?? 'Conversation';
    final message = data['lastMessageText']?.toString() ?? '';

    return ConversationModel(
      chatId: doc.id,
      postId: data['postId']?.toString() ?? '',
      participants: participants,
      name: name.isEmpty ? fallbackName : name,
      message: message.isEmpty ? 'No messages yet' : message,
      lastMessageSenderId: '',
      lastUpdatedAt: Timestamp.fromMillisecondsSinceEpoch(_asInt(data['updatedAtMs']) ?? DateTime.now().millisecondsSinceEpoch),
      createdAt: Timestamp.now(),
      unreadCount: _asInt(unreadMap[currentUserId]) ?? 0,
      itemName: data['itemName']?.toString() ?? 'General',
      isOnline: data['isOnline'] as bool? ?? false,
      isVerified: data['isVerified'] as bool? ?? false,
      avatarUrl: avatarMap[otherUserId]?.toString() ?? '',
    );
  }

  String _relativeTime(int? timestampMs) {
    if (timestampMs == null || timestampMs <= 0) {
      return 'Just now';
    }

    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
