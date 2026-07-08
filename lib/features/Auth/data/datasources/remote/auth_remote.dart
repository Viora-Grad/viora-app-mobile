import 'package:dio/dio.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/data/models/user_model.dart';

// Brief: This is the remote data source interface for auth remotely,
// which defines methods for logging in and registering users

abstract class AuthRemoteDataSource {
  Future<UserModel> login(LoginParameters params);

  Future<UserModel> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  });

  Future<UserModel> fetchCurrentUser();

  Future<UserModel> oauthRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String dateOfBirth,
    required String providerKey,
    String? userName,
    String? phoneNumber,
  });

  Future<void> forgetPassword(String email);

  Future<void> confirmForgetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<void> createCustomerProfile({
    String? userName,
    String? phoneNumber,
    String? email,
  });
}
