import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../models/notification_model.dart';
import '../notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;
  final List<NotificationModel> _items = [];

  NotificationRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Result<List<NotificationModel>>> getNotifications() async {
    if (!_apiClient.isAuthenticated) {
      _items.clear();
      return Result.success(const []);
    }

    try {
      final res = await _apiClient.get('/notifications');
      final list = res as List<dynamic>;

      _items
        ..clear()
        ..addAll(list.map((item) {
          final map = Map<String, dynamic>.from(item);
          return NotificationModel(
            id: map['id']?.toString() ?? '',
            title: map['title']?.toString() ?? 'Notification',
            message: map['message']?.toString() ?? '',
            timeAgo: _relativeTime(map['createdAtMs'] as int?),
            isUnread: map['isUnread'] as bool? ?? true,
            type: _notificationType(map['type']?.toString()),
          );
        }));

      return Result.success(List.unmodifiable(_items));
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load notifications: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  @override
  Future<Result<List<NotificationModel>>> markAsRead(int index) async {
    if (index < 0 || index >= _items.length) {
      return Result.success(List.unmodifiable(_items));
    }

    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to manage notifications.',
          type: FailureType.auth,
        ),
      );
    }

    final current = _items[index];
    try {
      if (current.id.isNotEmpty) {
        await _apiClient.put('/notifications/${current.id}/read', {});
      }

      _items[index] = current.copyWith(isUnread: false);
      return Result.success(List.unmodifiable(_items));
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update notification: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  NotificationType _notificationType(String? raw) {
    switch (raw) {
      case 'itemMatch':
        return NotificationType.itemMatch;
      case 'newMessage':
        return NotificationType.newMessage;
      case 'postApproved':
        return NotificationType.postApproved;
      default:
        return NotificationType.system;
    }
  }

  String _relativeTime(int? timestampMs) {
    if (timestampMs == null || timestampMs <= 0) {
      return 'Just now';
    }

    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestampMs),
    );

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
