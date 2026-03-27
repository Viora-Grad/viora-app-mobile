import 'package:viora_app/core/params/user_parameters.dart';
import 'package:viora_app/features/Auth/domain/entities/user.dart';

abstract class Authrepository {
  Future<User> login(LoginParameters params);

  Future<User> register(RegisterParameters params);

  Future<void> logout();

  Future<User?> getCurrentUser();
}