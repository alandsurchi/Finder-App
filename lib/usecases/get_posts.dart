import '../core/utils/pagination.dart';
import '../core/utils/result.dart';
import '../features/posts/domain/post.dart';
import '../repositories/post_repository.dart';

class GetPosts {
  final PostRepository repository;

  const GetPosts(this.repository);

  Future<Result<PageResult<Post>>> call({PageRequest? pageRequest}) {
    return repository.getPosts(pageRequest: pageRequest);
  }
}
