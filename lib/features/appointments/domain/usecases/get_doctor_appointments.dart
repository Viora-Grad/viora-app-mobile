import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetDoctorAppointmentsUseCase {
  final AppointmentRepository repository;

  GetDoctorAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<ReservedAppointment>>> call({
    required String doctorId,
    required DateTime date,
  }) async {
    return repository.getDoctorAppointments(doctorId, date);
  }
}
