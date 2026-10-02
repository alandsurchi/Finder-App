import '../../../core/utils/timestamp.dart';
import '../../../l10n/l10n.dart';

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
    if (deleted) return L10n.current.msgDeleted;
    if (text.isNotEmpty) return text;
    if (hasAudio) return L10n.current.msgVoiceMessage;
    if (hasImage) return L10n.current.msgPhoto;
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
  /// Reached the peer's phone (two grey ticks); [isRead] = seen (blue).
  final bool isDelivered;
  /// Loudness buckets 0-100 of a voice note, for the waveform.
  final List<int>? waveform;
  /// Copied from another chat ("Forwarded" label).
  final bool forwarded;
  /// Id of the message being forwarded while the copy is pending.
  final String? forwardOf;

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
    this.isDelivered = false,
    this.waveform,
    this.forwarded = false,
    this.forwardOf,
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
      isDelivered: map['isDelivered'] == true || map['isRead'] == true,
      waveform: map['waveform'] is List
          ? (map['waveform'] as List).map((e) => (e as num).toInt()).toList()
          : null,
      forwarded: map['forwarded'] == true,
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
    bool? isDelivered,
    List<int>? waveform,
    bool? forwarded,
    String? forwardOf,
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
      isDelivered: isDelivered ?? this.isDelivered,
      waveform: waveform ?? this.waveform,
      forwarded: forwarded ?? this.forwarded,
      forwardOf: forwardOf ?? this.forwardOf,
      isPending: isPending ?? this.isPending,
      failed: failed ?? this.failed,
      localAudioPath: localAudioPath ?? this.localAudioPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          other.messageId == messageId &&
          other.text == text &&
          other.imageUrl == imageUrl &&
          other.audioUrl == audioUrl &&
          other.deleted == deleted &&
          other.isRead == isRead &&
          other.isDelivered == isDelivered &&
          other.isPending == isPending &&
          other.failed == failed;

  @override
  int get hashCode => Object.hash(messageId, text, imageUrl, audioUrl, deleted, isRead, isDelivered, isPending, failed);
}
