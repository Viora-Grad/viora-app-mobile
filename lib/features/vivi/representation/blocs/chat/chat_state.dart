import 'package:equatable/equatable.dart';
import 'package:viora_app/features/vivi/domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatReady extends ChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? sessionId;
  final String? errorMessage;

  const ChatReady({
    required this.messages,
    this.isSending = false,
    this.sessionId,
    this.errorMessage,
  });

  ChatReady copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? sessionId,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ChatReady(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        sessionId: sessionId ?? this.sessionId,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [messages, isSending, sessionId, errorMessage];
}
