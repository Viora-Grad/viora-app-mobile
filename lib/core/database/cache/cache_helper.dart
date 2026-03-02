// TODO cache helper class to manage caching of api repsonse and data
// TODO in shared preferences or local storage db like sqflite
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
  static late SharedPreferences _sharedPrefernces;

  @override
  Future<bool> containsKey(String key) async {
    _sharedPrefernces = await SharedPreferences.getInstance();
    return _sharedPrefernces.containsKey(key);
  }

  @override
  Future<void> saveData(String key, dynamic data) async {
    _sharedPrefernces = await SharedPreferences.getInstance();
    if (data is String) {
      await _sharedPrefernces.setString(key, data);
    }
    if (data is int) {
      await _sharedPrefernces.setInt(key, data);
    }
    if (data is bool) {
      await _sharedPrefernces.setBool(key, data);
    }
    if (data is double) {
      await _sharedPrefernces.setDouble(key, data);
    }
    if (data is List<String>) {
      await _sharedPrefernces.setStringList(key, data);
    }
  }

  @override
  Future<dynamic> getData(String key) async {
    _sharedPrefernces = await SharedPreferences.getInstance();
    return _sharedPrefernces.get(key);
  }

  @override
  Future<void> patchData(String key, dynamic data) async {
    _sharedPrefernces = await SharedPreferences.getInstance();
    if (!_sharedPrefernces.containsKey(key)) {
      throw CacheException('Key $key does not exist in cache');
    }
    if (data is String) {
      await _sharedPrefernces.setString(key, data);
    }
    if (data is int) {
      await _sharedPrefernces.setInt(key, data);
    }
    if (data is bool) {
      await _sharedPrefernces.setBool(key, data);
    }
    if (data is double) {
      await _sharedPrefernces.setDouble(key, data);
    }
    if (data is List<String>) {
      await _sharedPrefernces.setStringList(key, data);
    }
  }

  @override
  Future<void> deleteData(String key) async {
    _sharedPrefernces = await SharedPreferences.getInstance();
    await _sharedPrefernces.remove(key);
  }

  @override
  Future<void> clearCache() async {
    _sharedPrefernces = await SharedPreferences.getInstance();
    await _sharedPrefernces.clear();
  }
}
