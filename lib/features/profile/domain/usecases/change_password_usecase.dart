import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/repositories/user_repository.dart';

class ChangePasswordUseCase {
  final UserRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty) {
      return const Left(ValidationFailure('Current password is required'));
    }
    if (newPassword.isEmpty) {
      return const Left(ValidationFailure('New password is required'));
    }
    if (newPassword.length < 8) {
      return const Left(
        ValidationFailure('Password must be at least 8 characters long'),
      );
    }
    if (newPassword.length > 100) {
      return const Left(
        ValidationFailure('Password must not exceed 100 characters'),
      );
    }
    if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
      return const Left(
        ValidationFailure(
          'Password must contain at least one uppercase letter',
        ),
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(newPassword)) {
      return const Left(
        ValidationFailure(
          'Password must contain at least one lowercase letter',
        ),
      );
    }
    if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      return const Left(
        ValidationFailure('Password must contain at least one number'),
      );
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(newPassword)) {
      return const Left(
        ValidationFailure(
          'Password must contain at least one special character',
        ),
      );
    }
    if (currentPassword == newPassword) {
      return const Left(
        ValidationFailure('New password must be different from current password'),
      );
    }

    return repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
