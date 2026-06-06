import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';

// Brief: This is the UserRepository interface, which defines the contract for
// the user repository. It includes methods for getting, updating, and deleting user profiles.

abstract class UserRepository {
  Future<Either<Failure, User>> getUserProfile(String userId);
  Future<Either<Failure, User>> updateUserProfile(User user);
  Future<Either<Failure, void>> deleteUserProfile(String userId);
}
