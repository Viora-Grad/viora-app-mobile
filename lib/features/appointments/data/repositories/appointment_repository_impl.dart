import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/data/datasources/remote/appointment_remote.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';
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
  Future<Either<Failure, void>> createAppointment({
    required String serviceId,
    required String staffId,
    required String branchId,
    required DateTime reservationDate,
    required int durationMinutes,
    required String paymentMethod,
  }) async {
    try {
      await remoteDataSource.createAppointment(
        serviceId: serviceId,
        staffId: staffId,
        branchId: branchId,
        reservationDate: reservationDate,
        durationMinutes: durationMinutes,
        paymentMethod: paymentMethod,
        createdBy: 'Customer',
        requestPlatform: 'Mobile',
      );
      return const Right(null);
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
