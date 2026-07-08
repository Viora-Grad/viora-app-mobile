import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class ChangeCategoryEvent extends HomeEvent {
  final String categoryName;
  const ChangeCategoryEvent(this.categoryName);

  @override
  List<Object?> get props => [categoryName];
}

class SearchOrganizationsEvent extends HomeEvent {
  final String query;
  final String? country;
  final String? serviceType;
  final double minimumRating;
  final String? sortBy;
  final int page;

  const SearchOrganizationsEvent({
    required this.query,
    this.country,
    this.serviceType,
    this.minimumRating = 0.0,
    this.sortBy,
    this.page = 1,
  });

  @override
  List<Object?> get props => [query, country, serviceType, minimumRating, sortBy, page];
}

class ClearHomeSearchEvent extends HomeEvent {
  const ClearHomeSearchEvent();
}

class LoadFilterOptionsEvent extends HomeEvent {
  const LoadFilterOptionsEvent();
}
