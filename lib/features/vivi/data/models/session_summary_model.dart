import 'package:viora_app/features/vivi/domain/entities/session_summary.dart';

class SessionSummaryModel extends SessionSummary {
  const SessionSummaryModel({
    required super.sessionId,
    super.title,
    required super.createdAt,
    required super.lastActiveAt,
  });

  factory SessionSummaryModel.fromJson(Map<String, dynamic> json) =>
      SessionSummaryModel(
        sessionId: json['sessionId'] as String,
        title: json['title'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'lastActiveAt': lastActiveAt.toIso8601String(),
      };

  SessionSummary toEntity() => SessionSummary(
        sessionId: sessionId,
        title: title,
        createdAt: createdAt,
        lastActiveAt: lastActiveAt,
      );
}
