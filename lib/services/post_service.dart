import '../core/network/api_client.dart';
import '../models/item_model.dart';

/// Posts API. Every method throws a typed [AppException] on failure so the
/// caller can show the server's message; nothing is swallowed here.
class PostService {
  final ApiClient _apiClient;

  PostService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const Duration pollInterval = Duration(seconds: 5);

  /// Polls the feed. Emits an error only while there is no data yet; once
  /// something was loaded, transient failures keep the last good list.
  Stream<List<ItemModel>> getPostsStream({
    String? ownerId,
    String? status,
    Duration interval = pollInterval,
  }) async* {
    List<ItemModel>? last;
    while (true) {
      try {
        last = await fetchItems(ownerId: ownerId, status: status);
        yield last;
      } catch (e, st) {
        if (last == null) yield* Stream<List<ItemModel>>.error(e, st);
      }
      await Future<void>.delayed(interval);
    }
  }

  Future<List<ItemModel>> fetchItems({
    String? ownerId,
    String? status,
    String? category,
    int limit = 100,
  }) async {
    final query = <String, String>{'limit': '$limit'};
    if (ownerId != null && ownerId.isNotEmpty) query['ownerId'] = ownerId;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (category != null && category.isNotEmpty) query['category'] = category;
    final qs = Uri(queryParameters: query).query;

    final res = await _apiClient.get('/posts?$qs');
    final items = (res is Map ? res['items'] : res) as List<dynamic>? ?? [];
    return items
        .map((e) => ItemModel.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<ItemModel> fetchById(String id) async {
    final res = await _apiClient.get('/posts/$id');
    return ItemModel.fromApi(Map<String, dynamic>.from(res as Map));
  }

  Future<List<ItemModel>> fetchSimilar(String id) async {
    final res = await _apiClient.get('/posts/$id/similar');
    final list = res as List<dynamic>? ?? [];
    return list
        .map((e) => ItemModel.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<ItemModel> createPost(ItemModel post) async {
    final res = await _apiClient.post('/posts', post.toApiBody());
    return ItemModel.fromApi(Map<String, dynamic>.from(res as Map));
  }

  Future<ItemModel> updatePost(String id, Map<String, dynamic> body) async {
    final res = await _apiClient.put('/posts/$id', body);
    return ItemModel.fromApi(Map<String, dynamic>.from(res as Map));
  }

  Future<void> deletePost(String id) => _apiClient.delete('/posts/$id');

  Future<ItemModel> markAsResolved(String id) =>
      updatePost(id, {'status': 'resolved'});

  Future<ItemModel> reopen(String id) => updatePost(id, {'status': 'active'});

  Future<void> reportPost(String postId, String reason) =>
      _apiClient.post('/posts/$postId/report', {'reason': reason});
}
