import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';

class CancelAppointmentUseCase {
  final AppointmentRepository repository;

  CancelAppointmentUseCase(this.repository);

  Future<Either<Failure, void>> call(String appointmentId) {
    return repository.cancelAppointment(appointmentId);
  }
}