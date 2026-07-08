import 'package:equatable/equatable.dart';
import 'package:viora_app/features/vivi/domain/entities/session_history.dart';
import 'package:viora_app/features/vivi/domain/entities/session_summary.dart';

abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];
}

class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

class SessionsLoaded extends SessionsState {
  final List<SessionSummary> sessions;
  const SessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionsError extends SessionsState {
  final String message;
  const SessionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SessionHistoryLoaded extends SessionsState {
  final SessionHistory history;
  const SessionHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}
