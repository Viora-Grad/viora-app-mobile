import 'package:viora_app/features/wellness/domain/sleep_entry.dart';
import 'package:viora_app/features/wellness/domain/water_reminder_settings.dart';
import 'package:viora_app/features/wellness/domain/workout_reminder_settings.dart';

/// Local persistence for the wellness features (reminder settings + sleep log).
abstract class WellnessLocal {
  Future<WaterReminderSettings> getWaterSettings();
  Future<void> saveWaterSettings(WaterReminderSettings settings);

  Future<WorkoutReminderSettings> getWorkoutSettings();
  Future<void> saveWorkoutSettings(WorkoutReminderSettings settings);

  /// Sleep entries, newest first, capped at [WellnessLocalImpl.maxSleepEntries].
  Future<List<SleepEntry>> getSleepEntries();
  Future<List<SleepEntry>> addSleepEntry(SleepEntry entry);
  Future<List<SleepEntry>> deleteSleepEntry(String id);
}
