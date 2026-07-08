import 'package:flutter_test/flutter_test.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';

void main() {
  test('endTime equals reservationDate + estimatedDuration', () {
    final start = DateTime(2024, 7, 6, 9, 0);
    final duration = const Duration(hours: 1, minutes: 30);
    final appt = ReservedAppointment(
      id: 'a1',
      serviceId: 's1',
      staffId: 'st1',
      branchId: 'b1',
      reservationDate: start,
      paymentMethod: 'Cash',
      status: 'Confirmed',
      estimatedDuration: duration,
    );

    expect(appt.endTime, equals(start.add(duration)));
  });

  test('equality considers key fields', () {
    final a = ReservedAppointment(
      id: 'id',
      serviceId: 's',
      staffId: 'st',
      branchId: 'b',
      reservationDate: DateTime(2024,7,6,9,0),
      paymentMethod: 'Cash',
      status: 'Confirmed',
      estimatedDuration: const Duration(minutes:30),
    );
    final b = ReservedAppointment(
      id: 'id',
      serviceId: 's',
      staffId: 'st',
      branchId: 'b',
      reservationDate: DateTime(2024,7,6,9,0),
      paymentMethod: 'Cash',
      status: 'Confirmed',
      estimatedDuration: const Duration(minutes:30),
    );

    expect(a, equals(b));
  });
}
