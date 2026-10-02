import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/auth_state_provider.dart';
import '../../../services/chat/chat_socket.dart';

/// Online now, or when they were last seen.
class PresenceInfo {
  final bool online;
  final int? lastSeenMs;
  const PresenceInfo({required this.online, this.lastSeenMs});
}

/// Presence of everyone we share a chat with, fed by the socket (snapshot on
/// connect, then per-user updates) and by the conversation list.
class PresenceStore extends StateNotifier<Map<String, PresenceInfo>> {
  PresenceStore(this.ref) : super(const {}) {
    ref.listen<AsyncValue<SocketEvent>>(socketEventsProvider, (_, next) {
      final e = next.value;
      if (e == null) return;
      if (e.type == 'presence.snapshot') {
        final users = e.data['users'];
        if (users is List) {
          final next = Map<String, PresenceInfo>.from(state);
          for (final u in users) {
            if (u is Map) {
              next[u['userId'].toString()] = PresenceInfo(
                online: u['online'] == true,
                lastSeenMs: (u['lastSeenMs'] as num?)?.toInt(),
              );
            }
          }
          state = next;
        }
      } else if (e.type == 'presence') {
        update(e.str('userId'), PresenceInfo(online: e.data['online'] == true, lastSeenMs: e.intOf('lastSeenMs')));
      }
    });
  }

  final Ref ref;

  void update(String userId, PresenceInfo info) {
    if (userId.isEmpty) return;
    state = {...state, userId: info};
  }
}

final presenceProvider = StateNotifierProvider<PresenceStore, Map<String, PresenceInfo>>(
  (ref) => PresenceStore(ref),
);

/// Whether the peer is typing in one chat. Clears itself after 4 s.
class TypingNotifier extends StateNotifier<bool> {
  TypingNotifier(this.ref, this.chatId) : super(false) {
    ref.listen<AsyncValue<SocketEvent>>(socketEventsProvider, (_, next) {
      final e = next.value;
      if (e == null || e.type != 'typing' || e.str('chatId') != chatId) return;
      final me = ref.read(authStateProvider).userId ?? '';
      if (e.str('userId') == me) return;
      _set(e.data['isTyping'] == true);
    });
  }

  final Ref ref;
  final String chatId;
  Timer? _clear;

  void _set(bool typing) {
    _clear?.cancel();
    state = typing;
    if (typing) {
      _clear = Timer(const Duration(seconds: 4), () {
        if (mounted) state = false;
      });
    }
  }

  @override
  void dispose() {
    _clear?.cancel();
    super.dispose();
  }
}

final typingProvider = StateNotifierProvider.autoDispose.family<TypingNotifier, bool, String>(
  (ref, chatId) => TypingNotifier(ref, chatId),
);
