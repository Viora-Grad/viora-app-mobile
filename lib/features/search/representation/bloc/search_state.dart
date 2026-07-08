import 'package:equatable/equatable.dart';
import 'package:viora_app/features/search/domain/entities/branch.dart';
import 'package:viora_app/features/search/domain/entities/organization.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchFilterOptionsLoaded extends SearchState {
  final List<String> countries;
  final List<String> serviceTypes;

  const SearchFilterOptionsLoaded({
    required this.countries,
    required this.serviceTypes,
  });

  @override
  List<Object?> get props => [countries, serviceTypes];
}

class SearchBranchesLoaded extends SearchState {
  final List<Branch> branches;
  final int page;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final double? latitude;
  final double? longitude;
  final double? distanceWithinMeters;
  final List<String>? servicesFilter;
  final double minimumRating;
  final List<String>? orderBy;
  final bool? isCurrentlyOpen;

  const SearchBranchesLoaded({
    required this.branches,
    required this.page,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    this.latitude,
    this.longitude,
    this.distanceWithinMeters,
    this.servicesFilter,
    this.minimumRating = 0.0,
    this.orderBy,
    this.isCurrentlyOpen,
  });

  @override
  List<Object?> get props => [
        branches,
        page,
        totalCount,
        totalPages,
        hasNextPage,
        latitude,
        longitude,
        distanceWithinMeters,
        servicesFilter,
        minimumRating,
        orderBy,
        isCurrentlyOpen,
      ];
}

class SearchBranchesLoadingMore extends SearchState {
  final List<Branch> branches;
  final int page;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final double? latitude;
  final double? longitude;
  final double? distanceWithinMeters;
  final List<String>? servicesFilter;
  final double minimumRating;
  final List<String>? orderBy;
  final bool? isCurrentlyOpen;

  const SearchBranchesLoadingMore({
    required this.branches,
    required this.page,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    this.latitude,
    this.longitude,
    this.distanceWithinMeters,
    this.servicesFilter,
    this.minimumRating = 0.0,
    this.orderBy,
    this.isCurrentlyOpen,
  });

  @override
  List<Object?> get props => [
        branches,
        page,
        totalCount,
        totalPages,
        hasNextPage,
        latitude,
        longitude,
        distanceWithinMeters,
        servicesFilter,
        minimumRating,
        orderBy,
        isCurrentlyOpen,
      ];
}

class SearchEmpty extends SearchState {
  final List<String> countries;
  final List<String> serviceTypes;
  final String? selectedCountry;
  final String? selectedServiceType;
  final double minRating;
  final String? sortBy;

  const SearchEmpty({
    this.countries = const [],
    this.serviceTypes = const [],
    this.selectedCountry,
    this.selectedServiceType,
    this.minRating = 0.0,
    this.sortBy,
  });

  bool get hasActiveFilters =>
      selectedCountry != null ||
      selectedServiceType != null ||
      minRating > 0 ||
      sortBy != null;

  @override
  List<Object?> get props => [
        countries,
        serviceTypes,
        selectedCountry,
        selectedServiceType,
        minRating,
        sortBy,
      ];
}

class SearchOrganizationsLoaded extends SearchState {
  final List<Organization> organizations;
  final int page;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final String? query;
  final List<String> countries;
  final List<String> serviceTypes;
  final String? selectedCountry;
  final String? selectedServiceType;
  final double minRating;
  final String? sortBy;

  const SearchOrganizationsLoaded({
    required this.organizations,
    required this.page,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    this.query,
    this.countries = const [],
    this.serviceTypes = const [],
    this.selectedCountry,
    this.selectedServiceType,
    this.minRating = 0.0,
    this.sortBy,
  });

  bool get hasActiveFilters =>
      selectedCountry != null ||
      selectedServiceType != null ||
      minRating > 0 ||
      sortBy != null;

  @override
  List<Object?> get props => [
        organizations,
        page,
        totalCount,
        totalPages,
        hasNextPage,
        query,
        countries,
        serviceTypes,
        selectedCountry,
        selectedServiceType,
        minRating,
        sortBy,
      ];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
