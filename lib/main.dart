import 'package:flutter/material.dart';
import 'app/router/app_router.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'core/network/api_client.dart';
import 'app/di/app_providers.dart';
import 'features/auth/presentation/auth_state_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  final apiClient = ApiClient();
  await apiClient.init();

  runApp(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
      ],
      child: const FinderApp(),
    ),
  );
}

class FinderApp extends ConsumerWidget {
  const FinderApp({super.key});

  static const LinearGradient _pageBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1533), Color(0xFF123B6B), Color(0xFFEAF1F8)],
    stops: [0.0, 0.42, 1.0],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeControllerProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Finder',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) {
        final themedChild = Theme(
          data: Theme.of(
            context,
          ).copyWith(scaffoldBackgroundColor: Colors.transparent),
          child: child ?? const SizedBox.shrink(),
        );

        return DecoratedBox(
          decoration: const BoxDecoration(gradient: _pageBackgroundGradient),
          child: themedChild,
        );
      },
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
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const OnboardingScreen();
    }
  }
}
