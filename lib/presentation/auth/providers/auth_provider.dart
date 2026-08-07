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
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await sl<LoginUseCase>()(email, password);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    final result = await sl<SignUpUseCase>()(email, password, name);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    await sl<SignOutUseCase>()();
    state = const AsyncValue.data(null);
  }
}
