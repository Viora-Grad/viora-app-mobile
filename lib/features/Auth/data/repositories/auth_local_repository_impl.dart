import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/data/models/user_model.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_local_repository.dart';

// Brief: This is the implementation of the AuthLocalRepository,
// which interacts with the AuthLocalDataSource to perform local data operations
// such as saving and retrieving user tokens and data.
// It also handles exceptions and converts them to Failure objects
// for better error handling in the domain layer.

class AuthLocalRepositoryImpl implements AuthLocalRepository {
  final AuthLocalDataSource localDataSource;

  AuthLocalRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, void>> clearUser() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearUserToken() async {
    try {
      await localDataSource.clearUserToken();
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, String?>> getUserToken() async {
    try {
      final token = await localDataSource.getUserToken();
      return Right(token);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      await localDataSource.saveUser(UserModel.fromEntity(user));
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserToken(String token) async {
    try {
      await localDataSource.saveUserToken(token);
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
