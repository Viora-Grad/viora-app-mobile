import 'package:viora_app/features/reviews/data/models/review_model.dart';

abstract class ReviewRemote {
  Future<List<ReviewModel>> getBranchReviews(String branchId);

  Future<ReviewModel?> getUserBranchReview(String branchId, String userId);

  Future<void> submitFeedback(Map<String, dynamic> data);

  Future<void> updateFeedback(String feedbackId, Map<String, dynamic> data);
}
