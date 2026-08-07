// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $NotifierProvider<Auth, AsyncValue<AppUser?>> {
  AuthProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AppUser?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AppUser?>>(value),
    );
  }
}

String _$authHash() => r'595419fbf59106e359de77ff1e7d6a134614a1c8';

abstract class _$Auth extends $Notifier<AsyncValue<AppUser?>> {
  AsyncValue<AppUser?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppUser?>, AsyncValue<AppUser?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AppUser?>, AsyncValue<AppUser?>>,
        AsyncValue<AppUser?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
