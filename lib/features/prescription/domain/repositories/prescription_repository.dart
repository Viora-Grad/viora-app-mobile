import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/prescription/domain/entities/prescription.dart';

abstract class PrescriptionRepository {
  Future<Either<Failure, Prescription>> getPrescriptionByAppointment(
    String appointmentId,
  );
}
