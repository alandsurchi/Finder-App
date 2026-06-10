import '../core/utils/result.dart';
import '../features/auth/domain/auth_user.dart';

abstract class AuthRepository {
  Future<Result<AuthUser>> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthUser>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  });

  Future<Result<AuthUser>> loginWithGoogle();

  Future<Result<void>> logout();
}
