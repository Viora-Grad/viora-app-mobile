import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<StaffDaySchedule>>> getStaffSchedule(
    String branchId,
    String staffId,
  );

  Future<Either<Failure, List<ReservedAppointment>>> getDoctorAppointments(
    String doctorId,
    DateTime date,
  );

  Future<Either<Failure, void>> createAppointment({
    required String serviceId,
    required String staffId,
    required String branchId,
    required DateTime reservationDate,
    required int durationMinutes,
    required String paymentMethod,
  });

  Future<Either<Failure, List<ReservedAppointment>>> getCustomerAppointments(
    String customerId, {
    String? status,
  });
}
