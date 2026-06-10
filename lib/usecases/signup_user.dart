import '../core/utils/result.dart';
import '../features/auth/domain/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  const SignupUser(this.repository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) {
    return repository.signUpWithEmailPassword(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }
}
