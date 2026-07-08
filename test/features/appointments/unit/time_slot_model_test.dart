import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/appointments/data/models/time_slot_model.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_time_slot.dart';

void main() {
  test('fromJson parses ISO strings and toEntity converts correctly', () {
    final json = {
      'startTime': '2024-07-06T09:00:00Z',
      'endTime': '2024-07-06T09:30:00Z',
    };

    final model = TimeSlotModel.fromJson(json);
    final entity = model.toEntity();

    expect(entity, isA<ReservedTimeSlot>());
    expect(entity.startTime.toUtc().hour, equals(9));
  });
}
