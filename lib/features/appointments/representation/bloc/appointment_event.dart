import 'package:equatable/equatable.dart';

sealed class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

final class LoadDoctorAppointments extends AppointmentEvent {
  final String branchId;
  final String staffId;
  final int serviceDurationMinutes;
  final DateTime selectedDate;

  const LoadDoctorAppointments({
    required this.branchId,
    required this.staffId,
    required this.serviceDurationMinutes,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [
        branchId,
        staffId,
        serviceDurationMinutes,
        selectedDate,
      ];
}

final class SetAppointmentTime extends AppointmentEvent {
  final DateTime startTime;

  const SetAppointmentTime({required this.startTime});

  @override
  List<Object?> get props => [startTime];
}

final class ConfirmBooking extends AppointmentEvent {
  final String serviceId;
  final String staffId;
  final String branchId;
  final int durationMinutes;
  final String paymentMethod;

  const ConfirmBooking({
    required this.serviceId,
    required this.staffId,
    required this.branchId,
    required this.durationMinutes,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        serviceId,
        staffId,
        branchId,
        durationMinutes,
        paymentMethod,
      ];
}
