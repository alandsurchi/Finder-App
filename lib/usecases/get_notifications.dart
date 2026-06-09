import '../core/utils/result.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  const GetNotifications(this.repository);

  Future<Result<List<NotificationModel>>> call() {
    return repository.getNotifications();
  }
}
