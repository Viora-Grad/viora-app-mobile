import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../entities/session_history.dart';
import '../repositories/ai_chat_repository.dart';

class GetSessionHistoryUseCase {
  final AiChatRepository _repository;

  GetSessionHistoryUseCase(this._repository);

  Future<Either<Failure, SessionHistory>> call(String sessionId) =>
      _repository.getSessionHistory(sessionId);
}
