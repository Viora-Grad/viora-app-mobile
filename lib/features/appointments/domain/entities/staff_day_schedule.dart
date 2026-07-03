import 'package:equatable/equatable.dart';

class StaffDaySchedule extends Equatable {
  final String day;
  final String startTime;
  final String endTime;

  const StaffDaySchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [day, startTime, endTime];
}
