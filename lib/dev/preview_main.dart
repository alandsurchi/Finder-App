// ═══════════════════════════════════════════════════════════════════════════════
// DEV-ONLY PREVIEW ENTRYPOINT
//
// Runs the real UI against in-memory sample data so every screen can be
// reviewed in light and dark mode without a backend or an account.
//
//   flutter run -d chrome -t lib/dev/preview_main.dart
//
// Query parameters (web):
//   ?theme=dark            start in dark mode
//   ?screen=item-details   open a route on top of Home (item-details, chat,
//                          notifications, saved-items, my-posts, profile, …)
//
// Nothing in here is imported by lib/main.dart.
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finder/app/di/app_providers.dart';
import 'package:finder/app/router/app_router.dart';
import 'package:finder/app/router/route_names.dart';
import 'package:finder/core/network/api_client.dart';
import 'package:finder/core/utils/timestamp.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/features/chat/domain/message.dart';
import 'package:finder/features/notifications/presentation/notifications_controller.dart';
import 'package:finder/features/posts/presentation/saved_items_controller.dart';
import 'package:finder/features/posts/presentation/similar_items_provider.dart';
import 'package:finder/features/profile/domain/blocked_user.dart';
import 'package:finder/features/profile/domain/privacy_settings.dart';
import 'package:finder/features/profile/presentation/blocked_users_controller.dart';
import 'package:finder/features/profile/presentation/privacy_settings_controller.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/models/conversation_model.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/models/notification_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/providers/chat_provider.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/providers/user_provider.dart';
import 'package:finder/screens/home_screen.dart';
import 'package:finder/theme/app_theme.dart';
import 'package:finder/theme/theme_provider.dart';

const kPreviewUserId = 'preview-user';

// ── Sample data ───────────────────────────────────────────────────────────────

Timestamp _ago(Duration d) => Timestamp.fromDateTime(DateTime.now().subtract(d));

final samplePosts = <ItemModel>[
  ItemModel(
    id: 'p1',
    ownerId: 'u-sarah',
    ownerName: 'Sarah Ahmed',
    title: 'Brown leather wallet',
    description:
        'Lost near the fountain at Central Park. Has a small scratch on the front and a photo of a dog inside.',
    location: 'Central Park, near the fountain',
    timeAgo: '2h ago',
    imagePath: 'assets/postes/wallet.jpg',
    isLost: true,
    reward: '50',
    isVerified: true,
    category: 'Wallets & Bags',
    lostOn: '2026-09-12 18:30',
    createdAt: _ago(const Duration(hours: 2)),
  ),
  ItemModel(
    id: 'p2',
    ownerId: 'u-mike',
    ownerName: 'Mike Chen',
    title: 'Set of car keys with a red keychain',
    description: 'Found on a bench outside the library. Toyota key and two house keys.',
    location: 'City Library, main entrance',
    timeAgo: '5h ago',
    imagePath: 'assets/postes/keys.jpg',
    isLost: false,
    category: 'Keys',
    createdAt: _ago(const Duration(hours: 5)),
  ),
  ItemModel(
    id: 'p3',
    ownerId: kPreviewUserId,
    ownerName: 'You',
    title: 'iPhone 15 in pink case',
    description: 'Left in a taxi on the way to the airport. Lock screen shows a mountain photo.',
    location: 'Airport road',
    timeAgo: '1d ago',
    imagePath: 'assets/postes/iphone 15 pink.jpg',
    isLost: true,
    reward: '200',
    category: 'Electronics',
    createdAt: _ago(const Duration(days: 1)),
  ),
  ItemModel(
    id: 'p4',
    ownerId: 'u-emily',
    ownerName: 'Emily Park',
    title: 'Golden retriever, answers to Max',
    description: 'Very friendly, wearing a blue collar. Found wandering near the river trail.',
    location: 'Riverside trail',
    timeAgo: '1d ago',
    imagePath: 'assets/postes/dog.jpg',
    isLost: false,
    category: 'Pets',
    createdAt: _ago(const Duration(days: 1, hours: 3)),
  ),
  ItemModel(
    id: 'p5',
    ownerId: kPreviewUserId,
    ownerName: 'You',
    title: 'Silver necklace with a moon pendant',
    description: 'Sentimental value. Probably lost at the gym locker room.',
    location: 'Downtown Fitness',
    timeAgo: '3d ago',
    imagePath: 'assets/postes/necklace.jpg',
    isLost: true,
    category: 'Watches & Jewelry',
    isResolved: true,
    createdAt: _ago(const Duration(days: 3)),
  ),
];

final sampleUser = UserModel(
  uid: kPreviewUserId,
  email: 'alex@example.com',
  createdAt: _ago(const Duration(days: 120)),
  fullName: 'Alex Rivera',
  nickName: 'alex',
  phone: '+1 555 0100',
  address: 'Portland, OR',
  job: 'Product designer',
  avatarUrl: 'assets/images/profile img.png',
);

