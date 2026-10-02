import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/errors/exceptions.dart';
import 'package:finder/core/utils/result.dart';
import 'package:finder/core/utils/timestamp.dart';
import 'package:finder/services/chat/chat_socket.dart';
import 'package:finder/services/chat_service.dart';
import 'package:finder/services/push/push_service.dart' show activeChatIdProvider;
import 'package:finder/models/conversation_model.dart';
import 'package:finder/features/chat/domain/message.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/l10n/l10n.dart';
import '../app/di/app_providers.dart';
import '../app/lifecycle/app_lifecycle_provider.dart';
import '../core/utils/polling.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(apiClient: ref.read(apiClientProvider));
});

final conversationsStreamProvider = StreamProvider<List<ConversationModel>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final userId = ref.watch(authStateProvider).userId ?? '';
  // Re-created (and fetched at once) whenever the socket reports a change.
  ref.watch(conversationsRefreshTickProvider);
  if (userId.isEmpty) return Stream.value(const []);
  return pollWhileVisible<List<ConversationModel>>(
    ref,
    interval: ChatService.conversationsInterval,
    fetch: () => chatService.fetchConversations(userId),
    equals: listsEqual,
  );
});

/// Total unread conversations, for the Messages tab badge.
final unreadConversationsCountProvider = Provider<int>((ref) {
  final convos = ref.watch(conversationsStreamProvider).value ?? const [];
  return convos.where((c) => c.unreadCount > 0).length;
});

/// Messages of one chat: the newest page from the server (older pages on
/// demand), live updates from the socket, merged with the messages that are
/// still being sent (optimistic) or failed to send.
class ChatMessagesController extends StateNotifier<AsyncValue<List<Message>>> {
  final Ref ref;
  final String chatId;
  Timer? _timer;
  Timer? _typingStop;
  ProviderSubscription<AsyncValue<SocketEvent>>? _socketSub;
  List<Message> _server = const [];
  final List<Message> _pending = [];
  int _localSeq = 0;
  int? _peerReadAtMs;
  int? _peerDeliveredAtMs;
  String? _nextCursor;
  bool _hasMore = false;
  bool _loadingOlder = false;
  DateTime _lastLoad = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastTypingSent = DateTime.fromMillisecondsSinceEpoch(0);
  bool _typing = false;

  /// First message the viewer had not seen when the chat opened (the
  /// "unread messages" divider goes above it). Null when everything was read.
  String? firstUnreadId;
  int unreadOnOpen = 0;

  bool get hasMore => _hasMore;
  bool get loadingOlder => _loadingOlder;

  ChatMessagesController(this.ref, this.chatId)
      : super(const AsyncValue.loading()) {
    load();
    _timer = Timer.periodic(ChatService.messagesInterval, (_) => _tick());
    _socketSub = ref.listen<AsyncValue<SocketEvent>>(socketEventsProvider, (_, next) {
      final e = next.value;
      if (e != null) _onSocketEvent(e);
    });
  }

  ChatService get _service => ref.read(chatServiceProvider);
  ChatSocket get _socket => ref.read(chatSocketProvider);
  String get _me => ref.read(authStateProvider).userId ?? '';

  void _tick() {
    if (!ref.read(appIsResumedProvider)) return;
    final interval = ref.read(socketConnectedProvider)
        ? ChatService.messagesIntervalRealtime
        : ChatService.messagesInterval;
    if (DateTime.now().difference(_lastLoad) >= interval) load();
  }

  Future<void> load() async {
    _lastLoad = DateTime.now();
    try {
      final page = await _service.fetchMessages(chatId);
      final first = !state.hasValue;
      _server = page.items;
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      _peerReadAtMs = page.peerReadAtMs;
      _peerDeliveredAtMs = page.peerDeliveredAtMs;
      if (first) _computeFirstUnread(page.myReadAtMsBefore);
      _publish();
    } catch (e, st) {
      if (!state.hasValue) {
        state = AsyncValue.error(
          failureFrom(e, fallback: L10n.current.chatLoadFailed),
          st,
        );
      }
    }
  }

  void _computeFirstUnread(int? readBefore) {
    final me = _me;
    final unread = _server.where((m) =>
        m.senderId != me && (readBefore == null || m.createdAt.millisecondsSinceEpoch > readBefore));
    unreadOnOpen = unread.length;
    firstUnreadId = unread.isEmpty ? null : unread.first.messageId;
  }

