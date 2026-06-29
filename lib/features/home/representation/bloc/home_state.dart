import 'package:equatable/equatable.dart';
import 'package:viora_app/features/search/domain/entities/organization.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String selectedCategory;
  final String userName;
  final List<String> countries;
  final List<String> serviceTypes;

  const HomeLoaded({
    required this.selectedCategory,
    this.userName = '',
    this.countries = const [],
    this.serviceTypes = const [],
  });

  HomeLoaded copyWith({
    String? selectedCategory,
    String? userName,
    List<String>? countries,
    List<String>? serviceTypes,
  }) {
    return HomeLoaded(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      userName: userName ?? this.userName,
      countries: countries ?? this.countries,
      serviceTypes: serviceTypes ?? this.serviceTypes,
    );
  }

  @override
  List<Object?> get props =>
      [selectedCategory, userName, countries, serviceTypes];
}

class HomeSearchActive extends HomeState {
  final String userName;
  final String query;
  final List<Organization> organizations;
  final int totalCount;
  final int page;
  final int totalPages;
  final bool hasNextPage;
  final bool isLoading;
  final List<String> countries;
  final List<String> serviceTypes;
  final String? selectedCountry;
  final String? selectedServiceType;
  final double minRating;
  final String? sortBy;

  const HomeSearchActive({
    required this.userName,
    required this.query,
    this.organizations = const [],
    this.totalCount = 0,
    this.page = 1,
    this.totalPages = 0,
    this.hasNextPage = false,
    this.isLoading = false,
    this.countries = const [],
    this.serviceTypes = const [],
    this.selectedCountry,
    this.selectedServiceType,
    this.minRating = 0.0,
    this.sortBy,
  });

  HomeSearchActive copyWith({
    String? query,
    List<Organization>? organizations,
    int? totalCount,
    int? page,
    int? totalPages,
    bool? hasNextPage,
    bool? isLoading,
    List<String>? countries,
    List<String>? serviceTypes,
  }) {
    return HomeSearchActive(
      userName: userName,
      query: query ?? this.query,
      organizations: organizations ?? this.organizations,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoading: isLoading ?? this.isLoading,
      countries: countries ?? this.countries,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      selectedCountry: selectedCountry,
      selectedServiceType: selectedServiceType,
      minRating: minRating,
      sortBy: sortBy,
    );
  }

  bool get hasActiveFilters =>
      selectedCountry != null ||
      selectedServiceType != null ||
      minRating > 0 ||
      sortBy != null;

  @override
  List<Object?> get props => [
        userName,
        query,
        organizations,
        totalCount,
        page,
        totalPages,
        hasNextPage,
        isLoading,
        countries,
        serviceTypes,
        selectedCountry,
        selectedServiceType,
        minRating,
        sortBy,
      ];
}

class HomeSearchEmpty extends HomeState {
  final String userName;
  final String query;
  final List<String> countries;
  final List<String> serviceTypes;
  final String? selectedCountry;
  final String? selectedServiceType;
  final double minRating;
  final String? sortBy;

  const HomeSearchEmpty({
    required this.userName,
    required this.query,
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
        userName,
        query,
        countries,
        serviceTypes,
        selectedCountry,
        selectedServiceType,
        minRating,
        sortBy,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
