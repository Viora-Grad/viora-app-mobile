import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';

class StaffDayScheduleModel {
  final String id;
  final String day;
  final String startTime;
  final String endTime;

  const StaffDayScheduleModel({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory StaffDayScheduleModel.fromJson(Map<String, dynamic> json) =>
      StaffDayScheduleModel(
        id: json['id'] as String? ?? '',
        day: json['day'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
      );

  StaffDaySchedule toEntity() => StaffDaySchedule(
        id: id,
        day: day,
        startTime: startTime,
        endTime: endTime,
      );
}
