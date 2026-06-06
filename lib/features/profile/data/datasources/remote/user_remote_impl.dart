import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/features/profile/data/datasources/local/user_local.dart';
import 'package:viora_app/features/profile/data/datasources/remote/user_remote.dart';
import 'package:viora_app/features/profile/data/models/user_model.dart';
import 'package:viora_app/core/api/api_consumer.dart';

// Brief: This is the remote data source implementation for user profile,
// which defines methods for fetching, updating, and deleting user profile data from a remote server.

class UserRemoteImpl implements UserRemote {
  final ApiConsumer apiConsumer;
  final UserLocal userLocal;
  final String profileUrl = EndPoints.profileUrl;

  UserRemoteImpl(this.apiConsumer, this.userLocal);

  @override
  Future<UserModel> getUserProfile(String userId) async {
    final response = await apiConsumer.get(
      '$profileUrl/$userId',
      requiresAuth: true,
    );
    final userModel = UserModel.fromJson(response);
    // Cache the user profile locally
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
