import 'package:dio/dio.dart';
import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/auth/data/models/user_model.dart';

// Brief: This is a dummy impl for the AuthRemoteDataSource,
// which simulates network calls with delays
// and returns mock user data based on the input parameters.
// It is useful for testing and development purposes
// without needing a real backend service.

class AuthRemoteDummyDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(LoginParameters params) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return UserModel(
      id: now.millisecondsSinceEpoch.toString(),
      userName: params.email.split('@').first,
      email: params.email,
      phoneNumber: '0000000000',
      gender: Gender.male,
      age: 18,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<UserModel> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    return UserModel(
      id: now.millisecondsSinceEpoch.toString(),
      userName: params.userName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      gender: params.gender,
      age: params.age,
      createdAt: now,
      updatedAt: now,
    );
  }
}
