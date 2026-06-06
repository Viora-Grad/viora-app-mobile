import 'package:viora_app/features/profile/data/models/user_model.dart';

abstract class UserRemote {
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel?> updateUserProfile(UserModel user);
  Future<void> deleteUserProfile(String userId);
}
