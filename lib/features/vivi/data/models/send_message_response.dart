class SendMessageResponse {
  final String response;
  final String? intent;
  final String? sessionId;

  SendMessageResponse({
    required this.response,
    this.intent,
    this.sessionId,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) =>
      SendMessageResponse(
        response: json['message'] as String, // Backend returns "message" not "response"
        intent: json['intent'] as String?,
        sessionId: json['sessionId'] as String?,
      );
}
