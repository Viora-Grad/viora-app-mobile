import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';
import 'package:viora_app/features/reviews/domain/repositories/review_repository.dart';

class CheckUserFeedbackUseCase {
  final ReviewRepository repository;

  CheckUserFeedbackUseCase(this.repository);

  Future<Either<Failure, Review?>> call(
      String branchId, String userId) {
    return repository.checkUserFeedback(branchId, userId);
  }
}
