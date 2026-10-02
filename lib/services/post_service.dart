import '../core/network/api_client.dart';
import 'package:latlong2/latlong.dart';
import '../models/item_model.dart';

/// Posts API. Every method throws a typed [AppException] on failure so the
/// caller can show the server's message; nothing is swallowed here.
/// A page of posts plus the cursor of the next (older) page.
class PostsPage {
  final List<ItemModel> items;
  final String? nextCursor;
  final bool hasMore;
  const PostsPage({required this.items, this.nextCursor, this.hasMore = false});
}

class PostService {
  final ApiClient _apiClient;

  PostService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Feed refresh cadence while the app is visible. Push notifications
  /// cover anything that must arrive faster.
  static const Duration pollInterval = Duration(seconds: 15);

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

  /// One page of the feed with the cursor for the next one.
  Future<PostsPage> fetchPage({
    String? ownerId,
    String? status,
    String? category,
    String? q,
    LatLng? near,
    int? km,
    String? cursor,
    int limit = 100,
  }) async {
    final query = <String, String>{'limit': '$limit'};
    if (ownerId != null && ownerId.isNotEmpty) query['ownerId'] = ownerId;
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (q != null && q.trim().isNotEmpty) query['q'] = q.trim();
    if (near != null) {
      query['near'] = '${near.latitude},${near.longitude}';
      query['km'] = '${km ?? 25}';
    }
    if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
    final qs = Uri(queryParameters: query).query;

    final res = await _apiClient.get('/posts?$qs');
    final map = res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{'items': res};
    final items = (map['items'] as List<dynamic>? ?? [])
        .map((e) => ItemModel.fromApi(Map<String, dynamic>.from(e as Map)))
        .toList();
    return PostsPage(items: items, nextCursor: map['nextCursor']?.toString(), hasMore: map['hasMore'] == true);
  }

  Future<List<ItemModel>> fetchItems({
    String? ownerId,
    String? status,
    String? category,
    String? q,
    LatLng? near,
    int? km,
    int limit = 100,
  }) async {
    if (q != null || near != null) {
      return (await fetchPage(ownerId: ownerId, status: status, category: category, q: q, near: near, km: km, limit: limit)).items;
    }
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

  /// Smart lost/found matches for one of my posts.
  Future<List<ItemModel>> fetchMatches(String id) async {
    final res = await _apiClient.get('/posts/$id/matches');
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
