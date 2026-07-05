import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';

class UploadFormFileUseCase {
  final FormRepository repository;

  UploadFormFileUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String formSubmissionId,
    required String filePath,
    required String fileName,
  }) async {
    if (formSubmissionId.isEmpty) {
      return const Left(ValidationFailure('Form submission ID is required'));
    }
    if (filePath.isEmpty) {
      return const Left(ValidationFailure('File path is required'));
    }

    return repository.uploadFormFile(
      formSubmissionId: formSubmissionId,
      filePath: filePath,
      fileName: fileName,
    );
  }
}
