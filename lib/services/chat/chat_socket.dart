import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../app/di/app_providers.dart';
import '../../app/lifecycle/app_lifecycle_provider.dart';
import '../../core/config/app_config.dart';
import '../../features/auth/presentation/auth_state_provider.dart';

/// One event from the realtime channel (`type` plus the raw payload).
class SocketEvent {
  final String type;
  final Map<String, dynamic> data;
  const SocketEvent(this.type, this.data);

  String str(String key) => data[key]?.toString() ?? '';
  int? intOf(String key) => (data[key] as num?)?.toInt();
}

/// Bumped whenever the socket learns something the conversation list
/// should show (new message, receipts, presence). The list re-fetches.
final conversationsRefreshTickProvider = StateProvider<int>((ref) => 0);

/// True while the realtime channel is authenticated.
final socketConnectedProvider = StateProvider<bool>((ref) => false);

/// The chat socket. Connects when a user is signed in and the app is in the
/// foreground; reconnects with backoff; everything it hears is published on
/// [events]. REST keeps working without it.
class ChatSocket {
  final Ref ref;
  ChatSocket(this.ref) {
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.isSignedIn && (prev == null || !prev.isSignedIn || prev.userId != next.userId)) {
        connect();
      } else if (!next.isSignedIn) {
        close();
      }
    });
    ref.listen<bool>(appIsResumedProvider, (_, resumed) {
      if (resumed) {
        _pauseTimer?.cancel();
        if (_wanted) connect();
      } else {
        // Keep the socket a little while: quick app switches are common.
        _pauseTimer?.cancel();
        _pauseTimer = Timer(const Duration(seconds: 10), () => _disconnect(keepWanted: true));
      }
    });
  }

  final _events = StreamController<SocketEvent>.broadcast();
  Stream<SocketEvent> get events => _events.stream;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  Timer? _pauseTimer;
  Timer? _refreshDebounce;
  int _attempt = 0;
  bool _wanted = false;
  bool _connecting = false;

  bool get connected => ref.read(socketConnectedProvider);

  static const _listEvents = {'message.new', 'message.read', 'message.delivered', 'message.deleted', 'presence', 'presence.snapshot'};

  Uri? _uri() {
    final token = ref.read(apiClientProvider).token;
    if (token == null || token.isEmpty) return null;
    final api = Uri.parse(AppConfig.apiUrl);
    return api.replace(
      scheme: api.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws',
      queryParameters: {'token': token},
    );
  }

  void connect() {
    _wanted = true;
    _reconnectTimer?.cancel();
    if (_channel != null || _connecting) return;
    if (!ref.read(appIsResumedProvider)) return;
    final uri = _uri();
    if (uri == null) return;
    _connecting = true;
    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      _sub = channel.stream.listen(
        _onData,
        onError: (_) => _onClosed(),
        onDone: _onClosed,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Chat socket connect failed: $e');
      _channel = null;
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _onData(dynamic raw) {
    Map<String, dynamic> map;
    try {
      map = Map<String, dynamic>.from(json.decode(raw as String) as Map);
    } catch (_) {
      return;
    }
    final type = map['type']?.toString() ?? '';
    if (type == 'authenticated') {
      _attempt = 0;
      ref.read(socketConnectedProvider.notifier).state = true;
    }
    final event = SocketEvent(type, map);
    _events.add(event);
    if (_listEvents.contains(type)) _bumpList();
  }

  void _bumpList() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(conversationsRefreshTickProvider.notifier).state++;
    });
  }

  void _onClosed() {
    _sub?.cancel();
    _sub = null;
    _channel = null;
    if (ref.read(socketConnectedProvider)) {
      ref.read(socketConnectedProvider.notifier).state = false;
    }
    _events.add(const SocketEvent('disconnected', {}));
    if (_wanted) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    final base = min(30000, 1000 * pow(2, _attempt).toInt());
    final jitter = (base * (Random().nextDouble() * 0.4 - 0.2)).toInt();
    _attempt = min(_attempt + 1, 6);
    _reconnectTimer = Timer(Duration(milliseconds: base + jitter), () {
      if (_wanted && ref.read(appIsResumedProvider)) connect();
    });
  }

  /// Sends a client event (`typing`, `delivered`, `read`). Silently dropped
  /// while offline: the REST fallbacks cover those cases.
  void send(Map<String, dynamic> event) {
    final ch = _channel;
    if (ch == null || !connected) return;
    try {
      ch.sink.add(json.encode(event));
    } catch (_) {}
  }

  void sendTyping(String chatId, bool isTyping) =>
      send({'type': 'typing', 'chatId': chatId, 'isTyping': isTyping});
  void sendDelivered(String chatId) => send({'type': 'delivered', 'chatId': chatId});
  void sendRead(String chatId) => send({'type': 'read', 'chatId': chatId});

  void _disconnect({bool keepWanted = false}) {
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _sub = null;
    try { _channel?.sink.close(); } catch (_) {}
    _channel = null;
    if (!keepWanted) _wanted = false;
    if (ref.read(socketConnectedProvider)) {
      ref.read(socketConnectedProvider.notifier).state = false;
    }
  }

  void close() => _disconnect();

  void dispose() {
    _disconnect();
    _pauseTimer?.cancel();
    _refreshDebounce?.cancel();
    _events.close();
  }
}

final chatSocketProvider = Provider<ChatSocket>((ref) {
  final socket = ChatSocket(ref);
  ref.onDispose(socket.dispose);
  if (ref.read(authStateProvider).isSignedIn) socket.connect();
  return socket;
});

/// Every socket event, for controllers that care about one chat.
final socketEventsProvider = StreamProvider<SocketEvent>(
  (ref) => ref.watch(chatSocketProvider).events,
);
