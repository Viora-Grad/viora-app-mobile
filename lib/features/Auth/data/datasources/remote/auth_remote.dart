import 'package:dio/dio.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(LoginParameters params);

  Future<UserModel> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  });
}
