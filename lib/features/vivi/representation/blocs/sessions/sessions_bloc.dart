import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/vivi/domain/usecases/get_session_history_usecase.dart';
import 'package:viora_app/features/vivi/domain/usecases/get_sessions_usecase.dart';
import 'sessions_event.dart';
import 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final GetSessionsUseCase _getSessionsUseCase;
  final GetSessionHistoryUseCase _getSessionHistoryUseCase;

  SessionsBloc(
    this._getSessionsUseCase,
    this._getSessionHistoryUseCase,
  ) : super(const SessionsInitial()) {
    on<LoadSessionsEvent>(_onLoad);
    on<OpenSessionEvent>(_onOpen);
  }

  Future<void> _onLoad(
    LoadSessionsEvent event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());
    final result = await _getSessionsUseCase();
    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (sessions) => emit(SessionsLoaded(sessions)),
    );
  }

  Future<void> _onOpen(
    OpenSessionEvent event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());
    final result =
        await _getSessionHistoryUseCase(event.session.sessionId);
    result.fold(
      (failure) => emit(SessionsError(failure.message)),
      (history) => emit(SessionHistoryLoaded(history)),
    );
  }
}
