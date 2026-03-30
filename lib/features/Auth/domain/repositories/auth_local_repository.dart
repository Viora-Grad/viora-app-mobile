import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';

abstract class AuthLocalRepository {
  Future<Either<Failure, void>> saveUserToken(String token);

  Future<Either<Failure, String?>> getUserToken();

  Future<Either<Failure, void>> clearUserToken();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, void>> saveUser(User user);

  Future<Either<Failure, void>> clearUser();
}
