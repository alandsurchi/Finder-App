enum FailureType { validation, network, auth, notFound, unknown }

class Failure {
  final String message;
  final FailureType type;
  final String? code;

  const Failure({
    required this.message,
    this.type = FailureType.unknown,
    this.code,
  });

  @override
  String toString() => 'Failure(type: $type, code: $code, message: $message)';
}
