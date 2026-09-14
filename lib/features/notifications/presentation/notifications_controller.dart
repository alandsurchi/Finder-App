import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../app/lifecycle/app_lifecycle_provider.dart';
import '../../../core/utils/result.dart';
import '../../../models/notification_model.dart';

/// The user's notifications, refreshed in the background so the bell badge
/// stays current. Read state changes are applied optimistically.
class NotificationsController extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref ref;
  Timer? _timer;

  static const Duration refreshInterval = Duration(seconds: 30);

  NotificationsController(this.ref) : super(const AsyncValue.loading()) {
    loadNotifications();
    _timer = Timer.periodic(refreshInterval, (_) {
      if (ref.read(appIsResumedProvider)) loadNotifications(silent: true);
    });
    ref.listen<bool>(appIsResumedProvider, (was, isNow) {
      if (isNow && was == false) loadNotifications(silent: true);
    });
  }

  Future<void> loadNotifications({bool silent = false}) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.getNotifications();
    if (!mounted) return;
    result.fold(
      onSuccess: (items) => state = AsyncValue.data(items),
      onFailure: (failure) {
        // Keep what we have during background refreshes.
        if (!silent || !state.hasValue) {
          state = AsyncValue.error(failure, StackTrace.current);
        }
      },
    );
  }

  List<NotificationModel> get _current =>
      List<NotificationModel>.from(state.value ?? const []);

  Future<Result<void>> markAsRead(String id) async {
    final before = _current;
    final target = before.indexWhere((n) => n.id == id);
    if (target == -1 || !before[target].isUnread) return Result.success(null);

    final after = List<NotificationModel>.from(before);
    after[target] = before[target].copyWith(isUnread: false);
    state = AsyncValue.data(after);

    final result = await ref.read(notificationRepositoryProvider).markAsRead(id);
    if (!result.isSuccess && mounted) state = AsyncValue.data(before);
    return result;
  }

  Future<Result<void>> markAllRead() async {
    final before = _current;
    if (!before.any((n) => n.isUnread)) return Result.success(null);
    state = AsyncValue.data(
      before.map((n) => n.copyWith(isUnread: false)).toList(),
    );

    final result = await ref.read(notificationRepositoryProvider).markAllRead();
    if (!result.isSuccess && mounted) state = AsyncValue.data(before);
    return result;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final notificationsControllerProvider = StateNotifierProvider<NotificationsController, AsyncValue<List<NotificationModel>>>(
  (ref) => NotificationsController(ref),
);

/// Unread notifications, for the Home bell badge.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationsControllerProvider).value ?? const [];
  return items.where((n) => n.isUnread).length;
});
