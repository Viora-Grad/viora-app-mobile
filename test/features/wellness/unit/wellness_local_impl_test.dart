import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/features/wellness/data/wellness_local_impl.dart';
import 'package:viora_app/features/wellness/domain/sleep_entry.dart';
import 'package:viora_app/core/database/cache/cache_helper.dart';

/// Educational unit tests for `WellnessLocalImpl`.
///
/// This file demonstrates common testing utilities:
/// - `group`: groups related tests for clearer output and setup/teardown.
/// - `test`: defines a single, focused unit test.
/// - `expect`: asserts expected values or behaviors.
/// - `setUp`: shared test setup run before each test.
/// - `mocktail` (`Mock` + `when`/`verify`): used to replace `CacheHelper`
///   with a lightweight mock so we can control persistence behavior.

class MockCacheHelper extends Mock implements CacheHelper {}

void main() {
  group('WellnessLocalImpl - sleep entries', () {
    late MockCacheHelper mockCache;
    late WellnessLocalImpl subject;

    setUp(() {
      mockCache = MockCacheHelper();
      subject = WellnessLocalImpl(mockCache);
    });

    test('addSleepEntry places newest first and caps to maxSleepEntries', () async {
      // Existing cached entries (oldest-to-newest in storage but WellnessLocal
      // returns them as stored list where we treat first element as newest).
      final existing = List.generate(
        2,
        (i) => SleepEntry(
          id: 'old_$i',
          bedtime: DateTime(2024, 1, 1, 22, i),
          wakeTime: DateTime(2024, 1, 2, 6, i),
        ),
      );

      // Mock cache to return previous entries as JSON strings.
      when(() => mockCache.getData(any())).thenAnswer(
        (_) async => existing.map((e) => jsonEncode(e.toJson())).toList(),
      );
      when(() => mockCache.saveData(any(), any())).thenAnswer((_) async {});

      final newEntry = SleepEntry(
        id: 'new',
        bedtime: DateTime(2024, 1, 3, 23, 0),
        wakeTime: DateTime(2024, 1, 4, 7, 0),
      );

      final result = await subject.addSleepEntry(newEntry);

      // Newest should be first.
      expect(result.first.id, equals('new'));

      // If we add many entries the implementation will cap at maxSleepEntries.
      // Simulate by preparing a large list and ensuring logic trims it.
      final many = List.generate(WellnessLocalImpl.maxSleepEntries + 5, (i) {
        return SleepEntry(
          id: 'e_$i',
          bedtime: DateTime(2024, 1, 1, i % 24),
          wakeTime: DateTime(2024, 1, 1, (i % 24) + 8),
        );
      });

      when(() => mockCache.getData(any())).thenAnswer(
        (_) async => many.map((e) => jsonEncode(e.toJson())).toList(),
      );

      // Adding one more should result in returned list length == maxSleepEntries
      final added = await subject.addSleepEntry(newEntry);
      expect(added.length, equals(WellnessLocalImpl.maxSleepEntries));
    });
  });
}
