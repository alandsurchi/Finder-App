import '../../../core/utils/timestamp.dart';

class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final String imageUrl;
  final Timestamp createdAt;
  final bool isRead;

  /// True while the message is on its way to the server (optimistic bubble).
  final bool isPending;

  /// True when sending failed; the bubble offers a retry.
  final bool failed;

  const Message({
    required this.messageId,
    required this.senderId,
    this.receiverId = '',
    required this.text,
    this.imageUrl = '',
    required this.createdAt,
    this.isRead = false,
    this.isPending = false,
    this.failed = false,
  });

  bool get hasImage => imageUrl.trim().isNotEmpty;
  bool get isLocal => messageId.startsWith('local-');

  factory Message.fromApi(Map<String, dynamic> map) {
    final createdAtMs = (map['createdAtMs'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    return Message(
      messageId: map['id']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      createdAt: Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
      isRead: map['isRead'] == true,
    );
  }

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      messageId: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  Message copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? text,
    String? imageUrl,
    Timestamp? createdAt,
    bool? isRead,
    bool? isPending,
    bool? failed,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isPending: isPending ?? this.isPending,
      failed: failed ?? this.failed,
    );
  }
}
