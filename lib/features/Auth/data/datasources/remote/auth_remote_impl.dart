import 'package:viora_app/core/api/dio_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/Auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioConsumer dioConsumer;

  AuthRemoteDataSourceImpl(this.dioConsumer);

  @override
  Future<UserModel> login(LoginParameters params) async {
    final response = await dioConsumer.post(
      EndPoints.loginUrl,
      data: {'email': params.email, 'password': params.password},
    );
    return UserModel.fromJson(response);
  }

  @override
  Future<UserModel> register(RegisterParameters params) async {
    final response = await dioConsumer.post(
      EndPoints.registerUrl,
      data: {
        'email': params.email,
        'password': params.password,
        'name': params.userName,
        'phone': params.phoneNumber,
        'gender': params.gender.name,
        'age': params.age,
        'profilePictureUrl': params.profilePictureUrl,
      },
    );
    return UserModel.fromJson(response);
  }
}
