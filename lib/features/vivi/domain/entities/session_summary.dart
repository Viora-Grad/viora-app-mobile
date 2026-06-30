import 'package:equatable/equatable.dart';

class SessionSummary extends Equatable {
  final String sessionId;
  final String? title;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const SessionSummary({
    required this.sessionId,
    this.title,
    required this.createdAt,
    required this.lastActiveAt,
  });

  String get displayTitle =>
      (title != null && title!.isNotEmpty) ? title! : 'New conversation';

  @override
  List<Object?> get props => [sessionId, title, lastActiveAt];
}
