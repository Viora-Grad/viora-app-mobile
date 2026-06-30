import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/search/domain/entities/organization.dart';
import 'package:viora_app/features/search/domain/repositories/search_repository.dart';

class SearchOrganizationsUseCase {
  final SearchRepository repository;

  SearchOrganizationsUseCase(this.repository);

  Future<Either<Failure, PaginatedOrganizations>> call(
    SearchOrganizationsParams params,
  ) {
    return repository.searchOrganizations(
      name: params.name,
      country: params.country,
      serviceType: params.serviceType,
      minimumRating: params.minimumRating,
      sortBy: params.sortBy,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class SearchOrganizationsParams extends Equatable {
  final String? name;
  final String? country;
  final String? serviceType;
  final double minimumRating;
  final String? sortBy;
  final int page;
  final int pageSize;

  const SearchOrganizationsParams({
    this.name,
    this.country,
    this.serviceType,
    this.minimumRating = 0.0,
    this.sortBy,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [
        name,
        country,
        serviceType,
        minimumRating,
        sortBy,
        page,
        pageSize,
      ];
}

class GetCountriesUseCase {
  final SearchRepository repository;

  GetCountriesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getCountries();
  }
}

class GetServiceTypesUseCase {
  final SearchRepository repository;

  GetServiceTypesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getServiceTypes();
  }
}
