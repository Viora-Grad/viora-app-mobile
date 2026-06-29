import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchOrganizations extends SearchEvent {
  final String? query;
  final String? country;
  final String? serviceType;
  final double minimumRating;
  final String? sortBy;
  final int page;

  const SearchOrganizations({
    this.query,
    this.country,
    this.serviceType,
    this.minimumRating = 0.0,
    this.sortBy,
    this.page = 1,
  });

  @override
  List<Object?> get props => [
        query,
        country,
        serviceType,
        minimumRating,
        sortBy,
        page,
      ];
}

class SearchBranches extends SearchEvent {
  final double? latitude;
  final double? longitude;
  final double? distanceWithinMeters;
  final List<String>? servicesFilter;
  final double minimumRating;
  final List<String>? orderBy;
  final bool? isCurrentlyOpen;
  final int page;

  const SearchBranches({
    this.latitude,
    this.longitude,
    this.distanceWithinMeters,
    this.servicesFilter,
    this.minimumRating = 0.0,
    this.orderBy,
    this.isCurrentlyOpen,
    this.page = 1,
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
      ];
}

class LoadFilterOptions extends SearchEvent {
  const LoadFilterOptions();
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class LoadMoreBranches extends SearchEvent {
  const LoadMoreBranches();
}
