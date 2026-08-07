import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> login(String email, String password);
  Future<Either<Failure, AppUser>> signUp(String email, String password, String name);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, AppUser?>> getCurrentUser();
}
