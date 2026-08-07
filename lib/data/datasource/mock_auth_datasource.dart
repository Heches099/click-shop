import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  UserModel? _currentUser;

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      id: 'mock-${email.hashCode}',
      email: email,
      name: email.split('@').first,
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      id: 'mock-${email.hashCode}',
      email: email,
      name: name,
    );
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  String toString() => 'MockAuthRemoteDataSource';
}
