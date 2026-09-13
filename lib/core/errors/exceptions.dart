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

/// A non-2xx HTTP response. [message] is the server's `message` field when
/// present, otherwise a short generic description of the status.
class ApiException extends AppException {
  final int statusCode;

  ApiException(this.statusCode, String message)
      : super(message, type: _typeFor(statusCode), code: '$statusCode');

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  static FailureType _typeFor(int status) {
    if (status == 401) return FailureType.auth;
    if (status == 404) return FailureType.notFound;
    if (status == 400 || status == 409 || status == 422) {
      return FailureType.validation;
    }
    return FailureType.unknown;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Converts any thrown object into a [Failure] the UI can show.
/// Typed exceptions keep their message; anything else gets [fallback].
Failure failureFrom(Object error, {required String fallback}) {
  if (error is AppException) return error.toFailure();
  return Failure(message: fallback);
}
