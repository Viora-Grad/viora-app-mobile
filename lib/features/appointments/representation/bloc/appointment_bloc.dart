import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';
import 'package:viora_app/features/appointments/domain/usecases/book_appointment.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_available_slots.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_event.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetAvailableSlotsUseCase getAvailableSlots;
  final BookAppointmentUseCase bookAppointment;

  AppointmentBloc({
    required this.getAvailableSlots,
    required this.bookAppointment,
  }) : super(const AppointmentInitial()) {
    on<LoadAvailableSlots>(_onLoadAvailableSlots);
    on<SelectSlot>(_onSelectSlot);
    on<ConfirmBooking>(_onConfirmBooking);
  }

  Future<void> _onLoadAvailableSlots(
    LoadAvailableSlots event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentsLoading());

    final result = await getAvailableSlots(
      branchId: event.branchId,
      staffId: event.staffId,
      serviceId: event.serviceId,
      serviceDurationMinutes: event.serviceDurationMinutes,
      selectedDate: event.selectedDate,
    );

    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (slots) => emit(SlotsLoaded(
        slots: slots,
        selectedDate: event.selectedDate,
      )),
    );
  }

  void _onSelectSlot(
    SelectSlot event,
    Emitter<AppointmentState> emit,
  ) {
    final current = state;
    if (current is SlotsLoaded) {
      emit(current.copyWith(
        selectedSlot: AvailableSlot(
          startTime: event.startTime,
          endTime: event.endTime,
        ),
      ));
    }
  }

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! SlotsLoaded || current.selectedSlot == null) return;

    emit(current.copyWith(isBooking: true));

    final result = await bookAppointment(
      serviceId: event.serviceId,
      staffId: event.staffId,
      branchId: event.branchId,
      reservationDate: current.selectedSlot!.startTime,
      durationMinutes: event.durationMinutes,
    );

    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (_) => emit(const BookingSuccess()),
    );
  }
}
