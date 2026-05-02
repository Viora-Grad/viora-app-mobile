import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

// Brief: This is the AuthRepository interface, which serves as the main contract
// for authentication-related operations in the domain layer. It defines methods
// for logging in, registering, and logging out users. Each method returns an
// Either<Failure, T> to handle success and failure cases explicitly, allowing
// the caller to manage errors effectively in the domain layer.

abstract class AuthRepository {
  Future<Either<Failure, User>> login(LoginParameters params);

  Future<Either<Failure, User>> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, void>> logout();
}
