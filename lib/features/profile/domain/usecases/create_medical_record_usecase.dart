import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/repositories/medical_record_repository.dart';

class CreateMedicalRecordUseCase {
  final MedicalRecordRepository repository;

  CreateMedicalRecordUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required int systolic,
    required int diastolic,
    required double weight,
    required int heartRate,
    required int bloodGlucose,
    required List<String> allergies,
  }) {
    return repository.createMedicalRecord(
      systolic: systolic,
      diastolic: diastolic,
      weight: weight,
      heartRate: heartRate,
      bloodGlucose: bloodGlucose,
      allergies: allergies,
    );
  }
}
