import 'package:equatable/equatable.dart';

/// A candidate sleep session inferred from how long the phone was left idle
/// (the app in the background) — offered to the user to confirm and log.
class SleepSuggestion extends Equatable {
  final DateTime start;
  final DateTime end;

  const SleepSuggestion({required this.start, required this.end});

  Duration get duration => end.difference(start);

  double get durationHours => duration.inMinutes / 60.0;

  @override
  List<Object?> get props => [start, end];
}
