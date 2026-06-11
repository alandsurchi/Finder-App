import '../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class SendPasswordReset {
  final AuthRepository repository;

  const SendPasswordReset(this.repository);

  Future<Result<void>> call({required String email}) {
    return repository.sendPasswordResetCode(email: email);
  }
}
