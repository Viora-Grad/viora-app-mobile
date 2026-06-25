import 'package:viora_app/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserToken(String token);
  Future<String?> getUserToken();
  Future<void> clearUserToken();

  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearRefreshToken();

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> clearUser();

  Future<void> saveGoogleIdToken(String token);
  Future<String?> getGoogleIdToken();
  Future<void> clearGoogleIdToken();
}
