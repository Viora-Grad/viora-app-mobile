import 'package:viora_app/features/appointments/data/models/time_slot_model.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_shift.dart';

class StaffDayShiftModel {
  final String shiftId;
  final String scheduleId;
  final String staffId;
  final String startTime;
  final String endTime;
  final List<TimeSlotModel> timeReserved;

  const StaffDayShiftModel({
    required this.shiftId,
    required this.scheduleId,
    required this.staffId,
    required this.startTime,
    required this.endTime,
    required this.timeReserved,
  });

  factory StaffDayShiftModel.fromJson(Map<String, dynamic> json) {
    final reserved = json['timeReserved'] as List<dynamic>? ?? [];
    return StaffDayShiftModel(
      shiftId: json['shiftId'] as String? ?? '',
      scheduleId: json['scheduleId'] as String? ?? '',
      staffId: json['staffId'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      timeReserved: reserved
          .map((e) => TimeSlotModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  StaffDayShift toEntity() => StaffDayShift(
        shiftId: shiftId,
        startTime: startTime,
        endTime: endTime,
        timeReserved:
            timeReserved.map((t) => t.toEntity()).toList(),
      );
}
