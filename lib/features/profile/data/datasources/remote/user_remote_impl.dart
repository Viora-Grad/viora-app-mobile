import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/profile/data/datasources/local/user_local.dart';
import 'package:viora_app/features/profile/data/datasources/remote/user_remote.dart';
import 'package:viora_app/features/profile/data/models/user_model.dart';
import 'package:viora_app/core/api/api_consumer.dart';

class UserRemoteImpl implements UserRemote {
  final ApiConsumer apiConsumer;
  final UserLocal userLocal;
  final AuthLocalDataSource authLocalDataSource;
  final String profileUrl = EndPoints.profileUrl;

  UserRemoteImpl(this.apiConsumer, this.userLocal, this.authLocalDataSource);

  @override
  Future<UserModel> getUserProfile() async {
    final response = await apiConsumer.get(
      profileUrl,
      requiresAuth: true,
    );

    final storedUser = await authLocalDataSource.getCurrentUser();
    final userId = storedUser?.id ?? '';

    final userModel = UserModel.fromJson({
      'id': userId,
      ...response,
    });
    await userLocal.cacheUserProfile(userModel);
    return userModel;
  }

  @override
  Future<UserModel?> updateUserProfile(UserModel user) async {
    await apiConsumer.put(
      '$profileUrl/${user.id}',
      data: user.toJson(),
      requiresAuth: true,
    );
    // Update the cached user profile Locally
    await userLocal.cacheUserProfile(user);
    return user;
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    await apiConsumer.delete('$profileUrl/$userId', requiresAuth: true);
    // Clear the cached user profile locally
    await userLocal.clearCachedUserProfile();
  }
}
