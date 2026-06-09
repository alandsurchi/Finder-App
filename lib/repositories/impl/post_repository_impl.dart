import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/pagination.dart';
import '../../core/utils/result.dart';
import '../../features/posts/domain/post.dart';
import '../../features/posts/mappers/post_mapper.dart';
import '../../services/posts/post_service.dart';
import '../post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostService service;
  final PostMapper mapper;

  const PostRepositoryImpl({required this.service, required this.mapper});

  @override
  Future<Result<Post>> createPost(Post post) async {
    try {
      final dto = mapper.toDto(post);
      final created = await service.createPost(dto);
      return Result.success(mapper.fromDto(created));
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: 'Unable to create post'));
    }
  }

  @override
  Future<Result<PageResult<Post>>> getPosts({PageRequest? pageRequest}) async {
    try {
      final request = pageRequest ?? const PageRequest();
      final page = await service.fetchPosts(request);
      final mapped = page.items.map(mapper.fromDto).toList();
      return Result.success(
        PageResult(items: mapped, nextCursor: page.nextCursor, hasMore: page.hasMore),
      );
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: 'Unable to load posts'));
    }
  }
}
