import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/features/appointments/data/datasources/remote/appointment_remote.dart';
import 'package:viora_app/features/appointments/data/models/reserved_appointment_model.dart';
import 'package:viora_app/features/appointments/data/models/staff_day_schedule_model.dart';
import 'package:viora_app/features/appointments/data/models/staff_day_shift_model.dart';

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AppointmentRemoteDataSourceImpl(this.dio, this.secureStorage);

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
  Future<List<StaffDayScheduleModel>> getStaffSchedule(
    String branchId,
    String staffId,
  ) async {
    try {
      final response = await dio.get(
        EndPoints.staffScheduleUrl(branchId, staffId),
        options: await _buildOptions(),
      );

      final data = response.data;
      debugPrint('=== GET Staff Schedule Response ===');
      debugPrint('URL: ${EndPoints.staffScheduleUrl(branchId, staffId)}');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: $data');
      debugPrint('===================================');

      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => StaffDayScheduleModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      handleDioException(e);
    }
  }

  @override
  Future<List<ReservedAppointmentModel>> getDoctorAppointments(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await dio.get(
        EndPoints.doctorAppointmentsUrl(doctorId),
        queryParameters: {
          'ReservationDate': dateStr,
          'pageSize': 100,
        },
        options: await _buildOptions(),
      );

      debugPrint('=== GET Doctor Appointments Response ===');
      debugPrint('URL: ${EndPoints.doctorAppointmentsUrl(doctorId)}');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.data}');
      debugPrint('=========================================');

      final data = response.data;
      if (data is! Map<String, dynamic>) return [];

      final items = data['items'] as List? ?? [];
      final now = DateTime.now();
      return items
          .map((e) =>
              ReservedAppointmentModel.fromJson(e as Map<String, dynamic>))
          .where((a) =>
              a.reservationDate.isAfter(now) ||
              a.reservationDate.day == date.day)
          .toList();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<StaffDayShiftModel> getStaffDayShift({
    required String staffId,
    required String shiftId,
    required DateTime day,
  }) async {
    final dayStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final response = await dio.get(
      EndPoints.staffDayShiftUrl(
        staffId: staffId,
        shiftId: shiftId,
        day: dayStr,
      ),
      options: await _buildOptions(),
    );
    final data = response.data as Map<String, dynamic>;
    return StaffDayShiftModel.fromJson(data);
  }

  @override
  Future<String> createAppointment({
    required String serviceId,
    required String staffId,
    required String branchId,
    required DateTime reservationDate,
    required int durationMinutes,
    required String paymentMethod,
    required String createdBy,
    required String requestPlatform,
  }) async {
    try {
      final durationStr = _formatDuration(durationMinutes);
      final response = await dio.post(
        EndPoints.createAppointmentUrl,
        data: {
          'serviceId': serviceId,
          'staffId': staffId,
          'branchId': branchId,
          'reservationDate': reservationDate.toIso8601String(),
          'paymentMethod': paymentMethod,
          'createdBy': createdBy,
          'requestPlatform': requestPlatform,
          'estimatedDuration': durationStr,
        },
        options: await _buildOptions(),
      );
      return response.data.toString();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<List<ReservedAppointmentModel>> getCustomerAppointments(
    String customerId, {
    int page = 1,
    int pageSize = 50,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'Page': page,
        'PageSize': pageSize,
        'IncludeStaffObject': true,
        'IncludeServiceObject': true,
        'IncludeBranchObject': true,
        'IncludeCustomerObject': true,
      };
      if (status != null && status.isNotEmpty) {
        queryParams['CustomerStatus'] = [status];
      }

      final response = await dio.get(
        EndPoints.customerAppointmentsUrl(customerId),
        queryParameters: queryParams,
        options: await _buildOptions(),
      );

      final data = response.data;
      debugPrint('=== GET /customers/$customerId RAW RESPONSE ===');
      debugPrint(const JsonEncoder.withIndent('  ').convert(data));
      debugPrint('===============================================');

      if (data is! Map<String, dynamic>) return [];

      final items = data['items'] as List? ?? [];
      return items
          .map((e) =>
              ReservedAppointmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<String?> getStaffName(String staffId) async {
    try {
      final response = await dio.get(
        EndPoints.staffsUrl,
        queryParameters: {'StaffId': staffId, 'PageSize': 1},
        options: await _buildOptions(),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final items = data['items'] as List? ?? [];
      if (items.isEmpty) return null;
      final first = items.first as Map<String, dynamic>;
      final fName = first['firstName'] as String? ?? '';
      final lName = first['lastName'] as String? ?? '';
      final name = '$fName $lName'.trim();
      return name.isEmpty ? null : name;
    } on DioException {
      return null;
    }
  }

  @override
  Future<Map<String, String?>> getBranchInfo(String branchId) async {
    try {
      final response = await dio.get(
        EndPoints.branchDetailsUrl(branchId),
        options: await _buildOptions(),
      );
      final data = response.data as Map<String, dynamic>?;
      if (data == null) return {'address': null, 'organizationName': null};
      return {
        'address': data['address'] as String?,
        'organizationName': data['organizationName'] as String?,
      };
    } on DioException {
      return {'address': null, 'organizationName': null};
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await dio.patch(
        EndPoints.cancelAppointmentUrl(appointmentId),
        options: await _buildOptions(),
      );
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:00';
  }
}
