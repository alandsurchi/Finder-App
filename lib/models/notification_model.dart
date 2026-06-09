enum NotificationType { itemMatch, newMessage, postApproved, system }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final NotificationType type;

  const NotificationModel({
    this.id = '',
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
    required this.type,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    bool? isUnread,
    NotificationType? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
      type: type ?? this.type,
    );
  }
}
