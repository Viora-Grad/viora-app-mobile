import 'package:flutter/foundation.dart';
import 'package:viora_app/core/api/api_consumer.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_model.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/features/vivi/data/datasources/remote/ai_chat_remote.dart';
import 'package:viora_app/features/vivi/data/models/send_message_response.dart';
import 'package:viora_app/features/vivi/data/models/session_history_model.dart';
import 'package:viora_app/features/vivi/data/models/session_summary_model.dart';

class AiChatRemoteImpl extends AiChatRemote {
  final ApiConsumer _apiConsumer;

  AiChatRemoteImpl(this._apiConsumer);

  @override
  Future<SendMessageResponse> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      debugPrint('[AiChatRemote] ===== sendMessage REQUEST =====');
      debugPrint('[AiChatRemote] URL: POST ${EndPoints.aiChatUrl}');
      debugPrint('[AiChatRemote] Body: message="$message", sessionId=$sessionId');

      final data = await _apiConsumer.post(
        EndPoints.aiChatUrl,
        data: {
          'message': message,
          if (sessionId != null) 'sessionId': sessionId, // ignore: use_null_aware_elements
        },
        requiresAuth: true,
      );

      debugPrint('[AiChatRemote] ✅ Response: $data');
      return SendMessageResponse.fromJson(data);
    } on ServerException catch (e) {
      debugPrint('[AiChatRemote] ❌ ServerException — status=${e.errorModel.statusCode}, message=${e.errorModel.errorMessage}');
      rethrow;
    } catch (e) {
      debugPrint('[AiChatRemote] ❌ Unexpected error — $e');
      throw ServerException(
        const ErrorModel(
          statusCode: 500,
          errorMessage: 'Failed to send message',
        ),
      );
    }
  }

  @override
  Future<List<SessionSummaryModel>> getSessions({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      debugPrint('[AiChatRemote] ===== getSessions REQUEST =====');
      debugPrint('[AiChatRemote] URL: GET ${EndPoints.aiSessionsUrl}?page=$page&pageSize=$pageSize');

      final data = await _apiConsumer.getRaw(
        EndPoints.aiSessionsUrl,
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
        requiresAuth: true,
      );

      debugPrint('[AiChatRemote] ✅ getSessions response: $data');

      final list = data as List;
      return list
          .map((e) =>
              SessionSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      debugPrint('[AiChatRemote] ❌ getSessions ServerException — status=${e.errorModel.statusCode}, message=${e.errorModel.errorMessage}');
      rethrow;
    } catch (e) {
      debugPrint('[AiChatRemote] ❌ getSessions Unexpected error — $e');
      throw ServerException(
        const ErrorModel(
          statusCode: 500,
          errorMessage: 'Failed to load sessions',
        ),
      );
    }
  }

  @override
  Future<SessionHistoryModel> getSessionHistory(String sessionId) async {
    try {
      debugPrint('[AiChatRemote] ===== getSessionHistory REQUEST =====');
      debugPrint('[AiChatRemote] URL: GET ${EndPoints.aiSessionsUrl}/$sessionId');

      final data = await _apiConsumer.get(
        '${EndPoints.aiSessionsUrl}/$sessionId',
        requiresAuth: true,
      );

      debugPrint('[AiChatRemote] ✅ getSessionHistory response: $data');
      return SessionHistoryModel.fromJson(data);
    } on ServerException catch (e) {
      debugPrint('[AiChatRemote] ❌ getSessionHistory ServerException — status=${e.errorModel.statusCode}, message=${e.errorModel.errorMessage}');
      rethrow;
    } catch (e) {
      debugPrint('[AiChatRemote] ❌ getSessionHistory Unexpected error — $e');
      throw ServerException(
        const ErrorModel(
          statusCode: 500,
          errorMessage: 'Failed to load session history',
        ),
      );
    }
  }
}
