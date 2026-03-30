import 'package:viora_app/core/enums/gender.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/Auth/data/models/user_model.dart';

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
  Future<UserModel> register(RegisterParameters params) async {
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
      profilePictureUrl: params.profilePicturePath,
    );
  }
}
