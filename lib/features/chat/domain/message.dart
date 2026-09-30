import '../../../core/utils/timestamp.dart';

/// The quoted message inside a reply.
class ReplyPreview {
  final String id;
  final String senderId;
  final String text;
  final String imageUrl;
  final String audioUrl;
  final bool deleted;

  const ReplyPreview({
    required this.id,
    this.senderId = '',
    this.text = '',
    this.imageUrl = '',
    this.audioUrl = '',
    this.deleted = false,
  });

  bool get hasImage => imageUrl.isNotEmpty;
  bool get hasAudio => audioUrl.isNotEmpty;

  /// One-line description for the quote block and the reply bar.
  String get summary {
    if (deleted) return 'This message was deleted';
    if (text.isNotEmpty) return text;
    if (hasAudio) return 'Voice message';
    if (hasImage) return 'Photo';
    return '';
  }

  factory ReplyPreview.fromApi(Map<String, dynamic> map) => ReplyPreview(
        id: map['id']?.toString() ?? '',
        senderId: map['senderId']?.toString() ?? '',
        text: map['text']?.toString() ?? '',
        imageUrl: map['imageUrl']?.toString() ?? '',
        audioUrl: map['audioUrl']?.toString() ?? '',
        deleted: map['deleted'] == true,
      );

  factory ReplyPreview.ofMessage(Message m) => ReplyPreview(
        id: m.messageId,
        senderId: m.senderId,
        text: m.text,
        imageUrl: m.imageUrl,
        audioUrl: m.audioUrl,
        deleted: m.deleted,
      );
}

class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final String imageUrl;
  final String audioUrl;
  final int? audioMs;
  final ReplyPreview? replyTo;
  final bool deleted;
  final Timestamp createdAt;
  final bool isRead;

  /// True while the message is on its way to the server (optimistic bubble).
  final bool isPending;

  /// True when sending failed; the bubble offers a retry.
  final bool failed;

  /// A voice note recorded on this phone, before or while it uploads.
  final String localAudioPath;

  const Message({
    required this.messageId,
    required this.senderId,
    this.receiverId = '',
    required this.text,
    this.imageUrl = '',
    this.audioUrl = '',
    this.audioMs,
    this.replyTo,
    this.deleted = false,
    required this.createdAt,
    this.isRead = false,
    this.isPending = false,
    this.failed = false,
    this.localAudioPath = '',
  });

  bool get hasImage => imageUrl.trim().isNotEmpty;
  bool get hasAudio => audioUrl.trim().isNotEmpty || localAudioPath.isNotEmpty;
  bool get isLocal => messageId.startsWith('local-');

  /// Where the player reads the voice note from: the local file while it is
  /// being sent, the server copy afterwards.
  String get audioSource => localAudioPath.isNotEmpty ? localAudioPath : audioUrl;

  factory Message.fromApi(Map<String, dynamic> map) {
    final createdAtMs = (map['createdAtMs'] as num?)?.toInt() ??
        DateTime.now().millisecondsSinceEpoch;
    final reply = map['replyTo'];
    return Message(
      messageId: map['id']?.toString() ?? '',
      senderId: map['senderId']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      audioUrl: map['audioUrl']?.toString() ?? '',
      audioMs: (map['audioMs'] as num?)?.toInt(),
      replyTo: reply is Map ? ReplyPreview.fromApi(Map<String, dynamic>.from(reply)) : null,
      deleted: map['deleted'] == true,
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
      'audioUrl': audioUrl,
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
    String? audioUrl,
    int? audioMs,
    ReplyPreview? replyTo,
    bool? deleted,
    Timestamp? createdAt,
    bool? isRead,
    bool? isPending,
    bool? failed,
    String? localAudioPath,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      audioMs: audioMs ?? this.audioMs,
      replyTo: replyTo ?? this.replyTo,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isPending: isPending ?? this.isPending,
      failed: failed ?? this.failed,
      localAudioPath: localAudioPath ?? this.localAudioPath,
    );
  }
}
