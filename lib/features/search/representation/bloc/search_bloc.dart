import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/services/location_service.dart';
import 'package:viora_app/features/search/domain/usecases/search_branches_usecase.dart';
import 'package:viora_app/features/search/domain/usecases/search_organizations_usecase.dart';
import 'package:viora_app/features/search/representation/bloc/search_event.dart';
import 'package:viora_app/features/search/representation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchBranchesUseCase searchBranchesUseCase;
  final SearchOrganizationsUseCase searchOrganizationsUseCase;
  final GetCountriesUseCase getCountriesUseCase;
  final GetServiceTypesUseCase getServiceTypesUseCase;
  final LocationService locationService;

  List<String> _countries = [];
  List<String> _serviceTypes = [];
  String? _selectedCountry;
  String? _selectedServiceType;
  double _minRating = 0;
  String? _sortBy;

  List<String> get countries => _countries;
  List<String> get serviceTypes => _serviceTypes;
  String? get selectedCountry => _selectedCountry;
  String? get selectedServiceType => _selectedServiceType;
  double get minRating => _minRating;
  String? get sortBy => _sortBy;

  int get activeFilterCount {
    int count = 0;
    if (_selectedCountry != null) count++;
    if (_selectedServiceType != null) count++;
    if (_minRating > 0) count++;
    if (_sortBy != null) count++;
    return count;
  }

  SearchBloc({
    required this.searchBranchesUseCase,
    required this.searchOrganizationsUseCase,
    required this.getCountriesUseCase,
    required this.getServiceTypesUseCase,
    required this.locationService,
  }) : super(const SearchInitial()) {
    on<LoadFilterOptions>(_onLoadFilterOptions);
    on<SearchOrganizations>(_onSearchOrganizations);
    on<SearchBranches>(_onSearchBranches);
    on<LoadMoreBranches>(_onLoadMoreBranches);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadFilterOptions(
    LoadFilterOptions event,
    Emitter<SearchState> emit,
  ) async {
    final countriesResult = await getCountriesUseCase();
    final serviceTypesResult = await getServiceTypesUseCase();

    countriesResult.fold(
      (_) => _countries = [],
      (countries) => _countries = countries,
    );

    serviceTypesResult.fold(
      (_) => _serviceTypes = [],
      (serviceTypes) => _serviceTypes = serviceTypes,
    );

    emit(SearchFilterOptionsLoaded(
      countries: _countries,
      serviceTypes: _serviceTypes,
    ));
  }

  Future<void> _onSearchOrganizations(
    SearchOrganizations event,
    Emitter<SearchState> emit,
  ) async {
    _selectedCountry = event.country;
    _selectedServiceType = event.serviceType;
    _minRating = event.minimumRating;
    _sortBy = event.sortBy;

    emit(const SearchLoading());

    final result = await searchOrganizationsUseCase(
      SearchOrganizationsParams(
        name: event.query,
        country: event.country,
        serviceType: event.serviceType,
        minimumRating: event.minimumRating,
        sortBy: event.sortBy,
        page: event.page,
      ),
    );

    result.fold(
      (failure) => emit(SearchError(failure.message)),
      (paginated) {
        if (paginated.items.isEmpty) {
          emit(SearchEmpty(
            countries: _countries,
            serviceTypes: _serviceTypes,
            selectedCountry: _selectedCountry,
            selectedServiceType: _selectedServiceType,
            minRating: _minRating,
            sortBy: _sortBy,
          ));
        } else {
          emit(SearchOrganizationsLoaded(
            organizations: paginated.items,
            page: paginated.page,
            totalCount: paginated.totalCount,
            totalPages: paginated.totalPages,
            hasNextPage: paginated.hasNextPage,
            query: event.query,
            countries: _countries,
            serviceTypes: _serviceTypes,
            selectedCountry: _selectedCountry,
            selectedServiceType: _selectedServiceType,
            minRating: _minRating,
            sortBy: _sortBy,
          ));
        }
      },
    );
  }

  Future<void> _onSearchBranches(
    SearchBranches event,
    Emitter<SearchState> emit,
  ) async {
    debugPrint('[SearchBloc] SearchBranches event received — '
        'lat=${event.latitude}, lng=${event.longitude}, '
        'dist=${event.distanceWithinMeters}, services=${event.servicesFilter}, '
        'minRating=${event.minimumRating}, isOpen=${event.isCurrentlyOpen}, '
        'orderBy=${event.orderBy}, page=${event.page}');
    emit(const SearchLoading());

    final result = await searchBranchesUseCase(
      SearchBranchesParams(
        latitude: event.latitude,
        longitude: event.longitude,
        distanceWithinMeters: event.distanceWithinMeters,
        servicesFilter: event.servicesFilter,
        minimumRating: event.minimumRating,
        orderBy: event.orderBy,
        isCurrentlyOpen: event.isCurrentlyOpen,
        page: event.page,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('[SearchBloc] ❌ SearchBranches FAILED — ${failure.message}');
        emit(SearchError(failure.message));
      },
      (paginated) {
        if (paginated.items.isEmpty) {
          debugPrint('[SearchBloc] SearchBranches returned 0 results');
          emit(SearchBranchesLoaded(
            branches: [],
            page: paginated.page,
            totalCount: 0,
            totalPages: 0,
            hasNextPage: false,
            latitude: event.latitude,
            longitude: event.longitude,
            distanceWithinMeters: event.distanceWithinMeters,
            servicesFilter: event.servicesFilter,
            minimumRating: event.minimumRating,
            orderBy: event.orderBy,
            isCurrentlyOpen: event.isCurrentlyOpen,
          ));
        } else {
          debugPrint('[SearchBloc] ✅ SearchBranches loaded ${paginated.items.length} items (total: ${paginated.totalCount})');
          emit(SearchBranchesLoaded(
            branches: paginated.items,
            page: paginated.page,
            totalCount: paginated.totalCount,
            totalPages: paginated.totalPages,
            hasNextPage: paginated.hasNextPage,
            latitude: event.latitude,
            longitude: event.longitude,
            distanceWithinMeters: event.distanceWithinMeters,
            servicesFilter: event.servicesFilter,
            minimumRating: event.minimumRating,
            orderBy: event.orderBy,
            isCurrentlyOpen: event.isCurrentlyOpen,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreBranches(
    LoadMoreBranches event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    debugPrint('[SearchBloc] LoadMoreBranches — current state: ${currentState.runtimeType}');
    if (currentState is SearchBranchesLoaded && currentState.hasNextPage) {
      debugPrint('[SearchBloc] Loading page ${currentState.page + 1}...');
      emit(SearchBranchesLoadingMore(
        branches: currentState.branches,
        page: currentState.page,
        totalCount: currentState.totalCount,
        totalPages: currentState.totalPages,
        hasNextPage: currentState.hasNextPage,
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        distanceWithinMeters: currentState.distanceWithinMeters,
        servicesFilter: currentState.servicesFilter,
        minimumRating: currentState.minimumRating,
        orderBy: currentState.orderBy,
        isCurrentlyOpen: currentState.isCurrentlyOpen,
      ));

      final result = await searchBranchesUseCase(
        SearchBranchesParams(
          latitude: currentState.latitude,
          longitude: currentState.longitude,
          distanceWithinMeters: currentState.distanceWithinMeters,
          servicesFilter: currentState.servicesFilter,
          minimumRating: currentState.minimumRating,
          orderBy: currentState.orderBy,
          isCurrentlyOpen: currentState.isCurrentlyOpen,
          page: currentState.page + 1,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('[SearchBloc] ❌ LoadMoreBranches FAILED — ${failure.message}');
          emit(SearchError(failure.message));
        },
        (paginated) {
          debugPrint('[SearchBloc] ✅ LoadMoreBranches loaded ${paginated.items.length} more items (total: ${paginated.totalCount})');
          emit(SearchBranchesLoaded(
            branches: [
              ...currentState.branches,
              ...paginated.items,
            ],
            page: paginated.page,
            totalCount: paginated.totalCount,
            totalPages: paginated.totalPages,
            hasNextPage: paginated.hasNextPage,
            latitude: currentState.latitude,
            longitude: currentState.longitude,
            distanceWithinMeters: currentState.distanceWithinMeters,
            servicesFilter: currentState.servicesFilter,
            minimumRating: currentState.minimumRating,
            orderBy: currentState.orderBy,
            isCurrentlyOpen: currentState.isCurrentlyOpen,
          ));
        },
      );
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) async {
    _selectedCountry = null;
    _selectedServiceType = null;
    _minRating = 0;
    _sortBy = null;
    emit(const SearchInitial());
  }
}
