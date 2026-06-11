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

  Future<void> sendPasswordResetCode({required String email});
  Future<void> verifyResetCode({required String email, required String code});
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<AuthUser> verifyEmail({required String code});
  Future<void> resendVerificationCode();
}



