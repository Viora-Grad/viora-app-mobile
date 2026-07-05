import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/features/forms/data/datasources/remote/form_remote.dart';
import 'package:viora_app/features/forms/data/models/form_model.dart';

class FormRemoteDataSourceImpl implements FormRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  FormRemoteDataSourceImpl(this.dio, this.secureStorage);

  Future<Options> _buildOptions() async {
    final token = await secureStorage.read(key: 'user_token');
    if (token == null || token.isEmpty) {
      return Options(contentType: Headers.jsonContentType);
    }
    return Options(
      contentType: Headers.jsonContentType,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<FormModel?> getServiceForm(String serviceId) async {
    try {
      final response = await dio.get(
        EndPoints.serviceFormUrl(serviceId),
        options: await _buildOptions(),
      );
      if (response.data == null) return null;
      return FormModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      handleDioException(e);
    }
  }

  @override
  Future<String> submitFormAnswers({
    required String appointmentId,
    required String formId,
    required List<AnswerModel> answers,
  }) async {
    try {
      final submission = {
        'questions': answers.map((a) => a.toJson()).toList(),
      };

      final response = await dio.post(
        EndPoints.formSubmissionUrl(appointmentId),
        data: {
          'formId': formId,
          'submission': submission,
        },
        options: await _buildOptions(),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('id')) {
        return data['id'] as String;
      }
      if (data is String) return data;
      return response.data.toString();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<void> uploadFormFile({
    required String formSubmissionId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final token = await secureStorage.read(key: 'user_token');
      final options = Options(
        contentType: Headers.multipartFormDataContentType,
        headers: token != null && token.isNotEmpty
            ? {'Authorization': 'Bearer $token'}
            : null,
      );

      await dio.post(
        EndPoints.formFileUploadUrl(formSubmissionId),
        data: formData,
        options: options,
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
