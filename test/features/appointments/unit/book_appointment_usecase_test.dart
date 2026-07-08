import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:viora_app/features/appointments/domain/usecases/book_appointment.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late MockAppointmentRepository mockRepo;
  late BookAppointmentUseCase subject;

  setUp(() {
    mockRepo = MockAppointmentRepository();
    subject = BookAppointmentUseCase(mockRepo);
  });

  test('validates required fields and returns failures', () async {
    var res = await subject.call(
      serviceId: '',
      staffId: 's',
      branchId: 'b',
      reservationDate: DateTime.now(),
      durationMinutes: 30,
      paymentMethod: 'Cash',
    );
    expect(res.isLeft(), isTrue);

    res = await subject.call(
      serviceId: 'sv',
      staffId: '',
      branchId: 'b',
      reservationDate: DateTime.now(),
      durationMinutes: 30,
      paymentMethod: 'Cash',
    );
    expect(res.isLeft(), isTrue);

    res = await subject.call(
      serviceId: 'sv',
      staffId: 's',
      branchId: '',
      reservationDate: DateTime.now(),
      durationMinutes: 30,
      paymentMethod: 'Cash',
    );
    expect(res.isLeft(), isTrue);

    res = await subject.call(
      serviceId: 'sv',
      staffId: 's',
      branchId: 'b',
      reservationDate: DateTime.now(),
      durationMinutes: 30,
      paymentMethod: '',
    );
    expect(res.isLeft(), isTrue);
  });

  test('delegates to repository when inputs valid', () async {
    when(() => mockRepo.createAppointment(
          serviceId: any(named: 'serviceId'),
          staffId: any(named: 'staffId'),
          branchId: any(named: 'branchId'),
          reservationDate: any(named: 'reservationDate'),
          durationMinutes: any(named: 'durationMinutes'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenAnswer((_) async => const Right('appt-1'));

    final res = await subject.call(
      serviceId: 'sv',
      staffId: 's',
      branchId: 'b',
      reservationDate: DateTime.now(),
      durationMinutes: 30,
      paymentMethod: 'Cash',
    );

    expect(res.isRight(), isTrue);
    res.fold((_) {}, (r) => expect(r, equals('appt-1')));
    verify(() => mockRepo.createAppointment(serviceId: 'sv', staffId: 's', branchId: 'b', reservationDate: any(named: 'reservationDate'), durationMinutes: 30, paymentMethod: 'Cash')).called(1);
  });
}
