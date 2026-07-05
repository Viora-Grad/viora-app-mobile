import 'package:equatable/equatable.dart';
import 'package:viora_app/core/services/notification_service.dart';

/// User configuration for the "take a 5-minute workout break" reminder.
///
/// Unlike water, workout reminders are a small set of explicit daily times the
/// user picks (e.g. mid-morning and early evening).
class WorkoutReminderSettings extends Equatable {
  final bool enabled;

  /// Times of day (24h) to nudge the user. Stored as "HH:mm" strings.
  final List<String> times;

  const WorkoutReminderSettings({
    this.enabled = false,
    this.times = const ['09:00', '18:00'],
  });

  List<ReminderSlot> get slots {
    return times.map((t) {
      final parts = t.split(':');
      final hour = int.tryParse(parts.first) ?? 9;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      return ReminderSlot(hour, minute);
    }).toList();
  }

  WorkoutReminderSettings copyWith({bool? enabled, List<String>? times}) {
    return WorkoutReminderSettings(
      enabled: enabled ?? this.enabled,
      times: times ?? this.times,
    );
  }

  Map<String, dynamic> toJson() => {'enabled': enabled, 'times': times};

  factory WorkoutReminderSettings.fromJson(Map<String, dynamic> json) {
    final rawTimes = json['times'];
    return WorkoutReminderSettings(
      enabled: json['enabled'] as bool? ?? false,
      times: rawTimes is List
          ? rawTimes.map((e) => e.toString()).toList()
          : const ['09:00', '18:00'],
    );
  }

  @override
  List<Object?> get props => [enabled, times];
}
