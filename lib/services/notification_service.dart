import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Writes notification documents to Firestore under users/{uid}/notifications.
/// The NotificationsScreen already reads from this collection.
class NotificationService {
  static final _db = FirebaseFirestore.instance;

  // ── Generic writer ──────────────────────────────────────────────────────────
  static Future<void> _write({
    required String toUserId,
    required String title,
    required String message,
    required String type, // itemMatch | newMessage | postApproved | system
  }) async {
    if (toUserId.isEmpty) return;
    try {
      await _db
          .collection('users')
          .doc(toUserId)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type,
        'isUnread': true,
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {
      // Fail silently — notifications are non-critical
    }
  }

  // ── Public helpers ──────────────────────────────────────────────────────────

  /// Called when a new chat message is sent.
  /// [toUserId]   — the recipient's uid
  /// [senderName] — display name of the sender
  /// [postTitle]  — title of the item being discussed
  static Future<void> notifyNewMessage({
    required String toUserId,
    required String senderName,
    required String postTitle,
  }) =>
      _write(
        toUserId: toUserId,
        title: '💬 New message from $senderName',
        message: 'Regarding: "$postTitle"',
        type: 'newMessage',
      );

  /// Called when someone saves (bookmarks) your post.
  static Future<void> notifyItemSaved({
    required String toUserId,
    required String saverName,
    required String postTitle,
  }) =>
      _write(
        toUserId: toUserId,
        title: '🔖 Someone saved your post',
        message: '$saverName saved "$postTitle"',
        type: 'itemMatch',
      );

  /// Called when the owner marks their own post as resolved.
  static Future<void> notifyResolved({
    required String postTitle,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Future.value();
    return _write(
      toUserId: uid,
      title: '✅ Post marked as resolved',
      message: '"$postTitle" has been resolved. Great job!',
      type: 'postApproved',
    );
  }

  /// General system notification to the current user.
  static Future<void> notifySystem({
    required String title,
    required String message,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Future.value();
    return _write(
      toUserId: uid,
      title: title,
      message: message,
      type: 'system',
    );
  }
}
