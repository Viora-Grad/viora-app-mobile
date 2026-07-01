import 'package:viora_app/features/profile/data/models/medical_record_model.dart';

abstract class MedicalRecordRemote {
  Future<MedicalRecordModel> getMedicalRecord();
  Future<String> createMedicalRecord({
    required int systolic,
    required int diastolic,
    required double weight,
    required int heartRate,
    required int bloodGlucose,
    required List<String> allergies,
  });
  Future<void> updateMedicalRecord({
    int? systolic,
    int? diastolic,
    double? weight,
    int? heartRate,
    int? bloodGlucose,
    List<String>? allergies,
  });
}
