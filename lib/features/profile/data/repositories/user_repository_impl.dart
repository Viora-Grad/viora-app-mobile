import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';
import 'package:viora_app/features/profile/data/datasources/remote/user_remote.dart';
import 'package:viora_app/features/profile/data/datasources/local/user_local.dart';
import 'package:viora_app/features/profile/data/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemote userRemote;
  final UserLocal userLocal;

  UserRepositoryImpl(this.userRemote, this.userLocal);

  @override
  Future<Either<Failure, User>> getUserProfile(String userId) async {
    try {
      final userModel = await userRemote.getUserProfile(userId);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(User user) async {
    try {
      final cachedUser = await userLocal.getCachedUserProfile();
      if (cachedUser == null) {
        return Left(const CacheFailure('No cached user profile found'));
      }

      final cachedUserModel = UserModel.fromEntity(cachedUser);
      final mergedUserModel = UserModel(
        // Preserve the user ID from cache to ensure we update the correct profile
        id: cachedUserModel.id,
        // prefer updated domain name, otherwise keep cached backend userName
        userName: (user.name.isNotEmpty) ? user.name : cachedUserModel.userName,
        email: (user.email.isNotEmpty) ? user.email : cachedUserModel.email,
        avatarUrl: (user.profilePictureUrl.isNotEmpty)
            ? user.profilePictureUrl
            : cachedUserModel.avatarUrl,
        age: (user.age > 0) ? user.age : cachedUserModel.age,
        gender: (user.gender != Gender.unknown)
            ? user.gender
            : cachedUserModel.gender,
        contacts: (user.contacts.isNotEmpty)
            ? user.contacts
            : cachedUserModel.contacts,
        // preserve other backend-specific fields from cache when updating
        personalInfo: cachedUserModel.personalInfo,
        joinedAt: cachedUserModel.joinedAt,
        medicalRecordId: cachedUserModel.medicalRecordId,
        organizationsVisited: cachedUserModel.organizationsVisited,
      );

      final updatedUserModel = await userRemote.updateUserProfile(
        mergedUserModel,
      );
      if (updatedUserModel == null) {
        return Left(
          const ServerFailure('Failed to update user profile', statusCode: 500),
        );
      }

      await userLocal.cacheUserProfile(updatedUserModel);
      return Right(updatedUserModel.toEntity());
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
}
