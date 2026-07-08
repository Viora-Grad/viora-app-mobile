import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/wellness/domain/water_reminder_settings.dart';

void main() {
  test('default slots computed with interval of 2 hours between 8 and 22', () {
    final settings = WaterReminderSettings();
    final slots = settings.slots;

    // Expected hours: 8,10,12,14,16,18,20,22 => 8 slots
    expect(slots.length, equals(8));
    expect(slots.first.hour, equals(8));
    expect(slots.last.hour, equals(22));
  });

  test('intervalHours <= 0 falls back to step 1 (every hour)', () {
    final settings = WaterReminderSettings(intervalHours: 0, startHour: 10, endHour: 12);
    final slots = settings.slots;

    // Hours: 10,11,12 => 3 slots
    expect(slots.length, equals(3));
    expect(slots.map((s) => s.hour).toList(), equals([10, 11, 12]));
  });

  test('toJson/fromJson and copyWith preserve values', () {
    final custom = WaterReminderSettings(enabled: true, intervalHours: 1, startHour: 6, endHour: 9);
    final json = custom.toJson();
    final restored = WaterReminderSettings.fromJson(json);

    expect(restored, equals(custom));

    final changed = custom.copyWith(intervalHours: 2);
    expect(changed.intervalHours, equals(2));
    expect(changed.enabled, equals(true));
  });
}
