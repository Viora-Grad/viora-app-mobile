import 'package:equatable/equatable.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';

sealed class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

final class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

final class AppointmentsLoading extends AppointmentState {
  const AppointmentsLoading();
}

final class SlotsLoaded extends AppointmentState {
  final List<AvailableSlot> slots;
  final AvailableSlot? selectedSlot;
  final DateTime selectedDate;
  final bool isBooking;

  const SlotsLoaded({
    required this.slots,
    this.selectedSlot,
    required this.selectedDate,
    this.isBooking = false,
  });

  @override
  List<Object?> get props => [slots, selectedSlot, selectedDate, isBooking];

  SlotsLoaded copyWith({
    List<AvailableSlot>? slots,
    AvailableSlot? selectedSlot,
    DateTime? selectedDate,
    bool? isBooking,
    bool clearSelection = false,
  }) =>
      SlotsLoaded(
        slots: slots ?? this.slots,
        selectedSlot: clearSelection ? null : (selectedSlot ?? this.selectedSlot),
        selectedDate: selectedDate ?? this.selectedDate,
        isBooking: isBooking ?? this.isBooking,
      );
}

final class BookingSuccess extends AppointmentState {
  const BookingSuccess();
}

final class AppointmentsError extends AppointmentState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
