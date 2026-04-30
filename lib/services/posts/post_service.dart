import '../../core/utils/pagination.dart';
import '../../models/dto/post_dto.dart';

abstract class PostService {
  Future<PageResult<PostDto>> fetchPosts(PageRequest request);

  Future<PostDto> createPost(PostDto dto);
}
