import 'package:equatable/equatable.dart';
import 'package:viora_app/core/services/notification_service.dart';

/// User configuration for the water-drinking reminder.
///
/// Reminders fire every [intervalHours] between [startHour] and [endHour]
/// (24h clock), so the user isn't woken up overnight.
class WaterReminderSettings extends Equatable {
  final bool enabled;
  final int intervalHours;
  final int startHour;
  final int endHour;

  const WaterReminderSettings({
    this.enabled = false,
    this.intervalHours = 2,
    this.startHour = 8,
    this.endHour = 22,
  });

  static const List<int> intervalOptions = [1, 2, 3];

  /// Concrete times of day the reminder will fire, derived from the window.
  List<ReminderSlot> get slots {
    final result = <ReminderSlot>[];
    final step = intervalHours <= 0 ? 1 : intervalHours;
    for (var hour = startHour; hour <= endHour; hour += step) {
      result.add(ReminderSlot(hour, 0));
    }
    return result;
  }

  WaterReminderSettings copyWith({
    bool? enabled,
    int? intervalHours,
    int? startHour,
    int? endHour,
  }) {
    return WaterReminderSettings(
      enabled: enabled ?? this.enabled,
      intervalHours: intervalHours ?? this.intervalHours,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'intervalHours': intervalHours,
    'startHour': startHour,
    'endHour': endHour,
  };

  factory WaterReminderSettings.fromJson(Map<String, dynamic> json) {
    return WaterReminderSettings(
      enabled: json['enabled'] as bool? ?? false,
      intervalHours: json['intervalHours'] as int? ?? 2,
      startHour: json['startHour'] as int? ?? 8,
      endHour: json['endHour'] as int? ?? 22,
    );
  }

  @override
  List<Object?> get props => [enabled, intervalHours, startHour, endHour];
}
