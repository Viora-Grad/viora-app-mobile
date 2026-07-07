import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/wellness/domain/sleep_entry.dart';

void main() {
  test('duration when wakeTime is after bedtime (same day)', () {
    final bedtime = DateTime(2024, 6, 1, 22, 0);
    final wake = DateTime(2024, 6, 2, 6, 30);
    final entry = SleepEntry(id: '1', bedtime: bedtime, wakeTime: wake);

    expect(entry.duration.inHours, equals(8));
    expect(entry.duration.inMinutes, equals(8 * 60 + 30));
    expect(entry.durationHours, closeTo(8.5, 1e-9));
  });

  test('duration when wakeTime is before or equal to bedtime (crosses midnight)', () {
    final bedtime = DateTime(2024, 6, 2, 23, 30);
    // wakeTime earlier on the clock -> treated as next day
    final wake = DateTime(2024, 6, 2, 7, 0);
    final entry = SleepEntry(id: '2', bedtime: bedtime, wakeTime: wake);

    // bedtime 23:30 to 07:00 next day => 7.5 hours
    expect(entry.duration.inMinutes, equals(7 * 60 + 30));
    expect(entry.durationHours, closeTo(7.5, 1e-9));
  });

  test('toJson/fromJson roundtrip preserves values', () {
    final bedtime = DateTime.parse('2024-06-01T22:15:00Z');
    final wake = DateTime.parse('2024-06-02T06:45:00Z');
    final entry = SleepEntry(id: 'abc', bedtime: bedtime, wakeTime: wake);

    final json = entry.toJson();
    final restored = SleepEntry.fromJson(json);

    expect(restored, equals(entry));
  });
}
