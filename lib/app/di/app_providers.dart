
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../features/chat/mappers/message_mapper.dart';
import '../../features/posts/mappers/post_mapper.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/chat_repository.dart';
import '../../repositories/post_repository.dart';
import '../../repositories/conversation_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../repositories/saved_items_repository.dart';
import '../../repositories/impl/auth_repository_impl.dart';
import '../../repositories/impl/chat_repository_impl.dart';
import '../../repositories/impl/post_repository_impl.dart';
import '../../repositories/impl/conversation_repository_impl.dart';
import '../../repositories/impl/notification_repository_impl.dart';
import '../../repositories/impl/profile_repository_impl.dart';
import '../../repositories/impl/saved_items_repository_impl.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/analytics/mock_analytics_service.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/railway_auth_service.dart';
import '../../services/chat/chat_service.dart';
import '../../services/chat/railway_chat_service.dart';
import '../../services/posts/post_service.dart';
import '../../services/posts/railway_post_service.dart';
import '../../usecases/create_post.dart';
import '../../usecases/get_posts.dart';
import '../../usecases/login_user.dart';
import '../../usecases/send_message.dart';
import '../../usecases/get_conversations.dart';
import '../../usecases/get_notifications.dart';
import '../../usecases/get_messages.dart';
import '../../usecases/signup_user.dart';
import '../../usecases/send_password_reset.dart';
import '../../usecases/reset_password.dart';

// ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider must be overridden in main()');
});



final authServiceProvider = Provider<AuthService>(
  (ref) => RailwayAuthService(
    apiClient: ref.read(apiClientProvider),
  ),
);

final postServiceProvider = Provider<PostService>(
  (ref) => RailwayPostService(apiClient: ref.read(apiClientProvider)),
);

final chatServiceProvider = Provider<ChatService>(
  (ref) => RailwayChatService(
    apiClient: ref.read(apiClientProvider),
  ),
);

final postMapperProvider = Provider<PostMapper>((ref) => const PostMapper());

final messageMapperProvider = Provider<MessageMapper>(
  (ref) => const MessageMapper(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(service: ref.read(authServiceProvider)),
);

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepositoryImpl(
    service: ref.read(postServiceProvider),
    mapper: ref.read(postMapperProvider),
  ),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(
    service: ref.read(chatServiceProvider),
    mapper: ref.read(messageMapperProvider),
  ),
);

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => ConversationRepositoryImpl(
    apiClient: ref.read(apiClientProvider),
  ),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    apiClient: ref.read(apiClientProvider),
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    apiClient: ref.read(apiClientProvider),
  ),
);

final savedItemsRepositoryProvider = Provider<SavedItemsRepository>(
  (ref) => SavedItemsRepositoryImpl(
    apiClient: ref.read(apiClientProvider),
  ),
);

final loginUserProvider = Provider<LoginUser>(
  (ref) => LoginUser(ref.read(authRepositoryProvider)),
);

final signupUserProvider = Provider<SignupUser>(
  (ref) => SignupUser(ref.read(authRepositoryProvider)),
);

final getPostsProvider = Provider<GetPosts>(
  (ref) => GetPosts(ref.read(postRepositoryProvider)),
);

final createPostProvider = Provider<CreatePost>(
  (ref) => CreatePost(ref.read(postRepositoryProvider)),
);

final sendMessageProvider = Provider<SendMessage>(
  (ref) => SendMessage(ref.read(chatRepositoryProvider)),
);

final getMessagesProvider = Provider<GetMessages>(
  (ref) => GetMessages(ref.read(chatRepositoryProvider)),
);

final getConversationsProvider = Provider<GetConversations>(
  (ref) => GetConversations(ref.read(conversationRepositoryProvider)),
);

final getNotificationsProvider = Provider<GetNotifications>(
  (ref) => GetNotifications(ref.read(notificationRepositoryProvider)),
);

final sendPasswordResetProvider = Provider<SendPasswordReset>(
  (ref) => SendPasswordReset(ref.read(authRepositoryProvider)),
);

final resetPasswordProvider = Provider<ResetPassword>(
  (ref) => ResetPassword(ref.read(authRepositoryProvider)),
);
