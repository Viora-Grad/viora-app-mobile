import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/features/organization/data/datasources/remote/organization_remote.dart';
import 'package:viora_app/features/organization/data/models/organization_detail_model.dart';

class OrganizationRemoteImpl implements OrganizationRemote {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  OrganizationRemoteImpl(this.dio, this.secureStorage);

  Future<Options> _buildOptions({required bool requiresAuth}) async {
    if (!requiresAuth) {
      return Options(contentType: Headers.jsonContentType);
    }
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
  Future<OrganizationDetailModel> getOrganizationDetails(
      String organizationId) async {
    final response = await dio.get(
      '${EndPoints.organizationsUrl}/$organizationId',
      options: await _buildOptions(requiresAuth: false),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return OrganizationDetailModel.fromJson(data);
    }

    throw Exception('Unexpected response format');
  }
}