  /// Older page above the current list, triggered by scrolling up.
  Future<void> loadOlder() async {
    if (_loadingOlder || !_hasMore || _nextCursor == null) return;
    _loadingOlder = true;
    _publish();
    try {
      final page = await _service.fetchMessages(chatId, cursor: _nextCursor);
      final known = _server.map((m) => m.messageId).toSet();
      _server = [...page.items.where((m) => !known.contains(m.messageId)), ..._server];
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
    } catch (_) {
      // Keep what we have; the user can scroll again.
    } finally {
      _loadingOlder = false;
      _publish();
    }
  }

  void _onSocketEvent(SocketEvent e) {
    switch (e.type) {
      case 'connected':
      case 'authenticated':
        load();
        return;
      case 'message.new':
        if (e.str('chatId') != chatId) return;
        final raw = e.data['message'];
        if (raw is! Map) return;
        final msg = Message.fromApi(Map<String, dynamic>.from(raw));
        _upsert(msg);
        if (msg.senderId != _me) {
          if (ref.read(activeChatIdProvider) == chatId) {
            _socket.sendRead(chatId);
          } else {
            _socket.sendDelivered(chatId);
          }
        }
        return;
      case 'message.read':
        if (e.str('chatId') != chatId || e.str('userId') == _me) return;
        _peerReadAtMs = e.intOf('readAtMs') ?? _peerReadAtMs;
        _peerDeliveredAtMs = _peerReadAtMs;
        _publish();
        return;
      case 'message.delivered':
        if (e.str('chatId') != chatId || e.str('userId') == _me) return;
        _peerDeliveredAtMs = e.intOf('deliveredAtMs') ?? _peerDeliveredAtMs;
        _publish();
        return;
      case 'message.deleted':
        if (e.str('chatId') != chatId) return;
        final id = e.str('messageId');
        _server = [
          for (final m in _server)
            m.messageId == id
                ? m.copyWith(deleted: true, text: '', imageUrl: '', audioUrl: '', waveform: const [])
                : m
        ];
        _publish();
        return;
    }
  }

  void _upsert(Message msg) {
    final idx = _server.indexWhere((m) => m.messageId == msg.messageId);
    if (idx == -1) {
      _server = [..._server, msg];
    } else {
      _server = [for (final m in _server) m.messageId == msg.messageId ? msg : m];
    }
    _publish();
  }

  /// Ticks follow the peer's watermarks, so one UPDATE on the server
  /// re-stamps every bubble here without another fetch.
  Message _stamped(Message m) {
    if (m.senderId != _me || m.isPending || m.failed) return m;
    final at = m.createdAt.millisecondsSinceEpoch;
    final read = m.isRead || (_peerReadAtMs != null && at <= _peerReadAtMs!);
    final delivered = read || m.isDelivered || (_peerDeliveredAtMs != null && at <= _peerDeliveredAtMs!);
    if (read == m.isRead && delivered == m.isDelivered) return m;
    return m.copyWith(isRead: read, isDelivered: delivered);
  }

  void _publish() {
    if (!mounted) return;
    state = AsyncValue.data([..._server.map(_stamped), ..._pending]);
  }

  /// Appends an optimistic bubble, sends, then swaps in the server copy.
  /// A voice note ([localAudioPath]) is uploaded first, then sent. With
  /// [forwardOf] the server copies that message; [forwardSource] seeds the
  /// optimistic bubble.
  Future<Result<Message>> send({
    String? text,
    String? imageUrl,
    String? localAudioPath,
    int? audioMs,
    List<int>? waveform,
    ReplyPreview? replyTo,
    String? forwardOf,
    Message? forwardSource,
  }) async {
    final me = _me;
    final local = Message(
      messageId: 'local-${DateTime.now().millisecondsSinceEpoch}-${_localSeq++}',
      senderId: me,
      text: forwardSource?.text ?? text?.trim() ?? '',
      imageUrl: forwardSource?.imageUrl ?? imageUrl ?? '',
      audioUrl: forwardSource?.audioUrl ?? '',
      localAudioPath: localAudioPath ?? '',
      audioMs: forwardSource?.audioMs ?? audioMs,
      waveform: forwardSource?.waveform ?? waveform,
      replyTo: replyTo,
      forwarded: forwardOf != null,
      forwardOf: forwardOf,
      createdAt: Timestamp.now(),
      isPending: true,
    );
    _pending.add(local);
    _publish();
    return _deliver(local);
  }

