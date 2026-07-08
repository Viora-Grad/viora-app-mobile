import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/features/wellness/data/wellness_local_impl.dart';
import 'package:viora_app/core/database/cache/cache_helper.dart';

/// Educational tests showing how to mock simple read/write cache behavior
/// and assert correct timestamp conversions.

class MockCacheHelper extends Mock implements CacheHelper {}

void main() {
  late MockCacheHelper mockCache;
  late WellnessLocalImpl subject;

  setUp(() {
    mockCache = MockCacheHelper();
    subject = WellnessLocalImpl(mockCache);
  });

  test('setLastBackgrounded saves milliseconds and getLastBackgrounded reads it', () async {
    final time = DateTime(2024, 5, 1, 12, 34);

    when(() => mockCache.saveData(any(), any())).thenAnswer((_) async {});
    when(() => mockCache.getData(any())).thenAnswer((_) async => time.millisecondsSinceEpoch);

    await subject.setLastBackgrounded(time);

    verify(() => mockCache.saveData('wellness_last_backgrounded_ms', time.millisecondsSinceEpoch)).called(1);

    final read = await subject.getLastBackgrounded();
    expect(read, equals(time));
  });

  test('setAwakeMarker(null) deletes the awake marker from cache', () async {
    when(() => mockCache.deleteData(any())).thenAnswer((_) async {});

    await subject.setAwakeMarker(null);

    verify(() => mockCache.deleteData('wellness_awake_marker_ms')).called(1);
  });
}
