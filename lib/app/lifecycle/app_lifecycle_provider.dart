import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's foreground/background state, so pollers can pause while the
/// app is not visible. Updated from [attachAppLifecycle] in main().
final appLifecycleProvider =
    StateProvider<AppLifecycleState>((ref) => AppLifecycleState.resumed);

/// True while the app is on screen.
final appIsResumedProvider = Provider<bool>(
  (ref) => ref.watch(appLifecycleProvider) == AppLifecycleState.resumed,
);

/// Wires Flutter's lifecycle events into [appLifecycleProvider]. Keep the
/// returned listener alive for the life of the app.
AppLifecycleListener attachAppLifecycle(ProviderContainer container) {
  final initial = WidgetsBinding.instance.lifecycleState;
  if (initial != null) {
    container.read(appLifecycleProvider.notifier).state = initial;
  }
  return AppLifecycleListener(
    onStateChange: (state) =>
        container.read(appLifecycleProvider.notifier).state = state,
  );
}
