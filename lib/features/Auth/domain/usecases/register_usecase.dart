import 'package:dartz/dartz.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure, User>> call(RegisterParameters params) async {
    // Username validation
    if (params.userName.isEmpty) {
      return const Left(ValidationFailure('Username cannot be empty'));
    }

    // Email and password validation (same as login)
    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }
    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }
    if (params.password.length < 8) {
      return const Left(
        ValidationFailure('Password must be at least 8 characters long'),
      );
    }
    if (!RegExp(r'[A-Z]').hasMatch(params.password)) {
      return const Left(
        ValidationFailure(
          'Password must contain at least one uppercase letter',
        ),
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(params.password)) {
      return const Left(
        ValidationFailure(
          'Password must contain at least one lowercase letter',
        ),
      );
    }
    if (!RegExp(r'[0-9]').hasMatch(params.password)) {
      return const Left(
        ValidationFailure('Password must contain at least one number'),
      );
    }

    // Phone number validation
    if (params.phoneNumber.isEmpty) {
      return const Left(ValidationFailure('Phone number cannot be empty'));
    }
    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(params.phoneNumber)) {
      return const Left(ValidationFailure('Invalid phone number format'));
    }
    if (params.phoneNumber.length < 7 || params.phoneNumber.length > 15) {
      return const Left(
        ValidationFailure('Phone number must be between 7 and 15 digits'),
      );
    }

    // Age validation
    if (params.age < 13) {
      return const Left(
        ValidationFailure('You must be at least 13 years old to register'),
      );
    }
    if (!RegExp(r'^\d+$').hasMatch(params.age.toString())) {
      return const Left(ValidationFailure('Age must be a valid number'));
    }

    // Gender
    if (params.gender != Gender.male && params.gender != Gender.female) {
      return const Left(ValidationFailure('Invalid gender value'));
    }

    // Profile picture path validation (optional)
    if (params.profilePicturePath != null &&
        params.profilePicturePath!.trim().isEmpty) {
      return const Left(ValidationFailure('Invalid profile picture file path'));
    }

    return repository.register(params);
  }
}
