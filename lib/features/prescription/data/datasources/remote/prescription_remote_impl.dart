import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/features/prescription/data/datasources/remote/prescription_remote.dart';
import 'package:viora_app/features/prescription/data/models/prescription_model.dart';

class PrescriptionRemoteDataSourceImpl implements PrescriptionRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  PrescriptionRemoteDataSourceImpl(this.dio, this.secureStorage);

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
  Future<PrescriptionModel> getPrescriptionByAppointment(
    String appointmentId,
  ) async {
    try {
      final response = await dio.get(
        EndPoints.prescriptionByAppointmentUrl(appointmentId),
        options: await _buildOptions(),
      );
      debugPrint('=== GET /api/prescription/appointment/$appointmentId ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      debugPrint('===================================================');
      final data = response.data as Map<String, dynamic>;
      return PrescriptionModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('=== GET /api/prescription/appointment/$appointmentId ERROR ===');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Body: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('======================================================');
      handleDioException(e);
    }
  }
}
