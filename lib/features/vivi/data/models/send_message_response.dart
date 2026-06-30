import 'package:viora_app/features/vivi/domain/entities/ai_action.dart';

class SendMessageResponse {
  final String response;
  final String? intent;
  final String? sessionId;
  final List<AiAction> actions;

  SendMessageResponse({
    required this.response,
    this.intent,
    this.sessionId,
    this.actions = const [],
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    final actions = (json['actions'] as List<dynamic>?)
            ?.map((a) => AiAction(
                  label: a['label'] as String,
                  specialty: a['specialty'] as String,
                ))
            .toList() ??
        [];

    return SendMessageResponse(
      response: json['message'] as String,
      intent: json['intent'] as String?,
      sessionId: json['sessionId'] as String?,
      actions: actions,
    );
  }
}
