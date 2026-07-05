import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetUserAppointmentsUseCase {
  final AppointmentRepository repository;

  GetUserAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<ReservedAppointment>>> call({
    required String customerId,
    String? status,
  }) {
    return repository.getCustomerAppointments(
      customerId,
      status: status,
    );
  }
}
