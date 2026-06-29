import 'package:viora_app/features/vivi/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.role,
    required super.content,
    required super.index,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        role: json['role'] as String,
        content: json['content'] as String,
        index: json['index'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'index': index,
      };

  factory ChatMessageModel.fromDomain(ChatMessage message) =>
      ChatMessageModel(
        role: message.role,
        content: message.content,
        index: message.index,
      );

  factory ChatMessageModel.userLocal(String content, int index) =>
      ChatMessageModel(role: 'user', content: content, index: index);

  ChatMessage toEntity() => ChatMessage(
        role: role,
        content: content,
        index: index,
      );
}
