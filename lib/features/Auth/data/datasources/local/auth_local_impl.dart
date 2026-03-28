import 'package:viora_app/features/Auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_local.dart';
import 'dart:convert';

class AuthLocalImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const tokenKey = 'user_token';
  static const userKey = 'user_data';

  AuthLocalImpl({required this.secureStorage});

  @override
  Future<String?> getUserToken() {
    return secureStorage.read(key: tokenKey);
  }

  @override
  Future<void> saveUserToken(String token) {
    return secureStorage.write(key: tokenKey, value: token);
  }

  @override
  Future<void> clearUserToken() {
    return secureStorage.delete(key: tokenKey);
  }

  @override
  Future<void> logout() {
    return Future.wait([
      clearUserToken(),
      secureStorage.delete(key: userKey),
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return secureStorage.read(key: userKey).then((userData) {
      return userData != null ? UserModel.fromJson(json.decode(userData)) : null;
    });
  }

  @override
  Future<void> saveUser(UserModel user) {
    return secureStorage.write(key: userKey, value: json.encode(user.toJson()));
  }
}
