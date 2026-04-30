import '../core/utils/result.dart';
import '../features/posts/domain/post.dart';
import '../repositories/post_repository.dart';

class CreatePost {
  final PostRepository repository;

  const CreatePost(this.repository);

  Future<Result<Post>> call(Post post) {
    return repository.createPost(post);
  }
}
