import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/reviews/data/datasources/remote/review_remote.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';
import 'package:viora_app/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemote reviewRemote;

  ReviewRepositoryImpl(this.reviewRemote);

  @override
  Future<Either<Failure, List<Review>>> getBranchReviews(
      String branchId) async {
    try {
      final result = await reviewRemote.getBranchReviews(branchId);
      return Right(result.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, Review?>> checkUserFeedback(
      String branchId, String userId) async {
    try {
      final result =
          await reviewRemote.getUserBranchReview(branchId, userId);
      return Right(result?.toEntity());
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> submitFeedback(FeedbackParams params) async {
    try {
      await reviewRemote.submitFeedback({
        'branchId': params.branchId,
        'serviceRatingOutOfTen': params.serviceRatingOutOfTen,
        'branchOutOfTen': params.branchOutOfTen,
        'systemExperienceOutOfTen': params.systemExperienceOutOfTen,
        if (params.comment != null && params.comment!.isNotEmpty)
          'comment': params.comment,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateFeedback(FeedbackParams params) async {
    try {
      await reviewRemote.updateFeedback(params.feedbackId!, {
        'serviceRatingOutOfTen': params.serviceRatingOutOfTen,
        'branchOutOfTen': params.branchOutOfTen,
        'systemExperienceOutOfTen': params.systemExperienceOutOfTen,
        if (params.comment != null && params.comment!.isNotEmpty)
          'comment': params.comment,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
