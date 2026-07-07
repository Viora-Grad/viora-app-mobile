import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/appointments/data/models/reserved_appointment_model.dart';

void main() {
  test('fromJson handles missing fields with defaults and null-empty normalization', () {
    final json = {
      // missing many optional fields
      'appointmentId': 'a1',
      'serviceId': 's1',
      'staffId': 'st1',
      'branchId': 'b1',
      'reservationDate': '2024-07-06T09:00:00Z',
      'paymentMethod': 'Card',
      'status': 'NotArrived',
      'estimatedDuration': '01:00:00',
      'staffName': '', // should normalize to null
    };

    final model = ReservedAppointmentModel.fromJson(json);

    expect(model.appointmentId, equals('a1'));
    expect(model.staffName, isNull);
    final entity = model.toEntity();
    expect(entity.estimatedDuration.inMinutes, equals(60));
  });

  test('toEntity parses malformed estimatedDuration safely', () {
    final json = {'estimatedDuration': 'bad'};
    final model = ReservedAppointmentModel.fromJson(json);
    final entity = model.toEntity();
    expect(entity.estimatedDuration, isA<Duration>());
  });
}
