import 'package:equatable/equatable.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';

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

final class DoctorAppointmentsLoaded extends AppointmentState {
  final List<ReservedAppointment> reservedAppointments;
  final DateTime selectedDate;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final DateTime? manualStartTime;
  final DateTime? calculatedEndTime;
  final String? conflictMessage;
  final bool isBooking;

  const DoctorAppointmentsLoaded({
    required this.reservedAppointments,
    required this.selectedDate,
    this.shiftStartTime,
    this.shiftEndTime,
    this.manualStartTime,
    this.calculatedEndTime,
    this.conflictMessage,
    this.isBooking = false,
  });

  @override
  List<Object?> get props => [
        reservedAppointments,
        selectedDate,
        shiftStartTime ?? '',
        shiftEndTime ?? '',
        manualStartTime,
        calculatedEndTime,
        conflictMessage ?? '',
        isBooking,
      ];

  DoctorAppointmentsLoaded copyWith({
    List<ReservedAppointment>? reservedAppointments,
    DateTime? selectedDate,
    String? shiftStartTime,
    String? shiftEndTime,
    DateTime? manualStartTime,
    DateTime? calculatedEndTime,
    String? conflictMessage,
    bool? isBooking,
    bool clearTime = false,
  }) =>
      DoctorAppointmentsLoaded(
        reservedAppointments:
            reservedAppointments ?? this.reservedAppointments,
        selectedDate: selectedDate ?? this.selectedDate,
        shiftStartTime: shiftStartTime ?? this.shiftStartTime,
        shiftEndTime: shiftEndTime ?? this.shiftEndTime,
        manualStartTime:
            clearTime ? null : (manualStartTime ?? this.manualStartTime),
        calculatedEndTime:
            clearTime ? null : (calculatedEndTime ?? this.calculatedEndTime),
        conflictMessage: conflictMessage,
        isBooking: isBooking ?? this.isBooking,
      );
}

final class BookingSuccess extends AppointmentState {
  final String appointmentId;

  const BookingSuccess({required this.appointmentId});

  @override
  List<Object?> get props => [appointmentId];
}

final class AppointmentsError extends AppointmentState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
