import '../core/utils/pagination.dart';
import '../core/utils/result.dart';
import '../features/posts/domain/post.dart';

abstract class PostRepository {
  Future<Result<Post>> createPost(Post post);

  Future<Result<PageResult<Post>>> getPosts({PageRequest? pageRequest});
}
