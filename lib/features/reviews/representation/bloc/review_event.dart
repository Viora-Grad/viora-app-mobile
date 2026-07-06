import 'package:equatable/equatable.dart';

sealed class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class GetBranchReviews extends ReviewEvent {
  final String branchId;

  const GetBranchReviews({required this.branchId});

  @override
  List<Object?> get props => [branchId];
}
