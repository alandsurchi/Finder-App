import '../core/utils/timestamp.dart';
import '../../core/network/api_client.dart';
import '../models/item_model.dart';

class PostService {
  final ApiClient _apiClient;

  PostService({required ApiClient apiClient}) : _apiClient = apiClient;

  // Real-time stream of all posts (polling fallback)
  Stream<List<ItemModel>> getPostsStream({String? ownerId}) async* {
    yield await fetchItems(ownerId: ownerId);
    yield* Stream.periodic(const Duration(seconds: 5)).asyncMap((_) => fetchItems(ownerId: ownerId));
  }

  Future<List<ItemModel>> fetchItems({String? ownerId}) async {
    try {
      final queryParams = ownerId != null ? 'limit=50&ownerId=$ownerId' : 'limit=50';
      final res = await _apiClient.get('/posts?$queryParams');
      final itemsList = res['items'] as List<dynamic>;
      return itemsList.map((item) {
        final map = Map<String, dynamic>.from(item);
        final createdAtMs = map['createdAtMs'] as int? ?? DateTime.now().millisecondsSinceEpoch;
        map['createdAt'] = Timestamp.fromMillisecondsSinceEpoch(createdAtMs);
        return ItemModel.fromMap(map, map['id']?.toString() ?? '');
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // Create a new post
  Future<void> createPost(ItemModel post) async {
    try {
      final map = post.toMap();
      map['id'] = post.id;
      map['createdAtMs'] = post.createdAt.millisecondsSinceEpoch;
      map.remove('createdAt'); // Not JSON-serializable
      
      await _apiClient.post('/posts', map);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Update a post
  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    try {
      await _apiClient.put('/posts/$id', data);
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  // Delete a post
  Future<void> deletePost(String id) async {
    try {
      await _apiClient.delete('/posts/$id');
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Mark post as resolved
  Future<void> markAsResolved(String id) async {
    try {
      await _apiClient.put('/posts/$id', {'status': 'resolved'});
    } catch (e) {
      throw Exception('Failed to resolve post: $e');
    }
  }

  // Report post
  Future<void> reportPost(String postId, String reporterId, String reason) async {
    try {
      await _apiClient.post('/posts/$postId/report', {
        'reporterId': reporterId,
        'reason': reason,
      });
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }
}
