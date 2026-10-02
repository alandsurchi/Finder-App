import 'package:flutter/material.dart';

import '../../../widgets/ui/ui.dart';
import '../domain/message.dart';

/// WhatsApp-style delivery state for one of my messages:
/// clock = sending, one grey tick = sent, two grey = delivered, two blue = seen.
class MessageTicks extends StatelessWidget {
  final Message message;
  final Color color;
  final double size;

  const MessageTicks({super.key, required this.message, required this.color, this.size = 14});

  static ({IconData icon, bool read}) stateOf(Message m) {
    if (m.isPending) return (icon: Icons.schedule_rounded, read: false);
    if (m.isRead) return (icon: Icons.done_all_rounded, read: true);
    if (m.isDelivered) return (icon: Icons.done_all_rounded, read: false);
    return (icon: Icons.done_rounded, read: false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final s = stateOf(message);
    return Icon(s.icon, size: size, color: s.read ? t.tickRead : color);
  }
}

/// Same rule for the conversation list, from the list's own flags.
class ListTicks extends StatelessWidget {
  final bool read;
  final bool delivered;
  final Color color;
  const ListTicks({super.key, required this.read, required this.delivered, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Icon(
      read || delivered ? Icons.done_all_rounded : Icons.done_rounded,
      size: 14,
      color: read ? t.tickRead : color,
    );
  }
}
