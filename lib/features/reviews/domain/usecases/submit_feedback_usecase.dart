import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/reviews/domain/repositories/review_repository.dart';

class SubmitFeedbackUseCase {
  final ReviewRepository repository;

  SubmitFeedbackUseCase(this.repository);

  Future<Either<Failure, void>> call(FeedbackParams params) {
    return repository.submitFeedback(params);
  }
}
