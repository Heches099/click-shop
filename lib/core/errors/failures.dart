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
