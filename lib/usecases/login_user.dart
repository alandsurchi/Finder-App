import '../core/utils/result.dart';
import '../features/auth/domain/auth_user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  const LoginUser(this.repository);

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) {
    return repository.loginWithEmailPassword(
      email: email,
      password: password,
    );
  }
}
