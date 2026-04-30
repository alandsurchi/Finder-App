class MessageDto {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final int createdAtMs;
  final bool isRead;

  const MessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAtMs,
    required this.isRead,
  });

  factory MessageDto.fromMap(Map<String, dynamic> map) {
    return MessageDto(
      id: map['id']?.toString() ?? '',
      chatId: map['chatId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      createdAtMs: map['createdAtMs'] as int? ?? 0,
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'createdAtMs': createdAtMs,
      'isRead': isRead,
    };
  }
}
