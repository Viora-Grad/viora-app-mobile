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

    return SendMessageResponse(
      response: json['message'] as String,
      intent: json['intent'] as String?,
      sessionId: json['sessionId'] as String?,
      actions: actions,
    );
  }
}
