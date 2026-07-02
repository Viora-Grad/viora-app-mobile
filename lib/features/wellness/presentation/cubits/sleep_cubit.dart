import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/wellness/data/wellness_local.dart';
import 'package:viora_app/features/wellness/domain/sleep_advice.dart';
import 'package:viora_app/features/wellness/domain/sleep_entry.dart';

class SleepState extends Equatable {
  final List<SleepEntry> entries;
  final bool loading;

  const SleepState({this.entries = const [], this.loading = true});

  SleepAdvice get advice => SleepAdvice.fromEntries(entries);

  SleepState copyWith({List<SleepEntry>? entries, bool? loading}) {
    return SleepState(
      entries: entries ?? this.entries,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [entries, loading];
}

class SleepCubit extends Cubit<SleepState> {
  SleepCubit(this._local) : super(const SleepState());

  final WellnessLocal _local;

  Future<void> load() async {
    final entries = await _local.getSleepEntries();
    emit(SleepState(entries: entries, loading: false));
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
}
