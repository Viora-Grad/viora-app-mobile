import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/reviews/domain/usecases/get_branch_reviews_usecase.dart';
import 'package:viora_app/features/reviews/representation/bloc/review_event.dart';
import 'package:viora_app/features/reviews/representation/bloc/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetBranchReviewsUseCase getBranchReviewsUseCase;

  ReviewBloc({required this.getBranchReviewsUseCase})
      : super(const ReviewInitial()) {
    on<GetBranchReviews>(_onGetBranchReviews);
  }

  Future<void> _onGetBranchReviews(
    GetBranchReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewLoading());

    final result = await getBranchReviewsUseCase(event.branchId);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ReviewLoaded(reviews: reviews)),
    );
  }
}