  Future<Result<Message>> _deliver(Message local) async {
    try {
      var audioUrl = local.audioUrl;
      if (audioUrl.isEmpty && local.localAudioPath.isNotEmpty) {
        final bytes = await File(local.localAudioPath).readAsBytes();
        audioUrl = await _service.uploadVoice(bytes);
        final idx = _pending.indexWhere((m) => m.messageId == local.messageId);
        if (idx != -1) _pending[idx] = _pending[idx].copyWith(audioUrl: audioUrl);
      }
      final sent = await _service.sendMessage(
        chatId,
        text: local.forwardOf == null ? local.text : null,
        imageUrl: local.forwardOf == null ? local.imageUrl : null,
        audioUrl: local.forwardOf == null ? audioUrl : null,
        audioMs: local.audioMs,
        waveform: local.waveform,
        replyToId: local.replyTo?.id,
        forwardOf: local.forwardOf,
      );
      _pending.removeWhere((m) => m.messageId == local.messageId);
      _upsert(sent);
      return Result.success(sent);
    } catch (e) {
      final idx = _pending.indexWhere((m) => m.messageId == local.messageId);
      if (idx != -1) {
        _pending[idx] = local.copyWith(isPending: false, failed: true);
      }
      _publish();
      return Result.failure(failureFrom(e, fallback: L10n.current.chatNotSentFailure));
    }
  }

  Future<Result<Message>> retry(String localId) async {
    final idx = _pending.indexWhere((m) => m.messageId == localId);
    if (idx == -1) {
      return Result.failure(failureFrom(Object(), fallback: L10n.current.chatNothingToRetry));
    }
    final retrying = _pending[idx].copyWith(isPending: true, failed: false);
    _pending[idx] = retrying;
    _publish();
    return _deliver(retrying);
  }

  void discard(String localId) {
    _pending.removeWhere((m) => m.messageId == localId);
    _publish();
  }

  /// Deletes one of my messages for everyone (a tombstone stays in place).
  Future<Result<void>> deleteMessage(String messageId) async {
    try {
      final gone = await _service.deleteMessage(chatId, messageId);
      if (gone != null) _server = [for (final m in _server) m.messageId == messageId ? gone : m];
      _publish();
      return Result.success(null);
    } catch (e) {
      return Result.failure(failureFrom(e, fallback: L10n.current.chatDeleteFailed));
    }
  }

  /// Hides any message on this account only.
  Future<Result<void>> hideMessage(String messageId) async {
    try {
      await _service.deleteMessage(chatId, messageId, forMe: true);
      _server = _server.where((m) => m.messageId != messageId).toList();
      _publish();
      return Result.success(null);
    } catch (e) {
      return Result.failure(failureFrom(e, fallback: L10n.current.chatDeleteFailed));
    }
  }

  /// "typing…" for the peer: at most one `true` every 3 s, `false` at once.
  void sendTyping(bool typing) {
    final now = DateTime.now();
    if (typing) {
      if (!_typing || now.difference(_lastTypingSent) > const Duration(seconds: 3)) {
        _socket.sendTyping(chatId, true);
        _lastTypingSent = now;
      }
      _typing = true;
      _typingStop?.cancel();
      _typingStop = Timer(const Duration(seconds: 3), () => sendTyping(false));
    } else if (_typing) {
      _typing = false;
      _typingStop?.cancel();
      _socket.sendTyping(chatId, false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _typingStop?.cancel();
    _socketSub?.close();
    if (_typing) _socket.sendTyping(chatId, false);
    super.dispose();
  }
}

final chatMessagesProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesController, AsyncValue<List<Message>>, String>(
  (ref, chatId) => ChatMessagesController(ref, chatId),
);

/// The message being replied to in the open chat (null = none).
final replyDraftProvider =
    StateProvider.autoDispose.family<ReplyPreview?, String>((ref, chatId) => null);
