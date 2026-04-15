import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(LoginParameters params);

  Future<Either<Failure, User>> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, void>> logout();
}
