import 'package:viora_app/features/vivi/data/models/send_message_response.dart';
import 'package:viora_app/features/vivi/data/models/session_history_model.dart';
import 'package:viora_app/features/vivi/data/models/session_summary_model.dart';

abstract class AiChatRemote {
  Future<SendMessageResponse> sendMessage({
    required String message,
    String? sessionId,
  });

  Future<List<SessionSummaryModel>> getSessions({
    int page = 1,
    int pageSize = 20,
  });

  Future<SessionHistoryModel> getSessionHistory(String sessionId);
}
