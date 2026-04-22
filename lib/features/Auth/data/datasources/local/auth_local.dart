import 'package:viora_app/features/auth/data/models/user_model.dart';

// Brief: This is the local data source interface for auth locally,
// which defines methods for saving and retrieving user tokens and data
// from secure storage. It abstracts away the details of how the data is stored,
// allowing for different implementations (e.g., using shared preferences)


abstract class AuthLocalDataSource {
  Future<void> saveUserToken(String token);

  Future<String?> getUserToken();

  Future<void> clearUserToken();

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Future<void> saveUser(UserModel user);

  Future<void> clearUser();
}
