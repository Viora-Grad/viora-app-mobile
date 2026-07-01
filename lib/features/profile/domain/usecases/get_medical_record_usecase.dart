import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';
import 'package:viora_app/features/profile/domain/repositories/medical_record_repository.dart';

class GetMedicalRecordUseCase {
  final MedicalRecordRepository repository;

  GetMedicalRecordUseCase(this.repository);

  Future<Either<Failure, MedicalRecord>> call() {
    return repository.getMedicalRecord();
  }
}
