import 'package:dio/dio.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/data/models/user_model.dart';

// Brief: This is the remote data source interface for auth remotely,
// which defines methods for logging in and registering users

abstract class AuthRemoteDataSource {
  Future<UserModel> login(LoginParameters params);

  Future<UserModel> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  });
}
