import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/search/domain/entities/branch.dart';
import 'package:viora_app/features/search/domain/repositories/search_repository.dart';

class SearchBranchesUseCase {
  final SearchRepository repository;

  SearchBranchesUseCase(this.repository);

  Future<Either<Failure, PaginatedBranches>> call(
    SearchBranchesParams params,
  ) {
    return repository.searchBranches(
      latitude: params.latitude,
      longitude: params.longitude,
      distanceWithinMeters: params.distanceWithinMeters,
      servicesFilter: params.servicesFilter,
      minimumRating: params.minimumRating,
      orderBy: params.orderBy,
      isCurrentlyOpen: params.isCurrentlyOpen,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class SearchBranchesParams extends Equatable {
  final double? latitude;
  final double? longitude;
  final double? distanceWithinMeters;
  final List<String>? servicesFilter;
  final double minimumRating;
  final List<String>? orderBy;
  final bool? isCurrentlyOpen;
  final int page;
  final int pageSize;

  const SearchBranchesParams({
    this.latitude,
    this.longitude,
    this.distanceWithinMeters,
    this.servicesFilter,
    this.minimumRating = 0.0,
    this.orderBy,
    this.isCurrentlyOpen,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        distanceWithinMeters,
        servicesFilter,
        minimumRating,
        orderBy,
        isCurrentlyOpen,
        page,
        pageSize,
      ];
}
