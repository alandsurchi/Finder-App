import '../core/utils/result.dart';
import '../features/auth/domain/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyEmail {
  final AuthRepository repository;

  const VerifyEmail(this.repository);

  Future<Result<AuthUser>> call({required String code}) {
    return repository.verifyEmail(code: code);
  }
}
