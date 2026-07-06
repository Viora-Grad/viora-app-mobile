import 'package:equatable/equatable.dart';

class Review extends Equatable {
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

  const Review({
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

  @override
  List<Object?> get props => [
        feedbackId,
        branchId,
        userId,
        userName,
        serviceRatingOutOfTen,
        branchOutOfTen,
        systemExperienceOutOfTen,
        totalRatingOutOfTen,
        createdAtUtc,
        editedAtUtc,
        comment,
      ];
}
