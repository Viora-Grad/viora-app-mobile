import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';

class BookAppointmentUseCase {
  final AppointmentRepository repository;

  BookAppointmentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String serviceId,
    required String staffId,
    required String branchId,
    required DateTime reservationDate,
    required int durationMinutes,
    required String paymentMethod,
  }) async {
    if (serviceId.isEmpty) {
      return const Left(ValidationFailure('Service ID is required'));
    }
    if (staffId.isEmpty) {
      return const Left(ValidationFailure('Doctor ID is required'));
    }
    if (branchId.isEmpty) {
      return const Left(ValidationFailure('Branch ID is required'));
    }
    if (paymentMethod.isEmpty) {
      return const Left(ValidationFailure('Payment method is required'));
    }

    return repository.createAppointment(
      serviceId: serviceId,
      staffId: staffId,
      branchId: branchId,
      reservationDate: reservationDate,
      durationMinutes: durationMinutes,
      paymentMethod: paymentMethod,
    );
  }
}
