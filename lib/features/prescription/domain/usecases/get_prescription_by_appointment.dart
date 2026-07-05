import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/prescription/domain/entities/prescription.dart';
import 'package:viora_app/features/prescription/domain/repositories/prescription_repository.dart';

class GetPrescriptionByAppointment {
  final PrescriptionRepository repository;

  GetPrescriptionByAppointment(this.repository);

  Future<Either<Failure, Prescription>> call(String appointmentId) {
    return repository.getPrescriptionByAppointment(appointmentId);
  }
}
