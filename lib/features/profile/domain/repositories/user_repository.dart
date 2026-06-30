import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUserProfile();
  Future<Either<Failure, void>> deleteUserProfile(String userId);
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
