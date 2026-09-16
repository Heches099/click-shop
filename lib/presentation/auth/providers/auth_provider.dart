import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth_usecase.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  /// Guards against stale async auth tasks (restore-on-start, profile sync)
  /// clobbering the state after a newer sign-in/sign-out. Any explicit auth
  /// action bumps the epoch; in-flight tasks that captured an old epoch become
  /// no-ops instead of silently resurrecting a logged-out session.
  int _epoch = 0;

  @override
  AsyncValue<AppUser?> build() {
    _checkCurrentUser();
    return const AsyncValue.loading();
  }

  Future<void> _checkCurrentUser() async {
    final epoch = _epoch;
    final result = await sl<GetCurrentUserUseCase>()();
    if (epoch != _epoch) return;
    if (result.isRight()) {
      await _syncProfile(result.getOrElse(() => null), epoch);
    }
    if (epoch != _epoch) return;
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  /// Merges the backend /auth/me profile (the only trusted source of the
  /// owner flag) over the Firebase-local user. Non-fatal if unavailable.
  /// Retries a few times because the API JWT exchange right after sign-in is
  /// async and a cold backend can take longer than the bounded first attempt.
  Future<void> _syncProfile(AppUser? local, int epoch) async {
    if (local == null) return;
    for (var attempt = 0; attempt < 3; attempt++) {
      if (epoch != _epoch) return;
      try {
        final refreshed = await sl<RefreshProfileUseCase>()();
        if (epoch != _epoch) return;
        final done = refreshed.fold(
          (_) => false,
          (apiUser) {
            if (apiUser != null) state = AsyncValue.data(apiUser);
            return apiUser != null;
          },
        );
        if (done) return;
      } catch (_) {
        // Best-effort sync; keep retrying.
      }
      if (epoch != _epoch) return;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _applyUser(AppUser? user) async {
    _epoch++;
    state = AsyncValue.data(user);
    await _syncProfile(user, _epoch);
  }

  Future<void> login(String email, String password) async {
    final epoch = ++_epoch;
    state = const AsyncValue.loading();
    final result = await sl<LoginUseCase>()(email, password);
    if (epoch != _epoch) return;
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        _applyUser(user);
      },
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    final epoch = ++_epoch;
    state = const AsyncValue.loading();
    final result = await sl<SignUpUseCase>()(email, password, name);
    if (epoch != _epoch) return;
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        _applyUser(user);
      },
    );
  }

  Future<void> signInWithGoogle() async {
    final epoch = ++_epoch;
    state = const AsyncValue.loading();
    final result = await sl<GoogleSignInUseCase>()();
    if (epoch != _epoch) return;
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) {
        _applyUser(user);
      },
    );
  }

  Future<void> signOut() async {
    _epoch++;
    await sl<SignOutUseCase>()();
    state = const AsyncValue.data(null);
  }
}
