import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../entities/send_message_result.dart';
import '../entities/session_history.dart';
import '../entities/session_summary.dart';

abstract class AiChatRepository {
  Future<Either<Failure, SendMessageResult>> sendMessage({
    required String message,
    String? sessionId,
  });

  Future<Either<Failure, List<SessionSummary>>> getSessions({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, SessionHistory>> getSessionHistory(
    String sessionId,
  );
}
