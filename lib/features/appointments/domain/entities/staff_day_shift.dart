import 'package:equatable/equatable.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_time_slot.dart';

class StaffDayShift extends Equatable {
  final String shiftId;
  final String startTime;
  final String endTime;
  final List<ReservedTimeSlot> timeReserved;

  const StaffDayShift({
    required this.shiftId,
    required this.startTime,
    required this.endTime,
    required this.timeReserved,
  });

  @override
  List<Object?> get props => [shiftId, startTime, endTime, timeReserved];
}