UserModel sampleOwner(String id) => UserModel(
      uid: id,
      email: '$id@example.com',
      createdAt: _ago(const Duration(days: 300)),
      fullName: switch (id) {
        'u-sarah' => 'Sarah Ahmed',
        'u-mike' => 'Mike Chen',
        'u-emily' => 'Emily Park',
        _ => 'Finder User',
      },
      nickName: id.replaceFirst('u-', ''),
      avatarUrl: switch (id) {
        'u-sarah' => 'assets/images/sarah.png',
        'u-mike' => 'assets/images/mike.png',
        'u-emily' => 'assets/images/emily.png',
        _ => '',
      },
    );

final sampleConversations = <ConversationModel>[
  ConversationModel(
    chatId: 'c1',
    postId: 'p1',
    participants: [kPreviewUserId, 'u-sarah'],
    name: 'Sarah Ahmed',
    message: 'I think I found your wallet! Is the scratch on the left side?',
    lastMessageSenderId: 'u-sarah',
    lastUpdatedAt: _ago(const Duration(minutes: 4)),
    createdAt: _ago(const Duration(hours: 2)),
    unreadCount: 2,
    itemName: 'Brown leather wallet',
    isOnline: true,
    isVerified: true,
    avatarUrl: 'assets/images/sarah.png',
  ),
  ConversationModel(
    chatId: 'c2',
    postId: 'p2',
    participants: [kPreviewUserId, 'u-mike'],
    name: 'Mike Chen',
    message: 'Thanks again for returning the keys 🙏',
    lastMessageSenderId: kPreviewUserId,
    lastUpdatedAt: _ago(const Duration(hours: 6)),
    createdAt: _ago(const Duration(days: 1)),
    itemName: 'Car keys',
    avatarUrl: 'assets/images/mike.png',
  ),
  ConversationModel(
    chatId: 'c3',
    postId: 'p4',
    participants: [kPreviewUserId, 'u-emily'],
    name: 'Emily Park',
    message: 'Max is safe with me, come by anytime today.',
    lastMessageSenderId: 'u-emily',
    lastUpdatedAt: _ago(const Duration(days: 1)),
    createdAt: _ago(const Duration(days: 2)),
    itemName: 'Golden retriever',
    avatarUrl: 'assets/images/emily.png',
  ),
];

final sampleMessages = <Message>[
  Message(messageId: 'm1', senderId: 'u-sarah', text: 'Hi! I saw your post about the wallet.', createdAt: _ago(const Duration(minutes: 40))),
  Message(messageId: 'm2', senderId: kPreviewUserId, text: 'Oh amazing, where did you find it?', createdAt: _ago(const Duration(minutes: 35)), isRead: true),
  Message(messageId: 'm3', senderId: 'u-sarah', text: 'Near the fountain, on the bench by the east gate.', createdAt: _ago(const Duration(minutes: 30))),
  Message(messageId: 'm4', senderId: 'u-sarah', text: 'I think I found your wallet! Is the scratch on the left side?', createdAt: _ago(const Duration(minutes: 4))),
];

final sampleNotifications = <NotificationModel>[
  const NotificationModel(id: 'n1', title: 'Possible match found', message: 'A found "brown wallet" was posted 400m from your last seen location.', timeAgo: '5m ago', isUnread: true, type: NotificationType.itemMatch),
  const NotificationModel(id: 'n2', title: 'New message from Sarah', message: 'I think I found your wallet! Is the scratch…', timeAgo: '12m ago', isUnread: true, type: NotificationType.newMessage),
  const NotificationModel(id: 'n3', title: 'Post approved', message: 'Your post "iPhone 15 in pink case" is now visible to the community.', timeAgo: '1d ago', type: NotificationType.postApproved),
  const NotificationModel(id: 'n4', title: 'Welcome to Finder', message: 'Tips: add clear photos and a precise location to get matches faster.', timeAgo: '3d ago', type: NotificationType.system),
];

// ── Fake controllers ──────────────────────────────────────────────────────────

class _PreviewAuth extends AuthStateController {
  _PreviewAuth(ApiClient api) : super(apiClient: api) {
    setAuthenticated(kPreviewUserId);
  }
}

class _PreviewProfile extends ProfileController {
  _PreviewProfile(super.ref);
  @override
  Future<void> loadProfile() async => state = AsyncValue.data(sampleUser);
  @override
  Future<void> updateProfile(UserModel profile) async =>
      state = AsyncValue.data(profile);
}

class _PreviewSaved extends SavedItemsController {
  _PreviewSaved(super.ref);
  @override
  Future<void> loadSavedItems() async =>
      state = AsyncValue.data([samplePosts[1], samplePosts[3]]);
  @override
  Future<void> toggleSaved(ItemModel item) async {
    final current = List<ItemModel>.from(state.value ?? []);
    if (current.any((i) => i.id == item.id)) {
      current.removeWhere((i) => i.id == item.id);
    } else {
      current.add(item);
    }
    state = AsyncValue.data(current);
  }
}

class _PreviewNotifications extends NotificationsController {
  _PreviewNotifications(super.ref);
  @override
  Future<void> loadNotifications() async =>
      state = AsyncValue.data(sampleNotifications);
  @override
  Future<void> markAsRead(int index) async {
    final list = List<NotificationModel>.from(state.value ?? []);
    if (index >= 0 && index < list.length) {
      list[index] = list[index].copyWith(isUnread: false);
    }
    state = AsyncValue.data(list);
  }
}

