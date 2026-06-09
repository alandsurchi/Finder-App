import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../domain/privacy_settings.dart';

class PrivacySettingsController extends StateNotifier<AsyncValue<PrivacySettings>> {
  final Ref ref;

  PrivacySettingsController(this.ref) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.getPrivacySettings();
    state = result.fold(
      onSuccess: (settings) => AsyncValue.data(settings),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }

  Future<void> updateSettings(PrivacySettings settings) async {
    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updatePrivacySettings(settings);
    state = result.fold(
      onSuccess: (updated) => AsyncValue.data(updated),
      onFailure: (failure) => AsyncValue.error(failure, StackTrace.current),
    );
  }
}

final privacySettingsProvider = StateNotifierProvider<PrivacySettingsController, AsyncValue<PrivacySettings>>(
  (ref) => PrivacySettingsController(ref),
);
