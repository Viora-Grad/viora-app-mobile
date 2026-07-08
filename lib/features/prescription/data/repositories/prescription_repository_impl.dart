import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/prescription/data/datasources/remote/prescription_remote.dart';
import 'package:viora_app/features/prescription/domain/entities/prescription.dart';
import 'package:viora_app/features/prescription/domain/repositories/prescription_repository.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource remoteDataSource;

  PrescriptionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Prescription>> getPrescriptionByAppointment(
    String appointmentId,
  ) async {
    try {
      final model =
          await remoteDataSource.getPrescriptionByAppointment(appointmentId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
