import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/result.dart';
import '../domain/notification_settings.dart';

/// Notification preferences with optimistic toggles.
class NotificationSettingsController
    extends StateNotifier<AsyncValue<NotificationSettings>> {
  final Ref ref;

  NotificationSettingsController(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    final result = await ref.read(profileRepositoryProvider).getNotificationSettings();
    if (!mounted) return;
    state = result.fold(
      onSuccess: (s) => AsyncValue.data(s),
      onFailure: (f) => AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<Result<NotificationSettings>> update(NotificationSettings next) async {
    final before = state.value;
    state = AsyncValue.data(next);
    final result =
        await ref.read(profileRepositoryProvider).updateNotificationSettings(next);
    if (!mounted) return result;
    result.fold(
      onSuccess: (saved) => state = AsyncValue.data(saved),
      onFailure: (_) {
        if (before != null) state = AsyncValue.data(before);
      },
    );
    return result;
  }
}

final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsController, AsyncValue<NotificationSettings>>(
  (ref) => NotificationSettingsController(ref),
);
