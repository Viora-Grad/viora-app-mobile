import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<User> call(LoginParameters params) async {
    if (params.email.isEmpty) {
      throw const ValidationException('Email cannot be empty');
    }
    if (params.password.isEmpty) {
      throw const ValidationException('Password cannot be empty');
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(params.email)) {
      throw const ValidationException('Invalid email format');
    }
    if (params.password.length < 8) {
      throw const ValidationException(
        'Password must be at least 8 characters long',
      );
    }
    if (!RegExp(r'[A-Z]').hasMatch(params.password)) {
      throw const ValidationException(
        'Password must contain at least one uppercase letter',
      );
    }
    if (!RegExp(r'[a-z]').hasMatch(params.password)) {
      throw const ValidationException(
        'Password must contain at least one lowercase letter',
      );
    }
    if (!RegExp(r'[0-9]').hasMatch(params.password)) {
      throw const ValidationException(
        'Password must contain at least one number',
      );
    }

    return await repository.login(params);
  }
}
