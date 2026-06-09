import '../../../models/item_model.dart';
import '../domain/post.dart';

class PostItemMapper {
  const PostItemMapper();

  ItemModel toItem(Post post) {
    return ItemModel(
      id: post.id,
      title: post.title,
      description: post.description,
      location: post.location,
      timeAgo: post.createdAtMs == null ? '' : _relativeTime(post.createdAtMs!),
      imagePath: post.imageUrl,
      isLost: post.isLost,
      reward: post.reward,
      isVerified: false,
      category: post.category,
      ownerName: null,
      ownerTrustScore: null,
      lostOn: null,
      lastSeenAt: null,
    );
  }

  Post toPost(ItemModel item, {required String ownerId}) {
    return Post(
      id: item.id,
      title: item.title,
      description: item.description,
      category: item.category,
      isLost: item.isLost,
      reward: item.reward,
      ownerId: ownerId,
      location: item.location,
      imageUrl: item.imagePath,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      updatedAtMs: null,
      status: 'active',
    );
  }

  String _relativeTime(int createdAtMs) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
