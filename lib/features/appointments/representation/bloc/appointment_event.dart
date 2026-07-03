import 'package:equatable/equatable.dart';

sealed class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAvailableSlots extends AppointmentEvent {
  final String branchId;
  final String staffId;
  final String serviceId;
  final int serviceDurationMinutes;
  final DateTime selectedDate;

  const LoadAvailableSlots({
    required this.branchId,
    required this.staffId,
    required this.serviceId,
    required this.serviceDurationMinutes,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [
        branchId,
        staffId,
        serviceId,
        serviceDurationMinutes,
        selectedDate,
      ];
}

final class SelectSlot extends AppointmentEvent {
  final DateTime startTime;
  final DateTime endTime;

  const SelectSlot({
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [startTime, endTime];
}

final class ConfirmBooking extends AppointmentEvent {
  final String serviceId;
  final String staffId;
  final String branchId;
  final int durationMinutes;

  const ConfirmBooking({
    required this.serviceId,
    required this.staffId,
    required this.branchId,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [serviceId, staffId, branchId, durationMinutes];
}
