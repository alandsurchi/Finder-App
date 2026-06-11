import '../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class VerifyResetCode {
  final AuthRepository repository;

  const VerifyResetCode(this.repository);

  Future<Result<void>> call({required String email, required String code}) {
    return repository.verifyResetCode(email: email, code: code);
  }
}
