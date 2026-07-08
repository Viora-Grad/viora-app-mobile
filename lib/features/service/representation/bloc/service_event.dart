import 'package:equatable/equatable.dart';

sealed class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

final class LoadServices extends ServiceEvent {
  final String branchId;
  final String serviceType;

  const LoadServices({
    required this.branchId,
    required this.serviceType,
  });

  @override
  List<Object?> get props => [branchId, serviceType];
}

final class SearchServices extends ServiceEvent {
  final String query;

  const SearchServices({required this.query});

  @override
  List<Object?> get props => [query];
}
