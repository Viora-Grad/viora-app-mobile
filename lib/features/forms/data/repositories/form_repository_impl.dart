import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/forms/data/datasources/remote/form_remote.dart';
import 'package:viora_app/features/forms/data/models/form_model.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';

class FormRepositoryImpl implements FormRepository {
  final FormRemoteDataSource remoteDataSource;

  FormRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, FormEntity?>> getServiceForm(String serviceId) async {
    try {
      final model = await remoteDataSource.getServiceForm(serviceId);
      if (model == null) return const Right(null);
      return Right(model.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> submitFormAnswers({
    required String appointmentId,
    required String formId,
    required List<AnswerData> answers,
  }) async {
    try {
      final answerModels = answers
          .map((a) => AnswerModel(id: a.id, type: a.type, answer: a.answer))
          .toList();

      final submissionId = await remoteDataSource.submitFormAnswers(
        appointmentId: appointmentId,
        formId: formId,
        answers: answerModels,
      );

      return Right(submissionId);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> uploadFormFile({
    required String formSubmissionId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      await remoteDataSource.uploadFormFile(
        formSubmissionId: formSubmissionId,
        filePath: filePath,
        fileName: fileName,
      );
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
