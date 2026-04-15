import 'package:dio/dio.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer _apiConsumer;
  final AuthLocalDataSource _authLocalDataSource;

  AuthRemoteDataSourceImpl(this._apiConsumer, this._authLocalDataSource);

  @override
  Future<UserModel> login(LoginParameters params) async {
    final response = await _apiConsumer.post(
      EndPoints.loginUrl,
      data: {'email': params.email, 'password': params.password},
    );

    // Extract the token from the response and save it to local storage
    final token = response['token'];
    if (token != null) {
      await _authLocalDataSource.saveUserToken(token);
    }

    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> register(
    RegisterParameters params, {
    CancelToken? cancelToken,
  }) async {
    final data = <String, dynamic>{
      'email': params.email,
      'password': params.password,
      'name': params.userName,
      'phone': params.phoneNumber,
      'gender': params.gender.name,
      'age': params.age,
    };

    final hasProfilePicture =
        params.profilePicturePath != null &&
        params.profilePicturePath!.isNotEmpty;

    if (hasProfilePicture) {
      final imagePath = params.profilePicturePath!;
      final imageName = imagePath.split(RegExp(r'[/\\]')).last;
      data['profilePicture'] = await MultipartFile.fromFile(
        imagePath,
        filename: imageName,
      );
    }

    final response = await _apiConsumer.post(
      EndPoints.registerUrl,
      data: data,
      isFormData: hasProfilePicture,
      cancelToken: cancelToken,
    );
    return UserModel.fromJson(response);
  }
}
