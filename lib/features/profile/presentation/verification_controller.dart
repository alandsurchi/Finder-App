import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/result.dart';
import '../domain/verification_status.dart';
import 'profile_controller.dart';

/// Identity verification status and submission.
class VerificationController extends StateNotifier<AsyncValue<VerificationStatus>> {
  final Ref ref;

  VerificationController(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    final result = await ref.read(profileRepositoryProvider).getVerificationStatus();
    if (!mounted) return;
    state = result.fold(
      onSuccess: (s) => AsyncValue.data(s),
      onFailure: (f) => AsyncValue.error(f, StackTrace.current),
    );
  }

  Future<Result<VerificationStatus>> submit(VerificationRequest request) async {
    final result = await ref.read(profileRepositoryProvider).submitVerification(request);
    if (!mounted) return result;
    result.fold(
      onSuccess: (s) {
        state = AsyncValue.data(s);
        if (s.isApproved) ref.read(profileControllerProvider.notifier).loadProfile();
      },
      onFailure: (_) {},
    );
    return result;
  }
}

final verificationProvider =
    StateNotifierProvider<VerificationController, AsyncValue<VerificationStatus>>(
  (ref) => VerificationController(ref),
);
