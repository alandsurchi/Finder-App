import '../../features/auth/domain/auth_user.dart';

abstract class AuthService {
  Future<AuthUser> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  });

  Future<AuthUser> loginWithGoogle();

  Future<void> logout();
}
