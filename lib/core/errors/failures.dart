import 'package:freezed_annotation/freezed_annotation.dart';
part 'failures.freezed.dart';

@freezed
class Failure with _$Failure {
  const factory Failure.serverError([String? message]) = ServerError;
  const factory Failure.networkError() = NetworkError;
  const factory Failure.cacheError() = CacheError;
  const factory Failure.validationError(String message) = ValidationError;
  const factory Failure.unauthorized() = Unauthorized;
}

/// Renders a user-friendly message for an error (usually a [Failure]).
String describeFailure(Object error) {
  if (error is Failure) {
    return error.when(
      serverError: (message) =>
          message ?? 'Something went wrong. Please try again.',
      networkError: () => 'Network error. Check your connection.',
      cacheError: () => 'Something went wrong. Please try again.',
      validationError: (message) => message,
      unauthorized: () => 'Please sign in again.',
    );
  }
  return error.toString();
}
