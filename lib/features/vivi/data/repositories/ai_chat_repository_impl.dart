import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/features/vivi/data/datasources/remote/ai_chat_remote.dart';
import 'package:viora_app/features/vivi/data/models/chat_message_model.dart';
import 'package:viora_app/features/vivi/domain/entities/send_message_result.dart';
import 'package:viora_app/features/vivi/domain/entities/session_history.dart';
import 'package:viora_app/features/vivi/domain/entities/session_summary.dart';
import 'package:viora_app/features/vivi/domain/repositories/ai_chat_repository.dart';

class AiChatRepositoryImpl extends AiChatRepository {
  final AiChatRemote _remote;

  AiChatRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, SendMessageResult>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      final response = await _remote.sendMessage(
        message: message,
        sessionId: sessionId,
      );
      final aiMessage = ChatMessageModel(
        role: 'assistant',
        content: response.response,
        index: 0,
      );
      return Right(SendMessageResult(
        aiMessage: aiMessage,
        sessionId: response.sessionId,
      ));
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<SessionSummary>>> getSessions({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final models = await _remote.getSessions(page: page, pageSize: pageSize);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, SessionHistory>> getSessionHistory(
    String sessionId,
  ) async {
    try {
      final model = await _remote.getSessionHistory(sessionId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
