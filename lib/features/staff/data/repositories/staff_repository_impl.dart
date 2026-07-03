import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:viora_app/core/api/end_points.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/staff/data/datasources/remote/staff_remote.dart';
import 'package:viora_app/features/staff/data/models/staff_shift_model.dart';
import 'package:viora_app/features/staff/domain/entities/staff.dart';
import 'package:viora_app/features/staff/domain/entities/staff_shift.dart';
import 'package:viora_app/features/staff/domain/repositories/staff_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  StaffRepositoryImpl(this.remoteDataSource, this.dio, this.secureStorage);

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
  Future<Either<Failure, List<Staff>>> getStaffByBranchService(
    String branchId,
    String serviceId,
  ) async {
    try {
      final models = await remoteDataSource.getStaffByBranchService(
        branchId,
        serviceId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<StaffShift>>> getBranchSchedule(
    String branchId,
  ) async {
    try {
      final response = await dio.get(
        EndPoints.branchScheduleUrl(branchId),
        options: await _buildOptions(),
      );

      final data = response.data;
      if (data is! List) {
        return const Right([]);
      }

      final shifts = <StaffShift>[];
      for (final dayEntry in data) {
        if (dayEntry is! Map<String, dynamic>) continue;
        final day = dayEntry['day'] as String? ?? '';
        final shiftList = dayEntry['shifts'] as List? ?? [];
        for (final s in shiftList) {
          if (s is! Map<String, dynamic>) continue;
          shifts.add(
            StaffShiftModel.fromJson({
              ...s,
              'day': day,
            }).toEntity(),
          );
        }
      }
      return Right(shifts);
    } on DioException catch (e) {
      return Left(handleException(e));
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
