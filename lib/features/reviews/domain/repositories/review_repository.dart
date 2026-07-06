import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';

class FeedbackParams {
  final String? feedbackId;
  final String branchId;
  final int serviceRatingOutOfTen;
  final int branchOutOfTen;
  final int systemExperienceOutOfTen;
  final String? comment;

  const FeedbackParams({
    this.feedbackId,
    required this.branchId,
    required this.serviceRatingOutOfTen,
    required this.branchOutOfTen,
    required this.systemExperienceOutOfTen,
    this.comment,
  });
}

abstract class ReviewRepository {
  Future<Either<Failure, List<Review>>> getBranchReviews(String branchId);

  Future<Either<Failure, Review?>> checkUserFeedback(
      String branchId, String userId);

  Future<Either<Failure, void>> submitFeedback(FeedbackParams params);

  Future<Either<Failure, void>> updateFeedback(FeedbackParams params);
}
