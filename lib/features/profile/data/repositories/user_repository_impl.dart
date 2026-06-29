import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';
import 'package:viora_app/features/profile/data/datasources/remote/user_remote.dart';
import 'package:viora_app/features/profile/data/datasources/local/user_local.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemote userRemote;
  final UserLocal userLocal;

  UserRepositoryImpl(this.userRemote, this.userLocal);

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      final userModel = await userRemote.getUserProfile();
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserProfile(String userId) async {
    try {
      await userRemote.deleteUserProfile(userId);
      await userLocal.clearCachedUserProfile();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await userRemote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
