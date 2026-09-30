import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notifications/presentation/notifications_controller.dart';
import '../../models/notification_model.dart';
import 'push_service.dart';

final localAlertsProvider = Provider<LocalAlerts>((ref) => LocalAlerts(ref));

/// Banners for phones that cannot receive push (an iPhone sideloaded with a
/// free Apple ID has no APNs token). It watches the notification poll and
/// shows a local banner for every unread row it has not seen before, while
/// the app is open. Does nothing when the device is registered for push, so
/// Android never gets the same alert twice.
class LocalAlerts {
  LocalAlerts(this._ref);

  final Ref _ref;
  final Set<String> _seen = {};
  bool _primed = false;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    _ref.listen<AsyncValue<List<NotificationModel>>>(
      notificationsControllerProvider,
      (previous, next) => _onList(next.value),
      fireImmediately: true,
    );
  }

  /// Forget what was seen (sign-out): the next sign-in starts fresh.
  void reset() {
    _seen.clear();
    _primed = false;
  }

  void _onList(List<NotificationModel>? items) {
    if (items == null) return;
    final push = _ref.read(pushServiceProvider);
    if (!_primed) {
      // The first list after start is history, not news.
      _seen.addAll(items.map((n) => n.id));
      _primed = true;
      return;
    }
    for (final n in items) {
      if (_seen.contains(n.id)) continue;
      _seen.add(n.id);
      if (!n.isUnread) continue;
      if (push.hasPushToken) continue; // FCM already showed it.
      final data = Map<String, dynamic>.from(n.data);
      final chatId = data['chatId']?.toString() ?? '';
      if (data['type'] == 'message' &&
          chatId.isNotEmpty &&
          _ref.read(activeChatIdProvider) == chatId) {
        continue;
      }
      data.putIfAbsent('notificationId', () => n.id);
      push.showLocal(title: n.title, body: n.message, data: data).catchError((Object e) {
        debugPrint('Local alert failed: $e');
      });
    }
  }
}
