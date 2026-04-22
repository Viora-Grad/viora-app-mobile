import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';
import 'package:viora_app/features/auth/domain/repositories/auth_repository.dart';

// Brief: This is the LoginUsecase, which is responsible for handling the login logic in the domain layer.
// It validates the input parameters and then calls the login method of the AuthRepository.
// It returns an Either<Failure, User> to handle success and failure cases explicitly,
// allowing the caller to manage errors effectively in the domain layer.

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, User>> call(LoginParameters params) async {
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

    return repository.login(params);
  }
}
