import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

// Brief: This is the AuthLocalRepository interface, which defines the contract
// for local data operations related to authentication, such as saving and retrieving user tokens and data. It returns Either<Failure, T> for better error handling
// in the domain layer, allowing the caller to handle success and failure cases explicitly.

abstract class AuthLocalRepository {
  Future<Either<Failure, void>> saveUserToken(String token);

  Future<Either<Failure, String?>> getUserToken();

  Future<Either<Failure, void>> clearUserToken();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, void>> saveUser(User user);

  Future<Either<Failure, void>> clearUser();
}
