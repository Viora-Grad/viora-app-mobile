import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetDoctorDayShiftUseCase {
  final AppointmentRepository repository;

  GetDoctorDayShiftUseCase(this.repository);

  Future<Either<Failure, List<StaffDaySchedule>>> call({
    required String branchId,
    required String staffId,
  }) async {
    return repository.getStaffSchedule(branchId, staffId);
  }
}
