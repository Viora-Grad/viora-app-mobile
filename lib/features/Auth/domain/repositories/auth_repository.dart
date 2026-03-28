import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(LoginParameters params);

  Future<User> register(RegisterParameters params);

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<void> saveUserToken(String token);

  Future<void> saveUser(User user);

  Future<String?> getUserToken();

  Future<void> clearUserToken();
}