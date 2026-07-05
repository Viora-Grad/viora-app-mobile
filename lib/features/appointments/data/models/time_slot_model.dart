import 'package:viora_app/features/appointments/domain/entities/reserved_time_slot.dart';

class TimeSlotModel {
  final DateTime startTime;
  final DateTime endTime;

  const TimeSlotModel({
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) => TimeSlotModel(
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
      );

  ReservedTimeSlot toEntity() =>
      ReservedTimeSlot(startTime: startTime, endTime: endTime);
}
