import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/pagination.dart';
import '../../models/dto/message_dto.dart';
import '../../services/notification_service.dart';
import 'chat_service.dart';

class FirebaseChatService implements ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const FirebaseChatService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  @override
  Future<PageResult<MessageDto>> fetchMessages({
    required String chatId,
    required PageRequest request,
  }) async {
    if (chatId.trim().isEmpty) {
      throw const ValidationException('Chat id is required.');
    }

    try {
      final limit = _normalizedLimit(request.limit);
      final messagesCollection = _chats.doc(chatId).collection('messages');

      Query<Map<String, dynamic>> query = messagesCollection;
      final cursorMs = request.cursor == null
          ? null
          : int.tryParse(request.cursor!.trim());
      if (cursorMs != null) {
        query = query.where('createdAtMs', isLessThan: cursorMs);
      }

      final snapshot = await query
          .orderBy('createdAtMs', descending: true)
          .limit(limit)
          .get();

      final docs = snapshot.docs;
      final items = docs
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            data['chatId'] = chatId;
            return MessageDto.fromMap(data);
          })
          .toList(growable: false);

      final hasMore = docs.length == limit;
      final nextCursor = hasMore && docs.isNotEmpty
          ? _asInt(docs.last.data()['createdAtMs'])?.toString()
          : null;

      await _resetCurrentUserUnreadCount(chatId);

      return PageResult(items: items, nextCursor: nextCursor, hasMore: hasMore);
    } on FirebaseException catch (e) {
      throw NetworkException(
        'Unable to load messages right now.',
        code: e.code,
      );
    }
  }

  @override
  Future<MessageDto> sendMessage(MessageDto dto) async {
    if (dto.chatId.trim().isEmpty) {
      throw const ValidationException('Chat id is required.');
    }
    if (dto.senderId.trim().isEmpty) {
      throw const ValidationException('Sender id is required.');
    }
    if (dto.text.trim().isEmpty) {
      throw const ValidationException('Message cannot be empty.');
    }

    try {
      final createdAtMs = dto.createdAtMs == 0
          ? DateTime.now().millisecondsSinceEpoch
          : dto.createdAtMs;

      final chatRef = _chats.doc(dto.chatId);
      final messageRef = dto.id.isEmpty
          ? chatRef.collection('messages').doc()
          : chatRef.collection('messages').doc(dto.id);

      final payload = {
        'id': messageRef.id,
        'chatId': dto.chatId,
        'senderId': dto.senderId,
        'text': dto.text.trim(),
        'createdAtMs': createdAtMs,
        'isRead': dto.isRead,
      };

      await messageRef.set(payload);

      await _upsertChatMetadata(
        chatRef: chatRef,
        senderId: dto.senderId,
        messageText: dto.text.trim(),
        createdAtMs: createdAtMs,
      );

      // Notify the recipient
      try {
        final chatSnap = await chatRef.get();
        final data = chatSnap.data() ?? {};
        final participants = (data['participants'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final recipientId = participants.firstWhere(
          (p) => p != dto.senderId,
          orElse: () => '',
        );
        final senderName =
            _auth.currentUser?.displayName ??
            _auth.currentUser?.email ??
            'Someone';
        final postTitle =
            (data['postTitle'] as String?)?.isNotEmpty == true
                ? data['postTitle'] as String
                : 'your post';
        if (recipientId.isNotEmpty) {
          await NotificationService.notifyNewMessage(
            toUserId: recipientId,
            senderName: senderName,
            postTitle: postTitle,
          );
        }
      } catch (_) {} // notification failure must never break chat

      return MessageDto.fromMap(payload);
    } on FirebaseException catch (e) {
      throw NetworkException('Unable to send message right now.', code: e.code);
    }
  }

  Future<void> _upsertChatMetadata({
    required DocumentReference<Map<String, dynamic>> chatRef,
    required String senderId,
    required String messageText,
    required int createdAtMs,
  }) async {
    final chatSnapshot = await chatRef.get();
    final existing = chatSnapshot.data() ?? const <String, dynamic>{};

    final participants =
        (existing['participants'] as List<dynamic>? ?? <dynamic>[senderId])
            .map((e) => e.toString())
            .toList();
    if (!participants.contains(senderId)) {
      participants.add(senderId);
    }

    final unreadCounts = Map<String, dynamic>.from(
      existing['unreadCounts'] as Map? ?? const {},
    );
    for (final participantId in participants) {
      if (participantId == senderId) {
        unreadCounts[participantId] = 0;
      } else {
        final current = _asInt(unreadCounts[participantId]) ?? 0;
        unreadCounts[participantId] = current + 1;
      }
    }

    final participantNames = Map<String, dynamic>.from(
      existing['participantNames'] as Map? ?? const {},
    );
    participantNames[senderId] =
        participantNames[senderId] ??
        _auth.currentUser?.displayName ??
        _auth.currentUser?.email ??
        'User';

    await chatRef.set({
      'id': chatRef.id,
      'participants': participants,
      'participantNames': participantNames,
      'lastMessageText': messageText,
      'lastSenderId': senderId,
      'updatedAtMs': createdAtMs,
      'unreadCounts': unreadCounts,
    }, SetOptions(merge: true));
  }

  Future<void> _resetCurrentUserUnreadCount(String chatId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    await _chats.doc(chatId).set({
      'unreadCounts.${currentUser.uid}': 0,
    }, SetOptions(merge: true));
  }

  int _normalizedLimit(int limit) {
    if (limit <= 0) return ApiConstants.defaultPageSize;
    if (limit > ApiConstants.maxPageSize) return ApiConstants.maxPageSize;
    return limit;
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
