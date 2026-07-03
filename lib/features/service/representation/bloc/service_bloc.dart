import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/service/domain/usecases/get_services_by_branch_usecase.dart';
import 'package:viora_app/features/service/representation/bloc/service_event.dart';
import 'package:viora_app/features/service/representation/bloc/service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetServicesByBranchUseCase getServicesByBranchUseCase;

  ServiceBloc({required this.getServicesByBranchUseCase})
      : super(const ServiceInitial()) {
    on<LoadServices>(_onLoadServices);
    on<SearchServices>(_onSearchServices);
  }

  Future<void> _onLoadServices(
      LoadServices event, Emitter<ServiceState> emit) async {
    emit(const ServiceLoading());

    final result = await getServicesByBranchUseCase(event.branchId);

    result.fold(
      (failure) => emit(ServiceError(failure.message)),
      (allServices) {
        final filtered = allServices
            .where((s) => s.serviceType.toLowerCase() == event.serviceType.toLowerCase())
            .toList();
        emit(ServiceLoaded(
          allServices: allServices,
          filteredServices: filtered,
          serviceType: event.serviceType,
        ));
      },
    );
  }

  void _onSearchServices(SearchServices event, Emitter<ServiceState> emit) {
    final current = state;
    if (current is! ServiceLoaded) return;

    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(current.copyWith(
        filteredServices: current.allServices
            .where((s) =>
                s.serviceType.toLowerCase() == current.serviceType.toLowerCase())
            .toList(),
        searchQuery: '',
      ));
      return;
    }

    final filtered = current.allServices
        .where((s) =>
            s.serviceType.toLowerCase() == current.serviceType.toLowerCase() &&
            (s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query)))
        .toList();

    emit(current.copyWith(
      filteredServices: filtered,
      searchQuery: event.query,
    ));
  }
}
