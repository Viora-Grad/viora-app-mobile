import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_repository.dart';

// Brief: This is the RegisterUsecase, which is responsible for handling the registration
// logic in the domain layer. It validates the input parameters and then calls the register method of the AuthRepository.
// It returns an Either<Failure, User> to handle success and failure cases explicitly,
// allowing the caller to manage errors effectively in the domain layer.

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure, User>> call(
    RegisterParameters params, {
    CancelToken? cancelToken,
  }) async {
    if (params.userName.isEmpty) {
      return const Left(ValidationFailure('Username cannot be empty'));
    }

    if (params.email.isEmpty) {
      return const Left(ValidationFailure('Email cannot be empty'));
    }

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(params.email)) {
      return const Left(ValidationFailure('Invalid email format'));
    }

    if (params.password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
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

    if (params.phoneNumber.isEmpty) {
      return const Left(ValidationFailure('Phone number cannot be empty'));
    }

    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(params.phoneNumber)) {
      return const Left(ValidationFailure('Invalid phone number format'));
    }

    if (params.age < 13) {
      return const Left(
        ValidationFailure('You must be at least 13 years old to register'),
      );
    }

    if (!RegExp(r'^\d+$').hasMatch(params.age.toString())) {
      return const Left(ValidationFailure('Age must be a valid number'));
    }

    if (params.gender != Gender.male && params.gender != Gender.female) {
      return const Left(ValidationFailure('Invalid gender value'));
    }

    return repository.register(params, cancelToken: cancelToken);
  }
}
