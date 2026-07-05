import 'package:equatable/equatable.dart';
import 'package:viora_app/features/vivi/domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String message;
  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class LoadSessionEvent extends ChatEvent {
  final String sessionId;
  final List<ChatMessage> messages;
  const LoadSessionEvent({required this.sessionId, required this.messages});

  @override
  List<Object?> get props => [sessionId, messages];
}

class NewChatEvent extends ChatEvent {
  const NewChatEvent();
}
