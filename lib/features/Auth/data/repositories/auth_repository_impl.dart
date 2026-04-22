import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';
import 'package:viora_app/features/auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';

// Brief: This is the implementation of the AuthRepository,
// which serves as the main data repository for authentication-related operations.
// It interacts with both the AuthRemoteDataSource for network calls
// and the AuthLocalDataSource for local data management.
// It also handles exceptions and converts them to Failure objects
// for better error handling in the domain layer.

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, User>> login(LoginParameters params) async {
    try {
      final userModel = await remoteDataSource.login(params);
      await localDataSource.saveUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        params,
        cancelToken: cancelToken,
      );
      await localDataSource.saveUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
