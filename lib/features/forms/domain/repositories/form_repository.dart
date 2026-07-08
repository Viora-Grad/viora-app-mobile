import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';

abstract class FormRepository {
  Future<Either<Failure, FormEntity?>> getServiceForm(String serviceId);

  Future<Either<Failure, String>> submitFormAnswers({
    required String appointmentId,
    required String formId,
    required List<AnswerData> answers,
  });

  Future<Either<Failure, void>> uploadFormFile({
    required String formSubmissionId,
    required String filePath,
    required String fileName,
  });
}
