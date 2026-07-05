import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/data/datasources/remote/appointment_remote.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_shift.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<StaffDaySchedule>>> getStaffSchedule(
    String branchId,
    String staffId,
  ) async {
    try {
      final models = await remoteDataSource.getStaffSchedule(branchId, staffId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<ReservedAppointment>>> getDoctorAppointments(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final models =
          await remoteDataSource.getDoctorAppointments(doctorId, date);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, StaffDayShift>> getStaffDayShift({
    required String staffId,
    required String shiftId,
    required DateTime day,
  }) async {
    try {
      final model = await remoteDataSource.getStaffDayShift(
        staffId: staffId,
        shiftId: shiftId,
        day: day,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> createAppointment({
    required String serviceId,
    required String staffId,
    required String branchId,
    required DateTime reservationDate,
    required int durationMinutes,
    required String paymentMethod,
  }) async {
    try {
      final appointmentId = await remoteDataSource.createAppointment(
        serviceId: serviceId,
        staffId: staffId,
        branchId: branchId,
        reservationDate: reservationDate,
        durationMinutes: durationMinutes,
        paymentMethod: paymentMethod,
        createdBy: 'Customer',
        requestPlatform: 'Mobile',
      );
      return Right(appointmentId);
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<ReservedAppointment>>> getCustomerAppointments(
    String customerId, {
    String? status,
  }) async {
    try {
      final models = await remoteDataSource.getCustomerAppointments(
        customerId,
        status: status,
      );

      final uniqueBranchIds = models
          .map((m) => m.branchId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final uniqueStaffIds = models
          .map((m) => m.staffId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final branchInfoMap = <String, Map<String, String?>>{};
      for (final id in uniqueBranchIds) {
        branchInfoMap[id] = await remoteDataSource.getBranchInfo(id);
      }

      final staffNameMap = <String, String?>{};
      for (final id in uniqueStaffIds) {
        staffNameMap[id] = await remoteDataSource.getStaffName(id);
      }

      for (final model in models) {
        final info = branchInfoMap[model.branchId];
        if (info != null) {
          if ((model.branchName == null || model.branchName!.isEmpty) &&
              info['address'] != null) {
            model.branchName = info['address'];
          }
          if (info['organizationName'] != null) {
            model.organizationName = info['organizationName'];
          }
        }
        final staffName = staffNameMap[model.staffId];
        if (staffName != null) {
          model.staffName = staffName;
        }
      }

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
