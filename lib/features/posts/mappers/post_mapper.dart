import '../../../models/dto/post_dto.dart';
import '../domain/post.dart';

class PostMapper {
  const PostMapper();

  Post fromDto(PostDto dto) {
    return Post(
      id: dto.id,
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

  PostDto toDto(Post post) {
    return PostDto(
      id: post.id,
      title: post.title,
      description: post.description,
      category: post.category,
      isLost: post.isLost,
      reward: post.reward,
      ownerId: post.ownerId,
      location: post.location,
      imageUrl: post.imageUrl,
      createdAtMs: post.createdAtMs,
      updatedAtMs: post.updatedAtMs,
      status: post.status,
    );
  }
}
