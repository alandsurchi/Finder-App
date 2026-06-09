import '../../core/network/api_client.dart';
import '../../core/utils/pagination.dart';
import '../../models/dto/post_dto.dart';
import 'post_service.dart';

class RailwayPostService implements PostService {
  final ApiClient _apiClient;

  const RailwayPostService({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PageResult<PostDto>> fetchPosts(PageRequest request) async {
    try {
      final queryParams = 'limit=${request.limit}${request.cursor != null ? '&cursor=${request.cursor}' : ''}';
      final res = await _apiClient.get('/posts?$queryParams');

      final itemsList = res['items'] as List<dynamic>;
      final items = itemsList
          .map((item) => PostDto.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      return PageResult(
        items: items,
        nextCursor: res['nextCursor']?.toString(),
        hasMore: res['hasMore'] as bool? ?? false,
      );
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<PostDto> createPost(PostDto dto) async {
    try {
      final res = await _apiClient.post('/posts', dto.toMap());
      return PostDto.fromMap(Map<String, dynamic>.from(res));
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
}
