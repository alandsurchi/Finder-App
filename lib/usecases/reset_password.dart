import '../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ResetPassword {
  final AuthRepository repository;

  const ResetPassword(this.repository);

  Future<Result<void>> call({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }
}
