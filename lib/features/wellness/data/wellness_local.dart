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

  /// Records the moment the app was last put in the background — used to
  /// estimate how long the phone stayed idle (a possible sleep window).
  Future<void> setLastBackgrounded(DateTime time);
  Future<DateTime?> getLastBackgrounded();

  /// Remembers the start of the last idle window the user already answered on
  /// (logged or dismissed), so the same suggestion isn't shown again.
  Future<void> setHandledSuggestionStart(DateTime start);
  Future<DateTime?> getHandledSuggestionStart();

  /// The "I'm awake" marker for two-tap logging: set when the user wakes,
  /// cleared (pass null) once they mark going to sleep.
  Future<void> setAwakeMarker(DateTime? time);
  Future<DateTime?> getAwakeMarker();
}
