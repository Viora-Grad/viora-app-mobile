import 'package:equatable/equatable.dart';
import 'package:viora_app/features/vivi/domain/entities/session_summary.dart';

abstract class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessionsEvent extends SessionsEvent {
  const LoadSessionsEvent();
}

class OpenSessionEvent extends SessionsEvent {
  final SessionSummary session;
  const OpenSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}
