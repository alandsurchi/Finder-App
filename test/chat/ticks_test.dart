import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finder/core/utils/timestamp.dart';
import 'package:finder/features/chat/domain/message.dart';
import 'package:finder/features/chat/presentation/message_ticks.dart';

Message _msg({bool pending = false, bool delivered = false, bool read = false}) => Message(
      messageId: 'm',
      senderId: 'me',
      text: 'hi',
      createdAt: Timestamp.now(),
      isPending: pending,
      isDelivered: delivered,
      isRead: read,
    );

void main() {
  test('tick state follows pending → sent → delivered → read', () {
    expect(MessageTicks.stateOf(_msg(pending: true)).icon, Icons.schedule_rounded);
    expect(MessageTicks.stateOf(_msg()).icon, Icons.done_rounded);
    final delivered = MessageTicks.stateOf(_msg(delivered: true));
    expect(delivered.icon, Icons.done_all_rounded);
    expect(delivered.read, isFalse);
    final read = MessageTicks.stateOf(_msg(delivered: true, read: true));
    expect(read.icon, Icons.done_all_rounded);
    expect(read.read, isTrue);
  });

  test('Message.fromApi reads receipts and waveform, tolerates old payloads', () {
    final m = Message.fromApi({
      'id': '1', 'senderId': 'a', 'text': 'x', 'createdAtMs': 1,
      'isRead': false, 'isDelivered': true, 'waveform': [1, 50, 100], 'forwarded': true,
    });
    expect(m.isDelivered, isTrue);
    expect(m.isRead, isFalse);
    expect(m.waveform, [1, 50, 100]);
    expect(m.forwarded, isTrue);
    final old = Message.fromApi({'id': '2', 'senderId': 'a', 'text': 'y', 'createdAtMs': 1, 'isRead': true});
    expect(old.isRead, isTrue);
    expect(old.isDelivered, isTrue, reason: 'read implies delivered');
    expect(old.waveform, isNull);
  });
}
