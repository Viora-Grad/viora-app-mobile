import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';

abstract class MedicalRecordRepository {
  Future<Either<Failure, MedicalRecord>> getMedicalRecord();
  Future<Either<Failure, String>> createMedicalRecord({
    required int systolic,
    required int diastolic,
    required double weight,
    required int heartRate,
    required int bloodGlucose,
    required List<String> allergies,
  });
  Future<Either<Failure, void>> updateMedicalRecord({
    int? systolic,
    int? diastolic,
    double? weight,
    int? heartRate,
    int? bloodGlucose,
    List<String>? allergies,
  });
}
