import 'package:viora_app/features/vivi/domain/entities/ai_action.dart';
import 'package:viora_app/features/vivi/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.role,
    required super.content,
    required super.index,
    super.actions,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final actions = (json['actions'] as List<dynamic>?)
            ?.map((a) {
              final actionType = a['actionType'] as String? ?? 'specialty';
              return AiAction(
                label: a['label'] as String,
                actionType: actionType,
                specialty: a['specialty'] as String? ?? '',
                orgName: a['orgName'] as String?,
                country: a['country'] as String?,
                serviceType: a['serviceType'] as String?,
                minRating: (a['minRating'] as num?)?.toDouble(),
              );
            })
            .toList() ??
        [];

    return ChatMessageModel(
      role: json['role'] as String,
      content: json['content'] as String,
      index: json['index'] as int? ?? 0,
      actions: actions,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'index': index,
        if (actions.isNotEmpty)
          'actions': actions
              .map((a) => {
                    'label': a.label,
                    'actionType': a.actionType,
                    'specialty': a.specialty,
                    if (a.orgName != null) 'orgName': a.orgName,
                    if (a.country != null) 'country': a.country,
                    if (a.serviceType != null) 'serviceType': a.serviceType,
                    if (a.minRating != null) 'minRating': a.minRating,
                  })
              .toList(),
      };

  factory ChatMessageModel.fromDomain(ChatMessage message) =>
      ChatMessageModel(
        role: message.role,
        content: message.content,
        index: message.index,
        actions: message.actions,
      );

  factory ChatMessageModel.userLocal(String content, int index) =>
      ChatMessageModel(role: 'user', content: content, index: index);

  ChatMessage toEntity() => ChatMessage(
        role: role,
        content: content,
        index: index,
        actions: actions,
      );
}
