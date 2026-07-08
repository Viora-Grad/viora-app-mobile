import 'package:equatable/equatable.dart';

class StaffShift extends Equatable {
  final String staffId;
  final String day;
  final String startTime;
  final String endTime;

  const StaffShift({
    required this.staffId,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [staffId, day, startTime, endTime];
}
