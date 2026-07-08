import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';
import 'package:viora_app/features/reviews/domain/repositories/review_repository.dart';

class GetBranchReviewsUseCase {
  final ReviewRepository repository;

  GetBranchReviewsUseCase(this.repository);

  Future<Either<Failure, List<Review>>> call(String branchId) {
    return repository.getBranchReviews(branchId);
  }
}
