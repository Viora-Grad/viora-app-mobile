import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/wellness/domain/workout_reminder_settings.dart';

void main() {
  test('slots parsing from times strings including malformed entries', () {
    final settings = WorkoutReminderSettings(times: ['07:30', 'bad', '20:15']);
    final slots = settings.slots;

    // '07:30' -> hour 7, minute 30
    expect(slots[0].hour, equals(7));
    expect(slots[0].minute, equals(30));

    // 'bad' -> fallback hour 9, minute 0
    expect(slots[1].hour, equals(9));
    expect(slots[1].minute, equals(0));

    // '20:15' -> hour 20, minute 15
    expect(slots[2].hour, equals(20));
    expect(slots[2].minute, equals(15));
  });

  test('toJson/fromJson and copyWith behavior', () {
    final s = WorkoutReminderSettings(enabled: true, times: ['08:00']);
    final json = s.toJson();
    final restored = WorkoutReminderSettings.fromJson(json);

    expect(restored, equals(s));

    final changed = s.copyWith(enabled: false, times: ['10:00', '18:00']);
    expect(changed.enabled, isFalse);
    expect(changed.times.length, equals(2));
  });
}
