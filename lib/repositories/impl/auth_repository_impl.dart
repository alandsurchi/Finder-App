import '../../l10n/l10n.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import '../../features/auth/domain/auth_user.dart';
import '../../services/auth/auth_service.dart';
import '../auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService service;

  const AuthRepositoryImpl({required this.service});

  @override
  Future<Result<AuthUser>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await service.loginWithEmailPassword(
        email: email,
        password: password,
      );
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableLogin));
    }
  }

  @override
  Future<Result<AuthUser>> loginWithGoogle() async {
    try {
      final user = await service.loginWithGoogle();
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableLoginGoogle));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await service.logout();
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableLogout));
    }
  }

  @override
  Future<Result<AuthUser>> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final user = await service.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableSignUp));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetCode({required String email}) async {
    try {
      await service.sendPasswordResetCode(email: email);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableSendResetCode));
    }
  }

  @override
  Future<Result<void>> verifyResetCode({required String email, required String code}) async {
    try {
      await service.verifyResetCode(email: email, code: code);
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableVerifyCode));
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await service.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableResetPassword));
    }
  }

  @override
  Future<Result<AuthUser>> verifyEmail({required String code}) async {
    try {
      final user = await service.verifyEmail(code: code);
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableVerifyEmail));
    }
  }

  @override
  Future<Result<void>> resendVerificationCode() async {
    try {
      await service.resendVerificationCode();
      return Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(Failure(message: L10n.current.repoUnableResendCode));
    }
  }
}



