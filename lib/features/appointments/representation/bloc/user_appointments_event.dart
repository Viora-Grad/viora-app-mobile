import 'package:equatable/equatable.dart';

sealed class UserAppointmentsEvent extends Equatable {
  const UserAppointmentsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadUserAppointments extends UserAppointmentsEvent {
  final String customerId;
  final String? statusFilter;

  const LoadUserAppointments({
    required this.customerId,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [customerId, statusFilter];
}

final class CancelSingleAppointment extends UserAppointmentsEvent {
  final String appointmentId;

  const CancelSingleAppointment({required this.appointmentId});

  @override
  List<Object?> get props => [appointmentId];
}

final class FilterUserAppointments extends UserAppointmentsEvent {
  final String searchQuery;
  final String? statusFilter;
  final bool sortAscending;

  const FilterUserAppointments({
    this.searchQuery = '',
    this.statusFilter,
    this.sortAscending = false,
  });

  @override
  List<Object?> get props => [searchQuery, statusFilter, sortAscending];
}
