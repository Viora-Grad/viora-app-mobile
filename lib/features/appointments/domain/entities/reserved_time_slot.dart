import 'package:equatable/equatable.dart';

class ReservedTimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;

  const ReservedTimeSlot({
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [startTime, endTime];
}
