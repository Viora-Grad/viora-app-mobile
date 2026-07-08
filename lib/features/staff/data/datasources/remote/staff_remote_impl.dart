import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/features/staff/data/datasources/remote/staff_remote.dart';
import 'package:viora_app/features/staff/data/models/staff_model.dart';

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  StaffRemoteDataSourceImpl(this.dio, this.secureStorage);

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
  Future<List<StaffModel>> getStaffByBranchService(
    String branchId,
    String serviceId,
  ) async {
    try {
      final response = await dio.get(
        EndPoints.staffByBranchServiceUrl(branchId, serviceId),
        options: await _buildOptions(),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => StaffModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
