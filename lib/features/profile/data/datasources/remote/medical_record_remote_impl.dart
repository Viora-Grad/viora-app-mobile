import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/features/profile/data/datasources/remote/medical_record_remote.dart';
import 'package:viora_app/features/profile/data/models/medical_record_model.dart';

class MedicalRecordRemoteImpl implements MedicalRecordRemote {
  final ApiConsumer apiConsumer;

  MedicalRecordRemoteImpl(this.apiConsumer);

  @override
  Future<MedicalRecordModel> getMedicalRecord() async {
    final response = await apiConsumer.get(
      EndPoints.medicalRecordUrl,
      requiresAuth: true,
    );
    return MedicalRecordModel.fromJson(response);
  }

  @override
  Future<String> createMedicalRecord({
    required int systolic,
    required int diastolic,
    required double weight,
    required int heartRate,
    required int bloodGlucose,
    required List<String> allergies,
  }) async {
    final response = await apiConsumer.post(
      EndPoints.medicalRecordUrl,
      data: {
        'systolic': systolic,
        'diastolic': diastolic,
        'weight': weight,
        'heartRate': heartRate,
        'bloodGlucose': bloodGlucose,
        'allergies': allergies,
      },
      requiresAuth: true,
    );
    return response['id']?.toString() ?? response.toString();
  }

  @override
  Future<void> updateMedicalRecord({
    int? systolic,
    int? diastolic,
    double? weight,
    int? heartRate,
    int? bloodGlucose,
    List<String>? allergies,
  }) async {
    final data = <String, dynamic>{};
    if (systolic != null) data['systolic'] = systolic;
    if (diastolic != null) data['diastolic'] = diastolic;
    if (weight != null) data['weight'] = weight;
    if (heartRate != null) data['heartRate'] = heartRate;
    if (bloodGlucose != null) data['bloodGlucose'] = bloodGlucose;
    if (allergies != null) data['allergies'] = allergies;

    await apiConsumer.patch(
      EndPoints.medicalRecordUrl,
      data: data,
      requiresAuth: true,
    );
  }
}
