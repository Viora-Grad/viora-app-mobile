import 'package:viora_app/features/vivi/data/models/chat_message_model.dart';
import 'package:viora_app/features/vivi/domain/entities/session_history.dart';

class SessionHistoryModel extends SessionHistory {
  const SessionHistoryModel({
    required super.sessionId,
    super.title,
    required super.createdAt,
    required super.messages,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    final messages = (json['messages'] as List)
        .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return SessionHistoryModel(
      sessionId: json['sessionId'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: messages,
    );
  }

  SessionHistory toEntity() => SessionHistory(
        sessionId: sessionId,
        title: title,
        createdAt: createdAt,
        messages: messages.map((m) => (m as ChatMessageModel).toEntity()).toList(),
      );
}
