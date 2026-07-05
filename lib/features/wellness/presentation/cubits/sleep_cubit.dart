import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/wellness/data/wellness_local.dart';
import 'package:viora_app/features/wellness/domain/sleep_advice.dart';
import 'package:viora_app/features/wellness/domain/sleep_entry.dart';
import 'package:viora_app/features/wellness/domain/sleep_suggestion.dart';

class SleepState extends Equatable {
  final List<SleepEntry> entries;
  final bool loading;

  /// An inferred sleep window (from phone idle time) awaiting the user's
  /// confirmation. Null when there's nothing to suggest.
  final SleepSuggestion? suggestion;

  /// Set when the user has tapped "I'm awake" but not yet "going to sleep".
  final DateTime? awakeSince;

  const SleepState({
    this.entries = const [],
    this.loading = true,
    this.suggestion,
    this.awakeSince,
  });

  SleepAdvice get advice => SleepAdvice.fromEntries(entries);

  SleepState copyWith({
    List<SleepEntry>? entries,
    bool? loading,
    SleepSuggestion? suggestion,
    bool clearSuggestion = false,
    DateTime? awakeSince,
    bool clearAwake = false,
  }) {
    return SleepState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
      suggestion: clearSuggestion ? null : (suggestion ?? this.suggestion),
      awakeSince: clearAwake ? null : (awakeSince ?? this.awakeSince),
    );
  }

  @override
  List<Object?> get props => [entries, loading, suggestion, awakeSince];
}

class SleepCubit extends Cubit<SleepState> {
  SleepCubit(this._local) : super(const SleepState());

  final WellnessLocal _local;

  /// Minimum idle stretch that we're willing to guess was sleep.
  static const Duration idleThreshold = Duration(hours: 5);

  Future<void> load() async {
    final entries = await _local.getSleepEntries();
    final suggestion = await _buildSuggestion();
    final awakeSince = await _local.getAwakeMarker();
    emit(
      SleepState(
        entries: entries,
        loading: false,
        suggestion: suggestion,
        awakeSince: awakeSince,
      ),
    );
  }

  /// Two-tap logging, step 1: user marks the moment they woke up.
  Future<void> markAwake() async {
    final now = DateTime.now();
    await _local.setAwakeMarker(now);
    emit(state.copyWith(awakeSince: now));
  }

  /// Two-tap logging, step 2: user is heading to bed. The time awake since the
  /// morning marker is one "shift"; the rest of the 24h day is counted as
  /// sleep. Returns the logged sleep duration (null if no awake marker set).
  Future<Duration?> markGoingToSleep() async {
    final awake = state.awakeSince;
    if (awake == null) return null;

    final now = DateTime.now();
    var awakeMinutes = now.difference(awake).inMinutes;
    if (awakeMinutes < 0) awakeMinutes += 1440;
    awakeMinutes %= 1440;
    final sleepMinutes = 1440 - awakeMinutes;
    final sleepDuration = Duration(minutes: sleepMinutes);

    await _local.setAwakeMarker(null);
    final updated = await _local.addSleepEntry(
      SleepEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        bedtime: now,
        wakeTime: now.add(sleepDuration),
      ),
    );
    emit(state.copyWith(entries: updated, clearAwake: true));
    return sleepDuration;
  }

  /// Injects a sample suggestion so the idle-detection prompt can be previewed
  /// on demand (demo/testing) without waiting for a real idle window.
  void demoSuggestion() {
    final now = DateTime.now();
    emit(
      state.copyWith(
        suggestion: SleepSuggestion(
          start: now.subtract(const Duration(hours: 7, minutes: 30)),
          end: now,
        ),
      ),
    );
  }

  Future<void> addEntry({
    required DateTime bedtime,
    required DateTime wakeTime,
  }) async {
    final entry = SleepEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bedtime: bedtime,
      wakeTime: wakeTime,
    );
    final updated = await _local.addSleepEntry(entry);
    emit(state.copyWith(entries: updated));
  }

  Future<void> deleteEntry(String id) async {
    final updated = await _local.deleteSleepEntry(id);
    emit(state.copyWith(entries: updated));
  }

  /// User confirmed the idle window was sleep — log it and stop suggesting it.
  Future<void> acceptSuggestion() async {
    final suggestion = state.suggestion;
    if (suggestion == null) return;
    await _local.setHandledSuggestionStart(suggestion.start);
    await addEntry(bedtime: suggestion.start, wakeTime: suggestion.end);
    emit(state.copyWith(clearSuggestion: true));
  }

  /// User said it wasn't sleep — remember so we don't ask about it again.
  Future<void> dismissSuggestion() async {
    final suggestion = state.suggestion;
    if (suggestion == null) return;
    await _local.setHandledSuggestionStart(suggestion.start);
    emit(state.copyWith(clearSuggestion: true));
  }

  Future<SleepSuggestion?> _buildSuggestion() async {
    final lastBackgrounded = await _local.getLastBackgrounded();
    if (lastBackgrounded == null) return null;

    final now = DateTime.now();
    if (now.difference(lastBackgrounded) < idleThreshold) return null;

    // Skip a window the user already answered (matched to the minute).
    final handled = await _local.getHandledSuggestionStart();
    if (handled != null &&
        (handled.difference(lastBackgrounded)).abs() <
            const Duration(minutes: 1)) {
      return null;
    }

    return SleepSuggestion(start: lastBackgrounded, end: now);
  }
}
