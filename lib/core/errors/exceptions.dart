import 'failure.dart';

class AppException implements Exception {
  final String message;
  final FailureType type;
  final String? code;

  const AppException(
    this.message, {
    this.type = FailureType.unknown,
    this.code,
  });

  Failure toFailure() => Failure(message: message, type: type, code: code);

  @override
  String toString() => 'AppException(type: $type, code: $code, message: $message)';
}

class ValidationException extends AppException {
  const ValidationException(String message, {String? code})
      : super(message, type: FailureType.validation, code: code);
}

class NetworkException extends AppException {
  const NetworkException(String message, {String? code})
      : super(message, type: FailureType.network, code: code);
}

class AuthException extends AppException {
  const AuthException(String message, {String? code})
      : super(message, type: FailureType.auth, code: code);
}

class NotFoundException extends AppException {
  const NotFoundException(String message, {String? code})
      : super(message, type: FailureType.notFound, code: code);
}

class UnknownException extends AppException {
  const UnknownException(String message, {String? code})
      : super(message, type: FailureType.unknown, code: code);
}
