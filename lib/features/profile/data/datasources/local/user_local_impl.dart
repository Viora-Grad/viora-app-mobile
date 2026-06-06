import 'dart:convert';
import 'package:viora_app/core/database/cache/cache_helper.dart';
import 'package:viora_app/features/profile/data/datasources/local/user_local.dart';
import 'package:viora_app/features/profile/data/models/user_model.dart';
import 'package:viora_app/features/profile/domain/entities/user.dart';

// Brief: This impl of UserLocalDataSource uses CacheHelper
// to persist user profile data locally on the device.

class UserLocalImpl implements UserLocal {
  static const String cachedUserProfileKey = 'CachedUserProfile';
  final CacheHelper cacheHelper;

  UserLocalImpl(this.cacheHelper);

  @override
  Future<void> cacheUserProfile(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    // Store the JSON string in cache
    // Btw we save it as UserModel's JSON, not User's JSON.
    // Why? cuz we cache the response from the server.
    // Why? cuz i think this is better.
    await cacheHelper.saveData(cachedUserProfileKey, jsonString);
  }

  @override
  Future<User?> getCachedUserProfile() async {
    final data = await cacheHelper.getData(cachedUserProfileKey);
    if (data == null) return null;

    try {
      if (data is String) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        // We return it as an entity because the repository should work with entities, not models
        return UserModel.fromJson(map).toEntity();
      }

      if (data is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(data)).toEntity();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  @override
  Future<void> clearCachedUserProfile() async {
    await cacheHelper.deleteData(cachedUserProfileKey);
  }
}
