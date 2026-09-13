import '../core/utils/result.dart';
import '../models/notification_model.dart';

abstract class NotificationRepository {
  Future<Result<List<NotificationModel>>> getNotifications();

  Future<Result<void>> markAsRead(String id);

  Future<Result<void>> markAllRead();
}
