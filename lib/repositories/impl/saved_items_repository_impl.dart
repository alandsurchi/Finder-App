import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../../models/item_model.dart';
import '../saved_items_repository.dart';

class SavedItemsRepositoryImpl implements SavedItemsRepository {
  final ApiClient _apiClient;

  const SavedItemsRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Result<List<ItemModel>>> getSavedItems() async {
    if (!_apiClient.isAuthenticated) {
      return Result.success(const []);
    }

    try {
      final res = await _apiClient.get('/profile/saved');
      final list = res as List<dynamic>;

      final items = list.map((item) {
        final map = Map<String, dynamic>.from(item);
        final createdAtMs = map['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch;
        
        final resolvedMap = {
          'ownerId': map['ownerId'],
          'title': map['title'],
          'description': map['description'],
          'location': map['location'],
          'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAtMs),
          'timeAgo': _relativeTime(createdAtMs),
          'imagePath': map['imageUrl'],
          'isLost': map['isLost'] as bool? ?? true,
          'reward': map['reward'],
          'isVerified': map['isVerified'] as bool? ?? false,
          'category': map['category'],
        };
        
        return ItemModel.fromMap(resolvedMap, map['id']?.toString() ?? '');
      }).toList();

      return Result.success(items);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to load saved items: $e',
          type: FailureType.network,
        ),
      );
    }
  }

  @override
  Future<Result<void>> updateSavedItems(List<ItemModel> items) async {
    if (!_apiClient.isAuthenticated) {
      return Result.failure(
        const Failure(
          message: 'Please log in to save items.',
          type: FailureType.auth,
        ),
      );
    }

    try {
      final existingRes = await getSavedItems();
      if (!existingRes.isSuccess) {
        return Result.failure(existingRes.failure!);
      }
      
      final existing = existingRes.data!;
      final existingIds = existing.map((e) => e.id).toSet();
      final targetIds = items.map((e) => e.id).toSet();

      // Deletions
      for (final id in existingIds) {
        if (!targetIds.contains(id)) {
          await _apiClient.delete('/profile/saved/$id');
        }
      }

      // Additions
      for (final id in targetIds) {
        if (!existingIds.contains(id)) {
          await _apiClient.post('/profile/saved', {'postId': id});
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure(
          message: 'Unable to update saved items: $e',
          type: FailureType.network,
        ),
      );
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
