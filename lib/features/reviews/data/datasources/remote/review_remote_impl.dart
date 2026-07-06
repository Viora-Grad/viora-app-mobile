import 'package:dio/dio.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/features/reviews/data/datasources/remote/review_remote.dart';
import 'package:viora_app/features/reviews/data/models/review_model.dart';

class ReviewRemoteImpl implements ReviewRemote {
  final Dio dio;

  ReviewRemoteImpl(this.dio);

  @override
  Future<List<ReviewModel>> getBranchReviews(String branchId) async {
    try {
      final response = await dio.get(
        '${EndPoints.feedbackUrl}?branchId=$branchId',
        options: Options(contentType: Headers.jsonContentType),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) {
          return items
              .map((e) =>
                  ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<ReviewModel?> getUserBranchReview(
      String branchId, String userId) async {
    try {
      final response = await dio.get(
        '${EndPoints.feedbackUrl}?branchId=$branchId&userId=$userId',
        options: Options(contentType: Headers.jsonContentType),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List && items.isNotEmpty) {
          return ReviewModel.fromJson(items[0] as Map<String, dynamic>);
        }
      }

      return null;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> submitFeedback(Map<String, dynamic> data) async {
    try {
      await dio.post(
        EndPoints.feedbackUrl,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> updateFeedback(String feedbackId, Map<String, dynamic> data) async {
    try {
      await dio.put(
        '${EndPoints.feedbackUrl}/$feedbackId',
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
