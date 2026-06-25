import 'package:viora_app/features/profile/data/models/user_model.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';

abstract class UserLocal {
  Future<void> cacheUserProfile(UserModel user);
  Future<User?> getCachedUserProfile();
  Future<void> clearCachedUserProfile();
}
