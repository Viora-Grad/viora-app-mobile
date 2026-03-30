import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';
import 'package:viora_app/features/Auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/Auth/data/datasources/local/auth_local.dart';

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
  Future<Either<Failure, User>> register(RegisterParameters params) async {
    try {
      final userModel = await remoteDataSource.register(params);
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
