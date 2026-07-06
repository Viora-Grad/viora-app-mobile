import 'package:viora_app/features/reviews/domain/entities/review.dart';

class ReviewModel {
  final String feedbackId;
  final String branchId;
  final String userId;
  final String userName;
  final int serviceRatingOutOfTen;
  final int branchOutOfTen;
  final int systemExperienceOutOfTen;
  final int totalRatingOutOfTen;
  final DateTime createdAtUtc;
  final DateTime? editedAtUtc;
  final String? comment;

  const ReviewModel({
    required this.feedbackId,
    required this.branchId,
    required this.userId,
    required this.userName,
    required this.serviceRatingOutOfTen,
    required this.branchOutOfTen,
    required this.systemExperienceOutOfTen,
    required this.totalRatingOutOfTen,
    required this.createdAtUtc,
    this.editedAtUtc,
    this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      feedbackId: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Anonymous',
      serviceRatingOutOfTen:
          (json['serviceRatingOutOfTen'] as num?)?.toInt() ?? 0,
      branchOutOfTen: (json['branchOutOfTen'] as num?)?.toInt() ?? 0,
      systemExperienceOutOfTen:
          (json['systemExperienceOutOfTen'] as num?)?.toInt() ?? 0,
      totalRatingOutOfTen:
          (json['totalRatingOurOfTen'] as num?)?.toInt() ?? 0,
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] as String? ?? '') ??
          DateTime.now(),
      editedAtUtc:
          DateTime.tryParse(json['editedAtUtc'] as String? ?? ''),
      comment: json['comment'] as String?,
    );
  }

  Review toEntity() {
    return Review(
      feedbackId: feedbackId,
      branchId: branchId,
      userId: userId,
      userName: userName,
      serviceRatingOutOfTen: serviceRatingOutOfTen,
      branchOutOfTen: branchOutOfTen,
      systemExperienceOutOfTen: systemExperienceOutOfTen,
      totalRatingOutOfTen: totalRatingOutOfTen,
      createdAtUtc: createdAtUtc,
      editedAtUtc: editedAtUtc,
      comment: comment,
    );
  }
}
