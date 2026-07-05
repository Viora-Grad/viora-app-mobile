import 'package:equatable/equatable.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';

sealed class UserAppointmentsState extends Equatable {
  const UserAppointmentsState();

  @override
  List<Object?> get props => [];
}

final class UserAppointmentsInitial extends UserAppointmentsState {
  const UserAppointmentsInitial();
}

final class UserAppointmentsLoading extends UserAppointmentsState {
  const UserAppointmentsLoading();
}

final class UserAppointmentsLoaded extends UserAppointmentsState {
  final List<ReservedAppointment> allAppointments;
  final List<ReservedAppointment> filteredAppointments;
  final String? selectedStatus;
  final String searchQuery;
  final bool sortAscending;
  final bool cancelledSuccessfully;

  const UserAppointmentsLoaded({
    required this.allAppointments,
    required this.filteredAppointments,
    this.selectedStatus,
    this.searchQuery = '',
    this.sortAscending = false,
    this.cancelledSuccessfully = false,
  });

  @override
  List<Object?> get props => [
        allAppointments,
        filteredAppointments,
        selectedStatus,
        searchQuery,
        sortAscending,
        cancelledSuccessfully,
      ];
}

final class UserAppointmentsError extends UserAppointmentsState {
  final String message;

  const UserAppointmentsError({required this.message});

  @override
  List<Object?> get props => [message];
}
