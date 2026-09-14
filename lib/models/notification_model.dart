enum NotificationType { itemMatch, newMessage, postApproved, update, system }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final NotificationType type;

  /// Deep-link payload from the server (chatId, postId, peer*, ...).
  final Map<String, dynamic> data;

  const NotificationModel({
    this.id = '',
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
    required this.type,
    this.data = const {},
  });

  bool get hasTarget => data.isNotEmpty;

  /// Backend `type` values: match, message, update, system.
  static NotificationType typeFromApi(String? raw) {
    switch (raw) {
      case 'match':
      case 'itemMatch':
        return NotificationType.itemMatch;
      case 'message':
      case 'newMessage':
        return NotificationType.newMessage;
      case 'update':
        return NotificationType.update;
      case 'postApproved':
        return NotificationType.postApproved;
      default:
        return NotificationType.system;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    bool? isUnread,
    NotificationType? type,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      type: type ?? this.type,
      data: data ?? this.data,
    );
  }
}
