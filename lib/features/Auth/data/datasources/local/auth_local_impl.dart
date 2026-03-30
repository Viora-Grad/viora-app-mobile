import 'package:viora_app/features/Auth/data/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/errors/exceptions.dart';
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
  Future<void> saveUserToken(String token) async {
    await secureStorage.write(key: tokenKey, value: token);
  }

  @override
  Future<void> clearUserToken() {
    return secureStorage.delete(key: tokenKey);
  }

  @override
  Future<void> logout() {
    return Future.wait([clearUserToken(), clearUser()]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userData = await secureStorage.read(key: userKey);
    if (userData == null) {
      return null;
    }

    try {
      final decoded = json.decode(userData);
      if (decoded is! Map<String, dynamic>) {
        await clearUser();
        throw const CacheException('Stored user data has invalid format');
      }
      return UserModel.fromJson(decoded);
    } on FormatException {
      await clearUser();
      throw const CacheException('Stored user data is corrupted');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final encodedUser = json.encode(user.toJson());
    await secureStorage.write(key: userKey, value: encodedUser);
  }

  @override
  Future<void> clearUser() {
    return secureStorage.delete(key: userKey);
  }
}
