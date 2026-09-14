import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/di/app_providers.dart';
import '../../features/notifications/presentation/notification_navigator.dart';
import '../../features/notifications/presentation/notifications_controller.dart';
import '../../providers/chat_provider.dart';
import '../../providers/post_provider.dart';
import '../../features/profile/presentation/profile_controller.dart';
import '../../features/profile/presentation/verification_controller.dart';

/// The chat currently on screen. Its own messages refresh the thread instead
/// of popping a banner.
final activeChatIdProvider = StateProvider<String?>((ref) => null);

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref));

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // The server always sends a `notification` block, so Android/iOS display
  // background messages themselves. Nothing to do here.
}

/// Phone notifications through Firebase Cloud Messaging.
///
/// The server decides what to send (see backend/lib/push.js); this class
/// registers the device, shows foreground banners and turns taps into
/// navigation. On web it is a no-op.
class PushService {
  PushService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String? _registeredToken;
  Map<String, dynamic>? _pendingOpen;

  static const AndroidNotificationChannel _messagesChannel =
      AndroidNotificationChannel(
    'finder_messages',
    'Messages',
    description: 'New chat messages',
    importance: Importance.high,
  );
  static const AndroidNotificationChannel _updatesChannel =
      AndroidNotificationChannel(
    'finder_updates',
    'Updates',
    description: 'Post and account updates',
    importance: Importance.defaultImportance,
  );

  bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isReady => _ready;

  /// Call once at startup. Never throws: a missing Firebase config simply
  /// leaves push off.
  Future<void> init() async {
    if (!supported || _ready) return;
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Push disabled (Firebase not configured): $e');
      return;
    }
    try {
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_notification'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _openPayload(response.payload),
      );
      final android = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_messagesChannel);
      await android?.createNotificationChannel(_updatesChannel);

      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _queueOpen(m.data));
      FirebaseMessaging.instance.onTokenRefresh.listen(_register);
      _ready = true;

      // Cold start from a notification tap (FCM or a local banner).
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _pendingOpen = Map<String, dynamic>.from(initial.data);
      final launch = await _local.getNotificationAppLaunchDetails();
      final payload = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true && payload != null) {
        _pendingOpen = _decode(payload);
      }
    } catch (e) {
      debugPrint('Push setup failed: $e');
    }
  }

  /// Asks for permission (Android 13+ / iOS) and registers the device for
  /// the signed-in user. Safe to call on every sign-in.
  Future<void> syncToken() async {
    if (!_ready) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _register(token);
    } catch (e) {
      debugPrint('Push token sync failed: $e');
    }
  }

  /// Stops phone notifications for this device (call before signing out).
  Future<void> unregister() async {
    if (!_ready) return;
    try {
      final token = _registeredToken ?? await FirebaseMessaging.instance.getToken();
      final api = _ref.read(apiClientProvider);
      if (token != null && api.isAuthenticated) {
        await api.deleteWithBody('/profile/push-token', {'token': token});
      }
    } catch (e) {
      debugPrint('Push token removal failed: $e');
    } finally {
      _registeredToken = null;
    }
  }

  /// Opens the screen for a notification tapped before the app was ready
  /// (cold start). Call once the user is signed in and the navigator exists.
  Future<void> flushPendingOpen() async {
    final data = _pendingOpen;
    if (data == null) return;
    _pendingOpen = null;
    await _open(data);
  }

  Future<void> _register(String token) async {
    final api = _ref.read(apiClientProvider);
    if (!api.isAuthenticated) return;
    try {
      await api.post('/profile/push-token', {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
      _registeredToken = token;
    } catch (e) {
      debugPrint('Push token registration failed: $e');
    }
  }

  Future<void> _onForeground(RemoteMessage message) async {
    final data = Map<String, dynamic>.from(message.data);
    final type = data['type']?.toString() ?? '';
    final chatId = data['chatId']?.toString() ?? '';

    // Keep the app's own lists fresh without waiting for the next poll.
    final api = _ref.read(apiClientProvider);
    if (api.isAuthenticated) {
      _ref.invalidate(conversationsStreamProvider);
      _ref
          .read(notificationsControllerProvider.notifier)
          .loadNotifications(silent: true);
    }

    if (type == 'verification' && api.isAuthenticated) {
      _ref.read(verificationProvider.notifier).load();
      _ref.read(profileControllerProvider.notifier).loadProfile();
    }

    if (type == 'message' &&
        chatId.isNotEmpty &&
        _ref.read(activeChatIdProvider) == chatId) {
      // The user is looking at this chat: refresh it, no banner.
      _ref.read(chatMessagesProvider(chatId).notifier).load();
      return;
    }

    final title = message.notification?.title ?? data['title']?.toString() ?? 'Finder';
    final body = message.notification?.body ?? data['body']?.toString() ?? '';
    final channel = type == 'message' ? _messagesChannel : _updatesChannel;
    final tag = chatId.isNotEmpty ? chatId : data['postId']?.toString();

    await _local.show(
      id: (tag ?? title).hashCode & 0x7fffffff,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.high,
          tag: tag,
          icon: '@drawable/ic_notification',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
  }

  void _queueOpen(Map<String, dynamic> data) {
    // Delivered while the app is running: open right away.
    _open(Map<String, dynamic>.from(data));
  }

  void _openPayload(String? payload) {
    final data = _decode(payload);
    if (data != null) _open(data);
  }

  Future<void> _open(Map<String, dynamic> data) {
    return openNotificationTarget(
      data,
      posts: _ref.read(postServiceProvider),
    );
  }

  static Map<String, dynamic>? _decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final v = jsonDecode(payload);
      return v is Map ? Map<String, dynamic>.from(v) : null;
    } catch (_) {
      return null;
    }
  }
}