class _PreviewMyPosts extends MyPostsNotifier {
  _PreviewMyPosts(super.ref);
  @override
  Future<void> load() async => state = AsyncValue.data(
      samplePosts.where((p) => p.ownerId == kPreviewUserId).toList());
  @override
  Future<void> deletePost(String postId) async => state = AsyncValue.data(
      (state.value ?? []).where((p) => p.id != postId).toList());
  @override
  Future<void> markResolved(String postId) async {
    state = AsyncValue.data((state.value ?? []).map((p) {
      if (p.id != postId) return p;
      return ItemModel(
        id: p.id,
        ownerId: p.ownerId,
        title: p.title,
        description: p.description,
        createdAt: p.createdAt,
        location: p.location,
        timeAgo: p.timeAgo,
        imagePath: p.imagePath,
        isLost: p.isLost,
        reward: p.reward,
        isVerified: p.isVerified,
        category: p.category,
        lostOn: p.lostOn,
        lastSeenAt: p.lastSeenAt,
        ownerName: p.ownerName,
        ownerTrustScore: p.ownerTrustScore,
        isResolved: true,
      );
    }).toList());
  }

  @override
  Future<void> updatePost(ItemModel updated) async => state = AsyncValue.data(
      (state.value ?? []).map((p) => p.id == updated.id ? updated : p).toList());
}

class _PreviewPrivacy extends PrivacySettingsController {
  _PreviewPrivacy(super.ref);
  @override
  Future<void> loadSettings() async => state = const AsyncValue.data(
      PrivacySettings(showProfile: true, allowMessages: true, showLocation: false, hidePhone: true));
  @override
  Future<void> updateSettings(PrivacySettings settings) async =>
      state = AsyncValue.data(settings);
}

class _PreviewBlocked extends BlockedUsersController {
  _PreviewBlocked(super.ref);
  @override
  Future<void> loadUsers() async => state = const AsyncValue.data([
        BlockedUser(id: 'b1', name: 'Spam Account', avatarLabel: 'SA'),
      ]);
  @override
  Future<void> unblockUser(String userId) async => state = AsyncValue.data(
      (state.value ?? []).where((u) => u.id != userId).toList());
}

class _PreviewTheme extends ThemeController {
  final ThemeMode initial;
  _PreviewTheme(this.initial);
  @override
  ThemeMode build() => initial;
}

// ── App ───────────────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient();
  await apiClient.init();

  final params = Uri.base.queryParameters;
  final initialTheme =
      params['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
  final screen = params['screen'];

  runApp(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
        authStateProvider.overrideWith((ref) => _PreviewAuth(apiClient)),
        themeControllerProvider.overrideWith(() => _PreviewTheme(initialTheme)),
        postsStreamProvider.overrideWith((ref) => Stream.value(samplePosts)),
        profileControllerProvider.overrideWith((ref) => _PreviewProfile(ref)),
        savedItemsProvider.overrideWith((ref) => _PreviewSaved(ref)),
        notificationsControllerProvider
            .overrideWith((ref) => _PreviewNotifications(ref)),
        myPostsProvider.overrideWith((ref) => _PreviewMyPosts(ref)),
        privacySettingsProvider.overrideWith((ref) => _PreviewPrivacy(ref)),
        blockedUsersProvider.overrideWith((ref) => _PreviewBlocked(ref)),
        conversationsStreamProvider
            .overrideWith((ref) => Stream.value(sampleConversations)),
        messagesStreamProvider
            .overrideWith((ref, chatId) => Stream.value(sampleMessages)),
        userProfileProvider.overrideWith((ref, id) async =>
            id == kPreviewUserId ? sampleUser : sampleOwner(id)),
        similarItemsProvider.overrideWith(
            (ref, id) async => samplePosts.where((p) => p.id != id).take(3).toList()),
      ],
      child: PreviewApp(screen: screen),
    ),
  );
}

class PreviewApp extends ConsumerWidget {
  final String? screen;
  const PreviewApp({super.key, this.screen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Finder preview',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: _PreviewLauncher(screen: screen),
    );
  }
}

class _PreviewLauncher extends StatefulWidget {
  final String? screen;
  const _PreviewLauncher({this.screen});

  @override
  State<_PreviewLauncher> createState() => _PreviewLauncherState();
}

class _PreviewLauncherState extends State<_PreviewLauncher> {
  @override
  void initState() {
    super.initState();
    final s = widget.screen;
    if (s == null || s.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = '/$s';
      Object? args;
      if (route == RouteNames.itemDetails) args = samplePosts.first;
      if (route == RouteNames.chat) {
        args = {'chatId': 'c1', 'userName': 'Sarah Ahmed', 'itemName': 'Brown leather wallet'};
      }
      if (route == RouteNames.forgotPassword) args = 'alex@example.com';
      Navigator.of(context).pushNamed(route, arguments: args);
    });
  }

  @override
  Widget build(BuildContext context) => const HomeScreen();
}
