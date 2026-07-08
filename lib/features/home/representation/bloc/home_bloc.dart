import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/Auth/data/datasources/local/auth_local.dart';
import 'package:viora_app/features/search/domain/usecases/search_organizations_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthLocalDataSource _authLocal;
  final SearchOrganizationsUseCase _searchOrganizationsUseCase;
  final GetCountriesUseCase _getCountriesUseCase;
  final GetServiceTypesUseCase _getServiceTypesUseCase;

  String _userName = '';

  HomeBloc({
    required AuthLocalDataSource authLocal,
    required SearchOrganizationsUseCase searchOrganizationsUseCase,
    required GetCountriesUseCase getCountriesUseCase,
    required GetServiceTypesUseCase getServiceTypesUseCase,
  })  : _authLocal = authLocal,
        _searchOrganizationsUseCase = searchOrganizationsUseCase,
        _getCountriesUseCase = getCountriesUseCase,
        _getServiceTypesUseCase = getServiceTypesUseCase,
        super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<ChangeCategoryEvent>((event, emit) {
      if (state is HomeLoaded) {
        emit((state as HomeLoaded)
            .copyWith(selectedCategory: event.categoryName));
      }
    });
    on<SearchOrganizationsEvent>(_onSearchOrganizations);
    on<ClearHomeSearchEvent>(_onClearSearch);
    on<LoadFilterOptionsEvent>(_onLoadFilterOptions);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final user = await _authLocal.getCurrentUser();
      _userName = user?.firstName ?? '';
      emit(HomeLoaded(
          selectedCategory: 'Doctor', userName: _userName));
    } catch (_) {
      _userName = '';
      emit(const HomeLoaded(
          selectedCategory: 'Doctor', userName: ''));
    }
  }

  Future<void> _onSearchOrganizations(
    SearchOrganizationsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final hasFilters = event.country != null ||
        event.serviceType != null ||
        event.minimumRating > 0 ||
        event.sortBy != null;

    if (event.query.isEmpty && !hasFilters) {
      final loaded = state is HomeLoaded
          ? state as HomeLoaded
          : null;
      emit(HomeLoaded(
        selectedCategory: 'Doctor',
        userName: _userName,
        countries: loaded?.countries ?? [],
        serviceTypes: loaded?.serviceTypes ?? [],
      ));
      return;
    }

    final currentActive = state is HomeSearchActive
        ? state as HomeSearchActive
        : null;

    emit(HomeSearchActive(
      userName: _userName,
      query: event.query,
      organizations: currentActive?.organizations ?? [],
      totalCount: currentActive?.totalCount ?? 0,
      isLoading: true,
      countries: currentActive?.countries ?? [],
      serviceTypes: currentActive?.serviceTypes ?? [],
      selectedCountry: event.country,
      selectedServiceType: event.serviceType,
      minRating: event.minimumRating,
      sortBy: event.sortBy,
    ));

    final result = await _searchOrganizationsUseCase(
      SearchOrganizationsParams(
        name: event.query.isEmpty ? null : event.query,
        country: event.country,
        serviceType: event.serviceType,
        minimumRating: event.minimumRating,
        sortBy: event.sortBy,
        page: event.page,
      ),
    );

    result.fold(
      (failure) {
        if (state is HomeSearchActive) {
          emit((state as HomeSearchActive).copyWith(
            isLoading: false,
          ));
        }
      },
      (paginated) {
        final cur = state is HomeSearchActive
            ? state as HomeSearchActive
            : null;
        if (paginated.items.isEmpty) {
          emit(HomeSearchEmpty(
            userName: _userName,
            query: event.query,
            countries: cur?.countries ?? [],
            serviceTypes: cur?.serviceTypes ?? [],
            selectedCountry: event.country,
            selectedServiceType: event.serviceType,
            minRating: event.minimumRating,
            sortBy: event.sortBy,
          ));
        } else {
          final prev = state is HomeSearchActive
              ? state as HomeSearchActive
              : null;
          emit(HomeSearchActive(
            userName: _userName,
            query: event.query,
            organizations: paginated.items,
            totalCount: paginated.totalCount,
            page: paginated.page,
            totalPages: paginated.totalPages,
            hasNextPage: paginated.hasNextPage,
            isLoading: false,
            countries: prev?.countries ?? [],
            serviceTypes: prev?.serviceTypes ?? [],
            selectedCountry: event.country,
            selectedServiceType: event.serviceType,
            minRating: event.minimumRating,
            sortBy: event.sortBy,
          ));
        }
      },
    );
  }

  void _onClearSearch(
    ClearHomeSearchEvent event,
    Emitter<HomeState> emit,
  ) {
    List<String> savedCountries = [];
    List<String> savedServiceTypes = [];
    if (state is HomeSearchActive) {
      final s = state as HomeSearchActive;
      savedCountries = s.countries;
      savedServiceTypes = s.serviceTypes;
    } else if (state is HomeSearchEmpty) {
      final s = state as HomeSearchEmpty;
      savedCountries = s.countries;
      savedServiceTypes = s.serviceTypes;
    }
    emit(HomeLoaded(
      selectedCategory: 'Doctor',
      userName: _userName,
      countries: savedCountries,
      serviceTypes: savedServiceTypes,
    ));
  }

  Future<void> _onLoadFilterOptions(
    LoadFilterOptionsEvent event,
    Emitter<HomeState> emit,
  ) async {
    final countriesResult = await _getCountriesUseCase();
    final serviceTypesResult = await _getServiceTypesUseCase();

    List<String> countries = [];
    List<String> serviceTypes = [];

    countriesResult.fold(
      (_) => countries = [],
      (c) => countries = c,
    );
    serviceTypesResult.fold(
      (_) => serviceTypes = [],
      (s) => serviceTypes = s,
    );

    if (state is HomeSearchActive) {
      emit((state as HomeSearchActive).copyWith(
        countries: countries,
        serviceTypes: serviceTypes,
      ));
    } else if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(
        countries: countries,
        serviceTypes: serviceTypes,
      ));
    }
  }
}
