import 'package:viora_app/features/Auth/data/models/user_model.dart';
import 'package:viora_app/features/Auth/domain/repositories/auth_repository.dart';
import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';
import 'package:viora_app/features/Auth/data/datasources/remote/auth_remote.dart';
import 'package:viora_app/features/Auth/data/datasources/local/auth_local.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<User> login(LoginParameters params) async {
    final userModel = await remoteDataSource.login(params);

    await localDataSource.saveUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<User> register(RegisterParameters params) async {
    final userModel = await remoteDataSource.register(params);
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await localDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await localDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> saveUserToken(String token) async {
    await localDataSource.saveUserToken(token);
  }

  @override
  Future<void> saveUser(User user) async {
    await localDataSource.saveUser(UserModel.fromEntity(user));
  }

  @override
  Future<String?> getUserToken() async {
    return await localDataSource.getUserToken();
  }

  @override
  Future<void> clearUserToken() async {
    await localDataSource.clearUserToken();
  }
}
