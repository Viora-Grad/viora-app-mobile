import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class SendMessageResult extends Equatable {
  final ChatMessage aiMessage;
  final String? sessionId;

  const SendMessageResult({
    required this.aiMessage,
    this.sessionId,
  });

  @override
  List<Object?> get props => [aiMessage, sessionId];
}
