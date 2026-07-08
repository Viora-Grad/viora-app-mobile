import 'package:viora_app/features/Auth/data/models/user_model.dart';

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

  Future<void> saveUserName(String userName);
  Future<String?> getUserName();
  Future<void> clearUserName();

  Future<void> savePhoneNumber(String phoneNumber);
  Future<String?> getPhoneNumber();
  Future<void> clearPhoneNumber();
}
