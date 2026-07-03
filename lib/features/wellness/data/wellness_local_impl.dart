import 'dart:convert';

import 'package:viora_app/core/database/cache/cache_helper.dart';
import 'package:viora_app/features/wellness/data/wellness_local.dart';
import 'package:viora_app/features/wellness/domain/sleep_entry.dart';
import 'package:viora_app/features/wellness/domain/water_reminder_settings.dart';
import 'package:viora_app/features/wellness/domain/workout_reminder_settings.dart';

class WellnessLocalImpl implements WellnessLocal {
  WellnessLocalImpl(this._cache);

  final CacheHelper _cache;

  static const String _waterKey = 'wellness_water_settings';
  static const String _workoutKey = 'wellness_workout_settings';
  static const String _sleepKey = 'wellness_sleep_entries';
  static const String _lastBackgroundedKey = 'wellness_last_backgrounded_ms';
  static const String _handledSuggestionKey = 'wellness_handled_suggestion_ms';

  /// Only the most recent sessions are kept in cache.
  static const int maxSleepEntries = 30;

  @override
  Future<WaterReminderSettings> getWaterSettings() async {
    final raw = await _cache.getData(_waterKey);
    if (raw is String && raw.isNotEmpty) {
      return WaterReminderSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    return const WaterReminderSettings();
  }

  @override
  Future<void> saveWaterSettings(WaterReminderSettings settings) async {
    await _cache.saveData(_waterKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<WorkoutReminderSettings> getWorkoutSettings() async {
    final raw = await _cache.getData(_workoutKey);
    if (raw is String && raw.isNotEmpty) {
      return WorkoutReminderSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    }
    return const WorkoutReminderSettings();
  }

  @override
  Future<void> saveWorkoutSettings(WorkoutReminderSettings settings) async {
    await _cache.saveData(_workoutKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<List<SleepEntry>> getSleepEntries() async {
    final raw = await _cache.getData(_sleepKey);
    if (raw is List<String>) {
      return raw
          .map((s) => SleepEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<List<SleepEntry>> addSleepEntry(SleepEntry entry) async {
    final entries = await getSleepEntries();
    // Newest first, capped so cache never grows unbounded.
    final updated = [entry, ...entries];
    if (updated.length > maxSleepEntries) {
      updated.removeRange(maxSleepEntries, updated.length);
    }
    await _persistSleep(updated);
    return updated;
  }

  @override
  Future<List<SleepEntry>> deleteSleepEntry(String id) async {
    final entries = await getSleepEntries();
    entries.removeWhere((e) => e.id == id);
    await _persistSleep(entries);
    return entries;
  }

  Future<void> _persistSleep(List<SleepEntry> entries) async {
    final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await _cache.saveData(_sleepKey, jsonList);
  }

  @override
  Future<void> setLastBackgrounded(DateTime time) async {
    await _cache.saveData(_lastBackgroundedKey, time.millisecondsSinceEpoch);
  }

  @override
  Future<DateTime?> getLastBackgrounded() => _readTimestamp(_lastBackgroundedKey);

  @override
  Future<void> setHandledSuggestionStart(DateTime start) async {
    await _cache.saveData(_handledSuggestionKey, start.millisecondsSinceEpoch);
  }

  @override
  Future<DateTime?> getHandledSuggestionStart() =>
      _readTimestamp(_handledSuggestionKey);

  Future<DateTime?> _readTimestamp(String key) async {
    final raw = await _cache.getData(key);
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    return null;
  }
}
