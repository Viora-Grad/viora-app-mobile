import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';

void main() {
  test('formattedStart and formattedEnd produce zero-padded HH:mm', () {
    final start = DateTime(2024, 7, 6, 9, 5);
    final end = DateTime(2024, 7, 6, 10, 45);
    final slot = AvailableSlot(startTime: start, endTime: end);

    expect(slot.formattedStart, equals('09:05'));
    expect(slot.formattedEnd, equals('10:45'));
  });

  test('equality based on start and end times', () {
    final a = AvailableSlot(startTime: DateTime(2024,7,6,8,0), endTime: DateTime(2024,7,6,9,0));
    final b = AvailableSlot(startTime: DateTime(2024,7,6,8,0), endTime: DateTime(2024,7,6,9,0));
    expect(a, equals(b));
  });
}
