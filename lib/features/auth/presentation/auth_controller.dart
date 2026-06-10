import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/app_providers.dart';
import '../../../core/utils/result.dart';
import 'auth_state_provider.dart';

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncValue.data(null));

  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(loginUserProvider);
    final result = await usecase(email: email, password: password);
    return result.fold(
      onSuccess: (user) {
        ref.read(authStateProvider.notifier).setAuthenticated(user.id);
        state = const AsyncValue.data(null);
        return Result.success(null);
      },
      onFailure: (failure) {
        ref.read(authStateProvider.notifier).setUnauthenticated(failure);
        state = AsyncValue.error(failure, StackTrace.current);
        return Result.failure(failure);
      },
    );
  }

  Future<Result<void>> signup({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    final usecase = ref.read(signupUserProvider);
    final result = await usecase(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    return result.fold(
      onSuccess: (user) {
        ref.read(authStateProvider.notifier).setAuthenticated(user.id);
        state = const AsyncValue.data(null);
        return Result.success(null);
      },
      onFailure: (failure) {
        ref.read(authStateProvider.notifier).setUnauthenticated(failure);
        state = AsyncValue.error(failure, StackTrace.current);
        return Result.failure(failure);
      },
    );
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.read(authStateProvider.notifier).setUnauthenticated();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);
