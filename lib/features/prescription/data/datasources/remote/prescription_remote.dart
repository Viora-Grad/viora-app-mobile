import 'package:viora_app/features/prescription/data/models/prescription_model.dart';

abstract class PrescriptionRemoteDataSource {
  Future<PrescriptionModel> getPrescriptionByAppointment(
    String appointmentId,
  );
}
