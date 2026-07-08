import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_user_appointments.dart';
import 'package:viora_app/features/appointments/domain/usecases/cancel_appointment.dart';
import 'package:viora_app/features/appointments/representation/bloc/user_appointments_event.dart';
import 'package:viora_app/features/appointments/representation/bloc/user_appointments_state.dart';

class UserAppointmentsBloc
    extends Bloc<UserAppointmentsEvent, UserAppointmentsState> {
  final GetUserAppointmentsUseCase getUserAppointments;
  final CancelAppointmentUseCase cancelAppointment;
  List<ReservedAppointment> _cachedAppointments = [];

  UserAppointmentsBloc({
    required this.getUserAppointments,
    required this.cancelAppointment,
  }) : super(const UserAppointmentsInitial()) {
    on<LoadUserAppointments>(_onLoadUserAppointments);
    on<FilterUserAppointments>(_onFilterUserAppointments);
    on<CancelSingleAppointment>(_onCancelAppointment);
  }

  Future<void> _onLoadUserAppointments(
    LoadUserAppointments event,
    Emitter<UserAppointmentsState> emit,
  ) async {
    emit(const UserAppointmentsLoading());

    final result = await getUserAppointments(
      customerId: event.customerId,
      status: event.statusFilter,
    );

    result.fold(
      (failure) => emit(
        UserAppointmentsError(message: failure.message),
      ),
      (appointments) {
        _cachedAppointments = List<ReservedAppointment>.from(appointments)
          ..sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
        emit(
          UserAppointmentsLoaded(
            allAppointments: _cachedAppointments,
            filteredAppointments: _cachedAppointments,
            selectedStatus: event.statusFilter,
          ),
        );
      },
    );
  }

  Future<void> _onCancelAppointment(
    CancelSingleAppointment event,
    Emitter<UserAppointmentsState> emit,
  ) async {
    emit(const UserAppointmentsLoading());

    final result = await cancelAppointment(event.appointmentId);

    result.fold(
      (failure) => emit(
        UserAppointmentsError(message: failure.message),
      ),
      (_) {
        _cachedAppointments.removeWhere((a) => a.id == event.appointmentId);
        emit(
          UserAppointmentsLoaded(
            allAppointments: _cachedAppointments,
            filteredAppointments: _cachedAppointments,
            cancelledSuccessfully: true,
          ),
        );
      },
    );
  }

  void _onFilterUserAppointments(
    FilterUserAppointments event,
    Emitter<UserAppointmentsState> emit,
  ) {
    var filtered = List<ReservedAppointment>.from(_cachedAppointments);

    if (event.statusFilter != null && event.statusFilter!.isNotEmpty) {
      filtered = filtered.where((a) => a.status == event.statusFilter).toList();
    }

    if (event.searchQuery.isNotEmpty) {
      final q = event.searchQuery.toLowerCase();
      filtered = filtered
          .where((a) => (a.branchName ?? '').toLowerCase().contains(q))
          .toList();
    }

    filtered.sort(
      (a, b) => event.sortAscending
          ? a.reservationDate.compareTo(b.reservationDate)
          : b.reservationDate.compareTo(a.reservationDate),
    );

    emit(
      UserAppointmentsLoaded(
        allAppointments: _cachedAppointments,
        filteredAppointments: filtered,
        selectedStatus: event.statusFilter,
        searchQuery: event.searchQuery,
        sortAscending: event.sortAscending,
      ),
    );
  }
}
