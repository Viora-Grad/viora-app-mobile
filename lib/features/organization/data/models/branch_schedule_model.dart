import 'package:viora_app/features/organization/domain/entities/branch_schedule.dart';

class BranchScheduleModel {
  final String day;
  final List<ShiftModel> shifts;

  const BranchScheduleModel({required this.day, required this.shifts});

  factory BranchScheduleModel.fromJson(Map<String, dynamic> json) {
    return BranchScheduleModel(
      day: json['day']?.toString() ?? '',
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((e) => ShiftModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  BranchSchedule toEntity() => BranchSchedule(
        day: day,
        shifts: shifts.map((s) => s.toEntity()).toList(),
      );
}

class ShiftModel {
  final String staffId;
  final String startTime;
  final String endTime;

  const ShiftModel({
    required this.staffId,
    required this.startTime,
    required this.endTime,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      staffId: json['staffId']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
    );
  }

  Shift toEntity() => Shift(
        staffId: staffId,
        startTime: startTime,
        endTime: endTime,
      );
}
