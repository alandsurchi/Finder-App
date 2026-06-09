import '../../core/utils/pagination.dart';
import '../../models/dto/post_dto.dart';
import 'post_service.dart';

class MockPostService implements PostService {
  @override
  Future<PageResult<PostDto>> fetchPosts(PageRequest request) async {
    return const PageResult(items: [], nextCursor: null, hasMore: false);
  }

  @override
  Future<PostDto> createPost(PostDto dto) async {
    final id = dto.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : dto.id;
    return PostDto(
      id: id,
      title: dto.title,
      description: dto.description,
      category: dto.category,
      isLost: dto.isLost,
      reward: dto.reward,
      ownerId: dto.ownerId,
      location: dto.location,
      imageUrl: dto.imageUrl,
      createdAtMs: dto.createdAtMs,
      updatedAtMs: dto.updatedAtMs,
      status: dto.status,
    );
  }
}
