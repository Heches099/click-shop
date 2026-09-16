import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth_usecase.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AsyncValue<AppUser?> build() {
    _checkCurrentUser();
    return const AsyncValue.loading();
  }

  Future<void> _checkCurrentUser() async {
    final result = await sl<GetCurrentUserUseCase>()();
    if (result.isRight()) {
      await _syncProfile(result.getOrElse(() => null));
    }
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  /// Merges the backend /auth/me profile (the only trusted source of the
  /// owner flag) over the Firebase-local user. Non-fatal if unavailable.
  Future<void> _syncProfile(AppUser? local) async {
    if (local == null) return;
    try {
      final refreshed = await sl<RefreshProfileUseCase>()();
      refreshed.fold(
        (_) {},
        (apiUser) {
          if (apiUser != null) state = AsyncValue.data(apiUser);
        },
      );
    } catch (_) {
      // Profile sync is best-effort; keep the local user.
    }
  }

  Future<void> _applyUser(AppUser? user) async {
    state = AsyncValue.data(user);
    await _syncProfile(user);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await sl<LoginUseCase>()(email, password);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        _applyUser(user);
      },
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    final result = await sl<SignUpUseCase>()(email, password, name);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        _applyUser(user);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await sl<GoogleSignInUseCase>()();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        _applyUser(user);
      },
    );
  }

  Future<void> signOut() async {
    await sl<SignOutUseCase>()();
    state = const AsyncValue.data(null);
  }
}
