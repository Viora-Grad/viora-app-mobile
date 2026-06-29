import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/vivi/data/models/chat_message_model.dart';
import 'package:viora_app/features/vivi/domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase _sendMessageUseCase;

  ChatBloc(this._sendMessageUseCase) : super(const ChatInitial()) {
    on<NewChatEvent>(_onNewChat);
    on<LoadSessionEvent>(_onLoadSession);
    on<SendMessageEvent>(_onSendMessage);
  }

  void _onNewChat(NewChatEvent event, Emitter<ChatState> emit) {
    emit(const ChatReady(messages: [], sessionId: null));
  }

  void _onLoadSession(LoadSessionEvent event, Emitter<ChatState> emit) {
    emit(ChatReady(messages: event.messages, sessionId: event.sessionId));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final current =
        state is ChatReady ? state as ChatReady : const ChatReady(messages: []);

    final userMsg =
        ChatMessageModel.userLocal(event.message, current.messages.length);
    final withUser = current.copyWith(
      messages: [...current.messages, userMsg],
      isSending: true,
      clearError: true,
    );
    emit(withUser);

    final result = await _sendMessageUseCase(
      message: event.message,
      sessionId: current.sessionId,
    );

    result.fold(
      (failure) {
        debugPrint('[ChatBloc] ❌ SendMessage FAILED — message="${failure.message}", statusCode=${failure is ServerFailure ? failure.statusCode : "N/A"}');
        emit(withUser.copyWith(
          isSending: false,
          errorMessage: failure.message,
        ));
      },
      (response) {
        debugPrint('[ChatBloc] ✅ SendMessage SUCCESS — sessionId=${response.sessionId}, response.length=${response.aiMessage.content.length}');
        emit(withUser.copyWith(
          messages: [...withUser.messages, response.aiMessage],
          isSending: false,
          sessionId: response.sessionId ?? current.sessionId,
        ));
      },
    );
  }
}
