import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/dto/message_dto.dart';
import '../domain/message.dart';

class MessageMapper {
  const MessageMapper();

  Message fromDto(MessageDto dto) {
    return Message(
      messageId: dto.id,
      senderId: dto.senderId,
      text: dto.text,
      createdAt: Timestamp.fromMillisecondsSinceEpoch(dto.createdAtMs),
      isRead: dto.isRead,
    );
  }

  MessageDto toDto(Message message) {
    return MessageDto(
      id: message.messageId,
      chatId: '',
      senderId: message.senderId,
      text: message.text,
      createdAtMs: message.createdAt.millisecondsSinceEpoch,
      isRead: message.isRead,
    );
  }
}
