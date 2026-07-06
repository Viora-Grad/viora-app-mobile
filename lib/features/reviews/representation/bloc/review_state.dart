import 'package:equatable/equatable.dart';
import 'package:viora_app/features/reviews/domain/entities/review.dart';

sealed class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewLoaded extends ReviewState {
  final List<Review> reviews;

  const ReviewLoaded({required this.reviews});

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(
        0, (prev, r) => prev + r.totalRatingOutOfTen);
    return sum / reviews.length;
  }

  double get averageServiceRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(
        0, (prev, r) => prev + r.serviceRatingOutOfTen);
    return sum / reviews.length;
  }

  double get averageBranchRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(
        0, (prev, r) => prev + r.branchOutOfTen);
    return sum / reviews.length;
  }

  double get averageSystemExperienceRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<double>(
        0, (prev, r) => prev + r.systemExperienceOutOfTen);
    return sum / reviews.length;
  }

  @override
  List<Object?> get props => [reviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
