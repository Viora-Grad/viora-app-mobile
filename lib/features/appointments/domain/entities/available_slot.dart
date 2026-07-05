import 'package:equatable/equatable.dart';

class AvailableSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;

  const AvailableSlot({
    required this.startTime,
    required this.endTime,
  });

  String get formattedStart {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedEnd {
    final hour = endTime.hour.toString().padLeft(2, '0');
    final minute = endTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  List<Object?> get props => [startTime, endTime];
}
