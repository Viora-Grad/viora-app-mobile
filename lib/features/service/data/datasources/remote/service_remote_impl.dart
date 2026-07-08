import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/features/service/data/datasources/remote/service_remote.dart';
import 'package:viora_app/features/service/data/models/service_model.dart';

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ServiceRemoteDataSourceImpl(this.dio, this.secureStorage);

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
  Future<List<ServiceModel>> getServicesByBranch(String branchId) async {
    try {
      final response = await dio.get(
        EndPoints.servicesByBranchUrl(branchId),
        options: await _buildOptions(),
      );

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
