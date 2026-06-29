import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import '../entities/send_message_result.dart';
import '../repositories/ai_chat_repository.dart';

class SendMessageUseCase {
  final AiChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<Either<Failure, SendMessageResult>> call({
    required String message,
    String? sessionId,
  }) =>
      _repository.sendMessage(message: message, sessionId: sessionId);
}
