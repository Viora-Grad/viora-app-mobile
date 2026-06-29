import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/features/search/data/datasources/remote/search_remote.dart';
import 'package:viora_app/features/search/data/models/branch_model.dart';
import 'package:viora_app/features/search/data/models/organization_model.dart';

class SearchRemoteImpl implements SearchRemote {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  SearchRemoteImpl(this.dio, this.secureStorage);

  Future<Options?> _buildOptions({required bool requiresAuth}) async {
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
  Future<PaginatedOrganizationsModel> searchOrganizations({
    String? name,
    String? country,
    String? serviceType,
    double minimumRating = 0.0,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (name != null && name.isNotEmpty) queryParameters['name'] = name;
    if (country != null && country.isNotEmpty) {
      queryParameters['country'] = country;
    }
    if (serviceType != null && serviceType.isNotEmpty) {
      queryParameters['serviceType'] = serviceType;
    }
    if (minimumRating > 0) {
      queryParameters['minimumRating'] = minimumRating;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParameters['sortBy'] = sortBy;
    }

    final response = await dio.get(
      EndPoints.organizationsUrl,
      queryParameters: queryParameters,
      options: await _buildOptions(requiresAuth: false),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return PaginatedOrganizationsModel.fromJson(data);
    }

    throw Exception('Unexpected response format');
  }

  @override
  Future<PaginatedBranchesModel> searchBranches({
    double? latitude,
    double? longitude,
    double? distanceWithinMeters,
    List<String>? servicesFilter,
    double minimumRating = 0.0,
    List<String>? orderBy,
    bool? isCurrentlyOpen,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (latitude != null) queryParameters['latitude'] = latitude;
    if (longitude != null) queryParameters['longitude'] = longitude;
    if (distanceWithinMeters != null) {
      queryParameters['distanceWithinMeters'] = distanceWithinMeters;
    }
    if (servicesFilter != null && servicesFilter.isNotEmpty) {
      queryParameters['servicesFilter'] = servicesFilter;
    }
    if (minimumRating > 0) {
      queryParameters['minimumRating'] = minimumRating;
    }
    if (orderBy != null && orderBy.isNotEmpty) {
      queryParameters['orderBy'] = orderBy;
    }
    if (isCurrentlyOpen != null) {
      queryParameters['isCurrentlyOpen'] = isCurrentlyOpen;
    }

    debugPrint('[SearchRemote] ===== searchBranches REQUEST =====');
    debugPrint('[SearchRemote] URL: GET ${EndPoints.branchesUrl}');
    debugPrint('[SearchRemote] Query params: $queryParameters');

    final response = await dio.get(
      EndPoints.branchesUrl,
      queryParameters: queryParameters,
      options: await _buildOptions(requiresAuth: false),
    );

    debugPrint('[SearchRemote] ✅ Response status: ${response.statusCode}');
    debugPrint('[SearchRemote] Response data (first 500 chars): ${response.data.toString().length > 500 ? response.data.toString().substring(0, 500) : response.data}');

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final model = PaginatedBranchesModel.fromJson(data);
      debugPrint('[SearchRemote] Parsed ${model.items.length} branches (total: ${model.totalCount})');
      return model;
    }

    debugPrint('[SearchRemote] ❌ Unexpected response format — data type: ${data.runtimeType}');
    throw Exception('Unexpected response format');
  }

  @override
  Future<List<String>> getCountries() async {
    final response = await dio.get(
      EndPoints.countriesUrl,
      options: await _buildOptions(requiresAuth: false),
    );

    final data = response.data;
    if (data is List) {
      return data.map((e) {
        if (e is Map<String, dynamic>) {
          return e['name'] as String? ?? '';
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return [];
  }

  @override
  Future<List<String>> getServiceTypes() async {
    final response = await dio.get(
      EndPoints.serviceTypesUrl,
      options: await _buildOptions(requiresAuth: false),
    );

    final data = response.data;
    if (data is List) {
      return data.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }

    return [];
  }
}
