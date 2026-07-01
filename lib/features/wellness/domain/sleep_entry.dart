import 'package:equatable/equatable.dart';

/// A single manually-logged sleep session.
class SleepEntry extends Equatable {
  final String id;
  final DateTime bedtime;
  final DateTime wakeTime;

  const SleepEntry({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
  });

  /// Total sleep duration. If [wakeTime] is not after [bedtime] we assume the
  /// session crossed midnight and add a day.
  Duration get duration {
    var end = wakeTime;
    if (!end.isAfter(bedtime)) {
      end = end.add(const Duration(days: 1));
    }
    return end.difference(bedtime);
  }

  double get durationHours => duration.inMinutes / 60.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'bedtime': bedtime.toIso8601String(),
    'wakeTime': wakeTime.toIso8601String(),
  };

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      id: json['id'] as String,
      bedtime: DateTime.parse(json['bedtime'] as String),
      wakeTime: DateTime.parse(json['wakeTime'] as String),
    );
  }

  @override
  List<Object?> get props => [id, bedtime, wakeTime];
}
