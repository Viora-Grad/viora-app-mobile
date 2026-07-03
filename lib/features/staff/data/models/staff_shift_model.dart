import 'package:viora_app/features/staff/domain/entities/staff_shift.dart';

class StaffShiftModel {
  final String staffId;
  final String day;
  final String startTime;
  final String endTime;

  const StaffShiftModel({
    required this.staffId,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory StaffShiftModel.fromJson(Map<String, dynamic> json) =>
      StaffShiftModel(
        staffId: json['staffId'] as String? ?? '',
        day: json['day'] as String? ?? '',
        startTime: json['startTime'] as String? ?? '',
        endTime: json['endTime'] as String? ?? '',
      );

  StaffShift toEntity() => StaffShift(
        staffId: staffId,
        day: day,
        startTime: startTime,
        endTime: endTime,
      );
}
