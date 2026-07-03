import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';

class StaffDayScheduleModel {
  final String day;
  final String startTime;
  final String endTime;

  const StaffDayScheduleModel({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory StaffDayScheduleModel.fromJson(Map<String, dynamic> json) =>
      StaffDayScheduleModel(
        day: json['day'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
      );

  StaffDaySchedule toEntity() => StaffDaySchedule(
        day: day,
        startTime: startTime,
        endTime: endTime,
      );
}
