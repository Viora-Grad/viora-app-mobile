import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_staff_schedule.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late MockAppointmentRepository mockRepo;
  late GetDoctorDayShiftUseCase subject;

  setUp(() {
    mockRepo = MockAppointmentRepository();
    subject = GetDoctorDayShiftUseCase(mockRepo);
  });

  test('delegates to repository and returns schedule list', () async {
    final schedules = [
      StaffDaySchedule(id: '1', day: 'Mon', startTime: '08:00', endTime: '16:00')
    ];
    when(() => mockRepo.getStaffSchedule(any(), any())).thenAnswer((_) async => Right(schedules));

    final res = await subject.call(branchId: 'b', staffId: 's');
    expect(res.isRight(), isTrue);
    res.fold((_) {}, (r) => expect(r, equals(schedules)));
    verify(() => mockRepo.getStaffSchedule('b', 's')).called(1);
  });
}
