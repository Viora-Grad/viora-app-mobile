import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viora_app/core/database/cache/cache_helper.dart';
import 'package:viora_app/core/errors/exceptions.dart';

void main() {
  late CacheHelperImpl cacheHelper;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    cacheHelper = CacheHelperImpl(prefs);
  });

  group('CacheHelperImpl - containsKey', () {
    test('returns false when key does not exist', () async {
      final result = await cacheHelper.containsKey('missing_key');
      expect(result, false);
    });

    test('returns true after saving a value', () async {
      await cacheHelper.saveData('my_key', 'value');
      final result = await cacheHelper.containsKey('my_key');
      expect(result, true);
    });
  });

  group('CacheHelperImpl - saveData & getData', () {
    test('saves and retrieves a String', () async {
      await cacheHelper.saveData('token', 'abc123');
      final result = await cacheHelper.getData('token');
      expect(result, 'abc123');
    });

    test('saves and retrieves an int', () async {
      await cacheHelper.saveData('count', 42);
      final result = await cacheHelper.getData('count');
      expect(result, 42);
    });

    test('saves and retrieves a bool', () async {
      await cacheHelper.saveData('isLoggedIn', true);
      final result = await cacheHelper.getData('isLoggedIn');
      expect(result, true);
    });

    test('saves and retrieves a double', () async {
      await cacheHelper.saveData('score', 9.5);
      final result = await cacheHelper.getData('score');
      expect(result, 9.5);
    });

    test('saves and retrieves a List<String>', () async {
      await cacheHelper.saveData('tags', ['flutter', 'dart']);
      final result = await cacheHelper.getData('tags');
      expect(result, ['flutter', 'dart']);
    });

    test('getData returns null for missing key', () async {
      final result = await cacheHelper.getData('nonexistent');
      expect(result, isNull);
    });
  });

  group('CacheHelperImpl - patchData', () {
    test('patches an existing String value', () async {
      await cacheHelper.saveData('name', 'Alice');
      await cacheHelper.patchData('name', 'Bob');
      final result = await cacheHelper.getData('name');
      expect(result, 'Bob');
    });

    test('throws CacheException when key does not exist', () async {
      expect(
        () async => await cacheHelper.patchData('ghost', 'value'),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('CacheHelperImpl - deleteData', () {
    test('deletes an existing key', () async {
      await cacheHelper.saveData('temp', 'data');
      await cacheHelper.deleteData('temp');
      final result = await cacheHelper.containsKey('temp');
      expect(result, false);
    });
  });

  group('CacheHelperImpl - clearCache', () {
    test('clears all stored data', () async {
      await cacheHelper.saveData('a', 'val1');
      await cacheHelper.saveData('b', 'val2');
      await cacheHelper.clearCache();
      expect(await cacheHelper.containsKey('a'), false);
      expect(await cacheHelper.containsKey('b'), false);
    });
  });
}
