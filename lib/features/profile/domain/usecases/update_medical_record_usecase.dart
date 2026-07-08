import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/repositories/medical_record_repository.dart';

class UpdateMedicalRecordUseCase {
  final MedicalRecordRepository repository;

  UpdateMedicalRecordUseCase(this.repository);

  Future<Either<Failure, void>> call({
    int? systolic,
    int? diastolic,
    double? weight,
    int? heartRate,
    int? bloodGlucose,
    List<String>? allergies,
  }) {
    return repository.updateMedicalRecord(
      systolic: systolic,
      diastolic: diastolic,
      weight: weight,
      heartRate: heartRate,
      bloodGlucose: bloodGlucose,
      allergies: allergies,
    );
  }
}
