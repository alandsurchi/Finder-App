import 'auth_service.dart';
import '../../features/auth/domain/auth_user.dart';

class MockAuthService implements AuthService {
  @override
  Future<AuthUser> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _fakeUser(email);
  }

  @override
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    return _fakeUser(email);
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    return _fakeUser('user@example.com');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendPasswordResetCode({required String email}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  AuthUser _fakeUser(String email) {

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final name = email.split('@').first;
    return AuthUser(id: id, email: email, displayName: name);
  }
}
