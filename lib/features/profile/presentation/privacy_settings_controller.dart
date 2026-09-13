import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/result.dart';
import '../domain/privacy_settings.dart';

typedef PrivacySettingsUpdate = PrivacySettings Function(PrivacySettings current);

/// Privacy toggles with optimistic updates and rollback on failure.
class PrivacySettingsController extends StateNotifier<AsyncValue<PrivacySettings>> {
  final Ref ref;

  PrivacySettingsController(this.ref) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getPrivacySettings();
    if (!mounted) return;
    state = result.fold(
      onSuccess: (settings) => AsyncValue.data(settings),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<Result<PrivacySettings>> updateSettings(PrivacySettings settings) async {
    final before = state.value;
    state = AsyncValue.data(settings);
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updatePrivacySettings(settings);
    if (!mounted) return result;
    result.fold(
      onSuccess: (updated) => state = AsyncValue.data(updated),
      onFailure: (_) {
        if (before != null) state = AsyncValue.data(before);
      },
    );
    return result;
  }
}

final privacySettingsProvider = StateNotifierProvider<PrivacySettingsController, AsyncValue<PrivacySettings>>(
  (ref) => PrivacySettingsController(ref),
);
