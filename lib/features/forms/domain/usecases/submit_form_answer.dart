import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';

class SubmitFormAnswerUseCase {
  final FormRepository repository;

  SubmitFormAnswerUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String appointmentId,
    required String formId,
    required List<AnswerData> answers,
  }) async {
    if (appointmentId.isEmpty) {
      return const Left(ValidationFailure('Appointment ID is required'));
    }
    if (formId.isEmpty) {
      return const Left(ValidationFailure('Form ID is required'));
    }
    if (answers.isEmpty) {
      return const Left(ValidationFailure('Answers are required'));
    }

    return repository.submitFormAnswers(
      appointmentId: appointmentId,
      formId: formId,
      answers: answers,
    );
  }
}
