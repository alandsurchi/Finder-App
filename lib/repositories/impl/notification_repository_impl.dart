import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../models/notification_model.dart';
import '../notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final List<NotificationModel> _items = [];

  NotificationRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<Result<List<NotificationModel>>> getNotifications() async {
    final user = _auth.currentUser;
    if (user == null) {
      _items.clear();
      return Result.success(const []);
    }

    try {
      final snapshot = await _userNotifications(
        user.uid,
      ).orderBy('createdAtMs', descending: true).get();

      _items
        ..clear()
        ..addAll(snapshot.docs.map(_toNotification));

      return Result.success(List.unmodifiable(_items));
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load notifications right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  @override
  Future<Result<List<NotificationModel>>> markAsRead(int index) async {
    if (index < 0 || index >= _items.length) {
      return Result.success(List.unmodifiable(_items));
    }

    final user = _auth.currentUser;
    if (user == null) {
      return Result.failure(
        const Failure(
          message: 'Please log in to manage notifications.',
          type: FailureType.auth,
        ),
      );
    }

    final current = _items[index];
    try {
      if (current.id.isNotEmpty) {
        await _userNotifications(user.uid).doc(current.id).set({
          'isUnread': false,
          'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));
      }

      _items[index] = current.copyWith(isUnread: false);
      return Result.success(List.unmodifiable(_items));
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update notification right now.',
          type: FailureType.network,
          code: e.code,
        ),
      );
    }
  }

  CollectionReference<Map<String, dynamic>> _userNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  NotificationModel _toNotification(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return NotificationModel(
      id: doc.id,
      title: data['title']?.toString() ?? 'Notification',
      message: data['message']?.toString() ?? '',
      timeAgo: _relativeTime(_asInt(data['createdAtMs'])),
      isUnread: data['isUnread'] as bool? ?? true,
      type: _notificationType(data['type']?.toString()),
    );
  }

  NotificationType _notificationType(String? raw) {
    switch (raw) {
      case 'itemMatch':
        return NotificationType.itemMatch;
      case 'newMessage':
        return NotificationType.newMessage;
      case 'postApproved':
        return NotificationType.postApproved;
      default:
        return NotificationType.system;
    }
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
