import '../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ResendVerification {
  final AuthRepository repository;

  const ResendVerification(this.repository);

  Future<Result<void>> call() {
    return repository.resendVerificationCode();
  }
}
