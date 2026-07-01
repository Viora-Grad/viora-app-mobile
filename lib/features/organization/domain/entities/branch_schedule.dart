import 'package:equatable/equatable.dart';

class BranchSchedule extends Equatable {
  final String day;
  final List<Shift> shifts;

  const BranchSchedule({required this.day, required this.shifts});

  @override
  List<Object?> get props => [day, shifts];
}

class Shift extends Equatable {
  final String staffId;
  final String startTime;
  final String endTime;

  const Shift({
    required this.staffId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [staffId, startTime, endTime];
}
