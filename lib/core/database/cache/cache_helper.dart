import 'package:shared_preferences/shared_preferences.dart';
import 'package:viora_app/core/errors/exceptions.dart';

abstract class CacheHelper {
  Future<bool> containsKey(String key);
  Future<void> saveData(String key, dynamic data);
  Future<dynamic> getData(String key);
  Future<void> patchData(String key, dynamic data);
  Future<void> deleteData(String key);
  Future<void> clearCache();
}

class CacheHelperImpl implements CacheHelper {
  CacheHelperImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  Future<void> _saveValue(String key, dynamic data) async {
    if (data is String) {
      await sharedPreferences.setString(key, data);
      return;
    }
    if (data is int) {
      await sharedPreferences.setInt(key, data);
      return;
    }
    if (data is bool) {
      await sharedPreferences.setBool(key, data);
      return;
    }
    if (data is double) {
      await sharedPreferences.setDouble(key, data);
      return;
    }
    if (data is List<String>) {
      await sharedPreferences.setStringList(key, data);
      return;
    }

    throw CacheException('Unsupported cache type: ${data.runtimeType}');
  }

  @override
  Future<bool> containsKey(String key) async {
    return sharedPreferences.containsKey(key);
  }

  @override
  Future<void> saveData(String key, dynamic data) async {
    await _saveValue(key, data);
  }

  @override
  Future<dynamic> getData(String key) async {
    return sharedPreferences.get(key);
  }

  @override
  Future<void> patchData(String key, dynamic data) async {
    if (!sharedPreferences.containsKey(key)) {
      throw CacheException('Key $key does not exist in cache');
    }

    await _saveValue(key, data);
  }

  @override
  Future<void> deleteData(String key) async {
    await sharedPreferences.remove(key);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.clear();
  }
}
