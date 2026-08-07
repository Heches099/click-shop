// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Failure {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Failure);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Failure()';
  }
}

/// @nodoc
class $FailureCopyWith<$Res> {
  $FailureCopyWith(Failure _, $Res Function(Failure) __);
}

/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ServerError value)? serverError,
    TResult Function(NetworkError value)? networkError,
    TResult Function(CacheError value)? cacheError,
    TResult Function(ValidationError value)? validationError,
    TResult Function(Unauthorized value)? unauthorized,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ServerError() when serverError != null:
        return serverError(_that);
      case NetworkError() when networkError != null:
        return networkError(_that);
      case CacheError() when cacheError != null:
        return cacheError(_that);
      case ValidationError() when validationError != null:
        return validationError(_that);
      case Unauthorized() when unauthorized != null:
        return unauthorized(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ServerError value) serverError,
    required TResult Function(NetworkError value) networkError,
    required TResult Function(CacheError value) cacheError,
    required TResult Function(ValidationError value) validationError,
    required TResult Function(Unauthorized value) unauthorized,
  }) {
    final _that = this;
    switch (_that) {
      case ServerError():
        return serverError(_that);
      case NetworkError():
        return networkError(_that);
      case CacheError():
        return cacheError(_that);
      case ValidationError():
        return validationError(_that);
      case Unauthorized():
        return unauthorized(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ServerError value)? serverError,
    TResult? Function(NetworkError value)? networkError,
    TResult? Function(CacheError value)? cacheError,
    TResult? Function(ValidationError value)? validationError,
    TResult? Function(Unauthorized value)? unauthorized,
  }) {
    final _that = this;
    switch (_that) {
      case ServerError() when serverError != null:
        return serverError(_that);
      case NetworkError() when networkError != null:
        return networkError(_that);
      case CacheError() when cacheError != null:
        return cacheError(_that);
      case ValidationError() when validationError != null:
        return validationError(_that);
      case Unauthorized() when unauthorized != null:
        return unauthorized(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String? message)? serverError,
    TResult Function()? networkError,
    TResult Function()? cacheError,
    TResult Function(String message)? validationError,
    TResult Function()? unauthorized,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case ServerError() when serverError != null:
        return serverError(_that.message);
      case NetworkError() when networkError != null:
        return networkError();
      case CacheError() when cacheError != null:
        return cacheError();
      case ValidationError() when validationError != null:
        return validationError(_that.message);
      case Unauthorized() when unauthorized != null:
        return unauthorized();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String? message) serverError,
    required TResult Function() networkError,
    required TResult Function() cacheError,
    required TResult Function(String message) validationError,
    required TResult Function() unauthorized,
  }) {
    final _that = this;
    switch (_that) {
      case ServerError():
        return serverError(_that.message);
      case NetworkError():
        return networkError();
      case CacheError():
        return cacheError();
      case ValidationError():
        return validationError(_that.message);
      case Unauthorized():
        return unauthorized();
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String? message)? serverError,
    TResult? Function()? networkError,
    TResult? Function()? cacheError,
    TResult? Function(String message)? validationError,
    TResult? Function()? unauthorized,
  }) {
    final _that = this;
    switch (_that) {
      case ServerError() when serverError != null:
        return serverError(_that.message);
      case NetworkError() when networkError != null:
        return networkError();
      case CacheError() when cacheError != null:
        return cacheError();
      case ValidationError() when validationError != null:
        return validationError(_that.message);
      case Unauthorized() when unauthorized != null:
        return unauthorized();
      case _:
        return null;
    }
  }
}

/// @nodoc

class ServerError implements Failure {
  const ServerError([this.message]);

  final String? message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ServerErrorCopyWith<ServerError> get copyWith =>
      _$ServerErrorCopyWithImpl<ServerError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ServerError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'Failure.serverError(message: $message)';
  }
}

/// @nodoc
abstract mixin class $ServerErrorCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory $ServerErrorCopyWith(
          ServerError value, $Res Function(ServerError) _then) =
      _$ServerErrorCopyWithImpl;
  @useResult
  $Res call({String? message});
}

/// @nodoc
class _$ServerErrorCopyWithImpl<$Res> implements $ServerErrorCopyWith<$Res> {
  _$ServerErrorCopyWithImpl(this._self, this._then);

  final ServerError _self;
  final $Res Function(ServerError) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = freezed,
  }) {
    return _then(ServerError(
      freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class NetworkError implements Failure {
  const NetworkError();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is NetworkError);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Failure.networkError()';
  }
}

/// @nodoc

class CacheError implements Failure {
  const CacheError();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CacheError);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Failure.cacheError()';
  }
}

/// @nodoc

class ValidationError implements Failure {
  const ValidationError(this.message);

  final String message;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ValidationErrorCopyWith<ValidationError> get copyWith =>
      _$ValidationErrorCopyWithImpl<ValidationError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ValidationError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'Failure.validationError(message: $message)';
  }
}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory $ValidationErrorCopyWith(
          ValidationError value, $Res Function(ValidationError) _then) =
      _$ValidationErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError _self;
  final $Res Function(ValidationError) _then;

  /// Create a copy of Failure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(ValidationError(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class Unauthorized implements Failure {
  const Unauthorized();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Unauthorized);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'Failure.unauthorized()';
  }
}

// dart format on
