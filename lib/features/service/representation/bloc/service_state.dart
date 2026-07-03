import 'package:equatable/equatable.dart';
import 'package:viora_app/features/service/domain/entities/service.dart';

sealed class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

final class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

final class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

final class ServiceLoaded extends ServiceState {
  final List<Service> allServices;
  final List<Service> filteredServices;
  final String serviceType;
  final String searchQuery;

  const ServiceLoaded({
    required this.allServices,
    required this.filteredServices,
    required this.serviceType,
    this.searchQuery = '',
  });

  ServiceLoaded copyWith({
    List<Service>? allServices,
    List<Service>? filteredServices,
    String? serviceType,
    String? searchQuery,
  }) {
    return ServiceLoaded(
      allServices: allServices ?? this.allServices,
      filteredServices: filteredServices ?? this.filteredServices,
      serviceType: serviceType ?? this.serviceType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allServices, filteredServices, serviceType, searchQuery];
}

final class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
