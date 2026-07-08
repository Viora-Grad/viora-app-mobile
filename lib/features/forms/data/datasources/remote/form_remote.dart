import 'package:viora_app/features/forms/data/models/form_model.dart';

abstract class FormRemoteDataSource {
  Future<FormModel?> getServiceForm(String serviceId);

  Future<String> submitFormAnswers({
    required String appointmentId,
    required String formId,
    required List<AnswerModel> answers,
  });

  Future<void> uploadFormFile({
    required String formSubmissionId,
    required String filePath,
    required String fileName,
  });
}
