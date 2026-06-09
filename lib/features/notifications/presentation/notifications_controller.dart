import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../models/notification_model.dart';

class NotificationsController extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref ref;

  NotificationsController(this.ref) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final usecase = ref.read(getNotificationsProvider);
    final result = await usecase();
    state = result.fold(
      onSuccess: (items) => AsyncValue.data(items),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<void> markAsRead(int index) async {
    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAsRead(index);
    state = result.fold(
      onSuccess: (items) => AsyncValue.data(items),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }
}

final notificationsControllerProvider = StateNotifierProvider<NotificationsController, AsyncValue<List<NotificationModel>>>(
  (ref) => NotificationsController(ref),
);
