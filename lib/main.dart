import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/di/app_providers.dart';
import 'app/router/app_router.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/auth_state_provider.dart';
import 'features/notifications/presentation/notifications_controller.dart';
import 'features/posts/presentation/saved_items_controller.dart';
import 'features/profile/presentation/blocked_users_controller.dart';
import 'features/profile/presentation/notification_settings_controller.dart';
import 'features/profile/presentation/privacy_settings_controller.dart';
import 'features/profile/presentation/profile_controller.dart';
import 'features/profile/presentation/verification_controller.dart';
import 'providers/chat_provider.dart';
import 'providers/my_posts_provider.dart';
import 'providers/post_provider.dart';
import 'routes.dart';
import 'screens/email_verification_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'widgets/common/action_feedback.dart';
import 'widgets/state/loading_widget.dart';

/// Root navigator, used to reset the stack when the session ends.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  await apiClient.init();

  final container = ProviderContainer(
    overrides: [apiClientProvider.overrideWithValue(apiClient)],
  );
  apiClient.onUnauthorized =
      () => container.read(authStateProvider.notifier).sessionExpired();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FinderApp(),
    ),
  );
}

/// Everything that is scoped to the signed-in user. Reset whenever the
/// session changes so no data leaks between accounts.
void resetUserScopedProviders(WidgetRef ref) {
  ref.invalidate(profileControllerProvider);
  ref.invalidate(postsStreamProvider);
  ref.invalidate(myPostsProvider);
  ref.invalidate(savedItemsProvider);
  ref.invalidate(conversationsStreamProvider);
  ref.invalidate(notificationsControllerProvider);
  ref.invalidate(privacySettingsProvider);
  ref.invalidate(blockedUsersProvider);
  ref.invalidate(notificationSettingsProvider);
  ref.invalidate(verificationProvider);
}

class FinderApp extends ConsumerWidget {
  const FinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      final wasSignedIn = previous?.isSignedIn ?? false;
      final userChanged = previous?.userId != next.userId;

      if (userChanged) resetUserScopedProviders(ref);

      // A signed-in session ended (logout or expired token): throw away
      // every pushed screen and land on onboarding.
      if (wasSignedIn && next.status == AuthStatus.unauthenticated) {
        final nav = rootNavigatorKey.currentState;
        if (nav == null) return;
        nav.pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
        final failure = next.failure;
        if (failure != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctx = rootNavigatorKey.currentContext;
            if (ctx != null) ActionFeedback.showInfo(ctx, failure.message);
          });
        }
      }
    });

    return MaterialApp(
      title: 'Finder',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      themeMode: mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: _AuthGate(state: authState),
    );
  }
}

class _AuthGate extends StatelessWidget {
  final AuthState state;

  const _AuthGate({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AuthStatus.loading:
        return const Scaffold(body: LoadingWidget());
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unverified:
        return const EmailVerificationScreen();
      case AuthStatus.unauthenticated:
        return const OnboardingScreen();
    }
  }
}
