import '../core/utils/timestamp.dart';

class ConversationModel {
  final String chatId;
  final String postId;
  final List<String> participants;
  final String name; // Peer's display name
  final String peerId;
  final String message;
  final String lastMessageSenderId;
  final Timestamp lastUpdatedAt;
  final Timestamp createdAt;
  final int unreadCount;
  final String itemName;
  final bool isOnline;
  final bool isVerified;
  final String avatarUrl;

  const ConversationModel({
    required this.chatId,
    required this.postId,
    required this.participants,
    this.name = '',
    this.peerId = '',
    required this.message,
    required this.lastMessageSenderId,
    required this.lastUpdatedAt,
    required this.createdAt,
    this.unreadCount = 0,
    this.itemName = '',
    this.isOnline = false,
    this.isVerified = false,
    this.avatarUrl = '',
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id, String currentUserId) {
    final participantsList = List<String>.from(map['participants'] ?? []);
    final otherUserId = participantsList.firstWhere(
      (p) => p != currentUserId,
      orElse: () => currentUserId,
    );

    final namesMap = Map<String, dynamic>.from(map['participantNames'] ?? {});
    final avatarsMap = Map<String, dynamic>.from(map['participantAvatars'] ?? {});

    final resolvedName = namesMap[otherUserId]?.toString() ?? 'Finder User';
    final resolvedAvatar = avatarsMap[otherUserId]?.toString() ?? '';

    return ConversationModel(
      chatId: id,
      postId: map['postId']?.toString() ?? '',
      participants: participantsList,
      name: resolvedName,
      peerId: otherUserId == currentUserId ? '' : otherUserId,
      avatarUrl: resolvedAvatar,
      message: map['lastMessage']?.toString() ?? '',
      lastMessageSenderId: map['lastMessageSenderId']?.toString() ?? '',
      lastUpdatedAt: map['lastUpdatedAt'] ?? Timestamp.now(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
      unreadCount: (map['unreadCount'] as num?)?.toInt() ?? 0,
      itemName: map['itemName']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel &&
        other.chatId == chatId &&
        other.postId == postId &&
        other.name == name &&
        other.peerId == peerId &&
        other.message == message &&
        other.lastMessageSenderId == lastMessageSenderId &&
        other.lastUpdatedAt.millisecondsSinceEpoch ==
            lastUpdatedAt.millisecondsSinceEpoch &&
        other.unreadCount == unreadCount &&
        other.itemName == itemName &&
        other.isVerified == isVerified &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode => Object.hash(
        chatId,
        postId,
        name,
        peerId,
        message,
        lastMessageSenderId,
        lastUpdatedAt.millisecondsSinceEpoch,
        unreadCount,
        itemName,
        isVerified,
        avatarUrl,
      );

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'participants': participants,
      'lastMessage': message,
      'lastMessageSenderId': lastMessageSenderId,
      'lastUpdatedAt': lastUpdatedAt,
      'createdAt': createdAt,
      'unreadCount': unreadCount,
      'itemName': itemName,
    };
  }
}
