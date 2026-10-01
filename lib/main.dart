import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/home_tab_provider.dart';

import 'app/di/app_providers.dart';
import 'app/lifecycle/app_lifecycle_provider.dart';
import 'app/router/app_router.dart';
import 'app/router/root_navigator.dart';
import 'services/push/push_service.dart';
import 'app/deep_links.dart';
import 'services/push/local_alerts.dart';
import 'core/config/app_config.dart';
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
import 'l10n/kurdish_localizations.dart';
import 'l10n/l10n.dart';
import 'l10n/locale_controller.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'widgets/common/action_feedback.dart';
import 'widgets/state/loading_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configError = AppConfig.configurationError;
  if (configError != null) {
    runApp(_ConfigErrorApp(message: configError));
    return;
  }

  final apiClient = ApiClient();
  await apiClient.init();

  // The saved language must be known before the first frame so the app
  // never flashes English at an Arabic or Kurdish user.
  final savedLocale = await LocaleController.restore();
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
      localeControllerProvider.overrideWith(() => LocaleController(savedLocale)),
    ],
  );
  apiClient.onUnauthorized =
      () => container.read(authStateProvider.notifier).sessionExpired();

  _lifecycle = attachAppLifecycle(container);
  // Phone notifications. A missing Firebase config only disables push.
  await container.read(pushServiceProvider).init();
  // Shared links (https://…/p/<id>, finder://post/<id>) open the post.
  await container.read(deepLinksProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FinderApp(),
    ),
  );
}

/// Keeps the lifecycle listener alive for the whole process.
AppLifecycleListener? _lifecycle;

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
  ref.invalidate(homeTabProvider);
  ref.invalidate(createPrefillProvider);
}

class FinderApp extends ConsumerWidget {
  const FinderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final chosenLocale = ref.watch(localeControllerProvider);
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      final wasSignedIn = previous?.isSignedIn ?? false;
      final userChanged = previous?.userId != next.userId;

      if (userChanged) resetUserScopedProviders(ref);

      // Register this phone for push as soon as someone is signed in, and
      // open whatever notification launched the app.
      if (next.isSignedIn && !wasSignedIn) {
        final push = ref.read(pushServiceProvider);
        push.syncToken().then((_) => push.flushPendingOpen());
        ref.read(deepLinksProvider).flushPending();
        ref.read(localAlertsProvider).start();
      }

      // A signed-in session ended (logout or expired token): throw away
      // every pushed screen and land on onboarding.
      if (wasSignedIn && next.status == AuthStatus.unauthenticated) {
        ref.read(localAlertsProvider).reset();
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

    // Resolve now (not in the callback) so the first frame already uses the
    // right fonts when the phone itself is set to Arabic or Kurdish.
    final resolvedLocale =
        resolveLocale(chosenLocale, WidgetsBinding.instance.platformDispatcher.locales);
    // Strings built outside the widget tree (models, services) follow the
    // same language from this frame on.
    L10n.use(resolvedLocale);
    final arabic = AppTheme.usesArabicScript(resolvedLocale);
    return MaterialApp(
      title: 'Finder',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      themeMode: mode,
      theme: AppTheme.light(arabicScript: arabic),
      darkTheme: AppTheme.dark(arabicScript: arabic),
      locale: chosenLocale,
      supportedLocales: kSupportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...KurdishLocalizations.delegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (device, supported) {
        final resolved = resolveLocale(chosenLocale, device);
        L10n.use(resolved);
        return resolved;
      },
      onGenerateTitle: (context) => context.l10n.appName,
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

/// Shown instead of the app when a release build was made without API_URL.
class _ConfigErrorApp extends StatelessWidget {
  final String message;
  const _ConfigErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_suggest_outlined, size: 48),
                  const SizedBox(height: 16),
                  Text('This build is not configured',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
