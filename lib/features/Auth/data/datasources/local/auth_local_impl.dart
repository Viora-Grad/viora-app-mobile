import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/auth/data/models/user_model.dart';

class AuthLocalImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const _tokenKey = 'user_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';
  static const _googleIdTokenKey = 'google_id_token';

  AuthLocalImpl({required this.secureStorage});

  @override
  Future<String?> getUserToken() {
    return secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> saveUserToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> clearUserToken() {
    return secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> clearRefreshToken() {
    return secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> saveGoogleIdToken(String token) async {
    await secureStorage.write(key: _googleIdTokenKey, value: token);
  }

  @override
  Future<String?> getGoogleIdToken() {
    return secureStorage.read(key: _googleIdTokenKey);
  }

  @override
  Future<void> clearGoogleIdToken() {
    return secureStorage.delete(key: _googleIdTokenKey);
  }

  @override
  Future<void> logout() async {
    await Future.wait([
      clearUserToken(),
      clearRefreshToken(),
      clearUser(),
      clearGoogleIdToken(),
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userData = await secureStorage.read(key: _userKey);
    if (userData == null) return null;

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
    await secureStorage.write(key: _userKey, value: encodedUser);
  }

  @override
  Future<void> clearUser() {
    return secureStorage.delete(key: _userKey);
  }
}
