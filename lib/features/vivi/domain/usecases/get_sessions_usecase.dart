import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../entities/session_summary.dart';
import '../repositories/ai_chat_repository.dart';

class GetSessionsUseCase {
  final AiChatRepository _repository;

  GetSessionsUseCase(this._repository);

  Future<Either<Failure, List<SessionSummary>>> call({
    int page = 1,
    int pageSize = 20,
  }) =>
      _repository.getSessions(page: page, pageSize: pageSize);
}
