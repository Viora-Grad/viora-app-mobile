import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class SessionHistory extends Equatable {
  final String sessionId;
  final String? title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  const SessionHistory({
    required this.sessionId,
    this.title,
    required this.createdAt,
    required this.messages,
  });

  @override
  List<Object?> get props => [sessionId, title, createdAt, messages];
}
