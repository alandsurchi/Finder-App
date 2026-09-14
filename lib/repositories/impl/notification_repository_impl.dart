import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/relative_time.dart';
import '../../core/utils/result.dart';
import '../../models/notification_model.dart';
import '../notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Result<List<NotificationModel>>> getNotifications() async {
    if (!_apiClient.isAuthenticated) {
      return Result.success(const []);
    }

    try {
      final res = await _apiClient.get('/notifications');
      final list = res as List<dynamic>? ?? [];
      final items = list.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return NotificationModel(
          id: map['id']?.toString() ?? '',
          title: map['title']?.toString() ?? 'Notification',
          message: map['message']?.toString() ?? '',
          timeAgo: relativeTime((map['createdAtMs'] as num?)?.toInt()),
          isUnread: map['isUnread'] == true,
          type: NotificationModel.typeFromApi(map['type']?.toString()),
          data: map['data'] is Map
              ? Map<String, dynamic>.from(map['data'] as Map)
              : const {},
        );
      }).toList();
      return Result.success(items);
    } catch (e) {
      return Result.failure(
        failureFrom(e, fallback: 'Unable to load notifications.'),
      );
    }
  }

  Failure? get _authFailure => _apiClient.isAuthenticated
      ? null
      : const Failure(
          message: 'Please log in to manage notifications.',
          type: FailureType.auth,
        );

  @override
  Future<Result<void>> markAsRead(String id) async {
    final auth = _authFailure;
    if (auth != null) return Result.failure(auth);
    if (id.isEmpty) return Result.success(null);
    try {
      await _apiClient.put('/notifications/$id/read', {});
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        failureFrom(e, fallback: 'Unable to update the notification.'),
      );
    }
  }

  @override
  Future<Result<void>> markAllRead() async {
    final auth = _authFailure;
    if (auth != null) return Result.failure(auth);
    try {
      await _apiClient.put('/notifications/read-all', {});
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        failureFrom(e, fallback: 'Unable to update notifications.'),
      );
    }
  }
}
