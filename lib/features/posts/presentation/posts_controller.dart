import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/result.dart';
import '../../../models/item_model.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../domain/create_post_input.dart';
import '../mappers/post_item_mapper.dart';

class PostsController extends StateNotifier<AsyncValue<List<ItemModel>>> {
  final Ref ref;
  final PostItemMapper mapper;

  PostsController({required this.ref, required this.mapper})
    : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = const AsyncValue.loading();
    final getPosts = ref.read(getPostsProvider);
    final result = await getPosts();
    state = result.fold(
      onSuccess: (page) =>
          AsyncValue.data(page.items.map(mapper.toItem).toList()),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<Result<ItemModel>> createPost(CreatePostInput input) async {
    final ownerId = ref.read(authStateProvider).userId ?? '';
    if (ownerId.isEmpty) {
      return Result.failure(
        Failure(
          message: 'You must be logged in to post',
          type: FailureType.auth,
        ),
      );
    }

    final item = ItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: input.title,
      description: input.description,
      location: input.location,
      timeAgo: 'Just now',
      imagePath: input.imagePath,
      isLost: input.isLost,
      reward: input.reward,
      isVerified: false,
      category: input.category,
    );

    final createPost = ref.read(createPostProvider);
    final result = await createPost(mapper.toPost(item, ownerId: ownerId));

    return result.fold(
      onSuccess: (post) {
        final created = mapper.toItem(post);
        final current = state.value ?? [];
        state = AsyncValue.data([created, ...current]);
        return Result.success(created);
      },
      onFailure: (failure) {
        if (failure.type != FailureType.auth &&
            failure.type != FailureType.validation) {
          final local = ItemModel(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            title: item.title,
            description: item.description,
            location: item.location,
            timeAgo: 'Just now',
            imagePath: item.imagePath,
            isLost: item.isLost,
            reward: item.reward,
            isVerified: item.isVerified,
            category: item.category,
            lostOn: item.lostOn,
            lastSeenAt: item.lastSeenAt,
            ownerName: item.ownerName,
            ownerTrustScore: item.ownerTrustScore,
          );

          final current = state.value ?? [];
          state = AsyncValue.data([local, ...current]);
          return Result.success(local);
        }
        return Result.failure(failure);
      },
    );
  }
}

final postsControllerProvider =
    StateNotifierProvider<PostsController, AsyncValue<List<ItemModel>>>(
      (ref) => PostsController(ref: ref, mapper: const PostItemMapper()),
    );
