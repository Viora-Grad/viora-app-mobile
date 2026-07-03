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

  const SleepState({
    this.entries = const [],
    this.loading = true,
    this.suggestion,
  });

  SleepAdvice get advice => SleepAdvice.fromEntries(entries);

  SleepState copyWith({
    List<SleepEntry>? entries,
    bool? loading,
    SleepSuggestion? suggestion,
    bool clearSuggestion = false,
  }) {
    return SleepState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
      suggestion: clearSuggestion ? null : (suggestion ?? this.suggestion),
    );
  }

  @override
  List<Object?> get props => [entries, loading, suggestion];
}

class SleepCubit extends Cubit<SleepState> {
  SleepCubit(this._local) : super(const SleepState());

  final WellnessLocal _local;

  /// Minimum idle stretch that we're willing to guess was sleep.
  static const Duration idleThreshold = Duration(hours: 5);

  Future<void> load() async {
    final entries = await _local.getSleepEntries();
    final suggestion = await _buildSuggestion();
    emit(SleepState(entries: entries, loading: false, suggestion: suggestion));
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
