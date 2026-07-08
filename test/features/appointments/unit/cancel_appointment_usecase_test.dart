import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:viora_app/features/appointments/domain/usecases/cancel_appointment.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late MockAppointmentRepository mockRepo;
  late CancelAppointmentUseCase subject;

  setUp(() {
    mockRepo = MockAppointmentRepository();
    subject = CancelAppointmentUseCase(mockRepo);
  });

  test('delegates cancel to repository', () async {
    when(() => mockRepo.cancelAppointment(any())).thenAnswer((_) async => const Right(null));

    final res = await subject.call('appt-1');
    expect(res.isRight(), isTrue);
    verify(() => mockRepo.cancelAppointment('appt-1')).called(1);
  });
}
