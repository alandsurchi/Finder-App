import '../errors/failure.dart';

class Result<T> {
  final T? data;
  final Failure? failure;

  const Result._(this.data, this.failure);

  bool get isSuccess => failure == null;

  factory Result.success(T data) => Result._(data, null);
  factory Result.failure(Failure failure) => Result._(null, failure);

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess(data as T);
    }
    return onFailure(failure as Failure);
  }

  Result<U> map<U>(U Function(T data) mapper) {
    if (isSuccess) {
      return Result.success(mapper(data as T));
    }
    return Result.failure(failure as Failure);
  }
}
