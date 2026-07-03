import 'package:viora_app/features/appointments/data/models/reserved_appointment_model.dart';
import 'package:viora_app/features/appointments/data/models/staff_day_schedule_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<StaffDayScheduleModel>> getStaffSchedule(
    String branchId,
    String staffId,
  );

  Future<List<ReservedAppointmentModel>> getDoctorAppointments(
    String doctorId,
    DateTime date,
  );

  Future<void> createAppointment({
    required String serviceId,
    required String staffId,
    required String branchId,
    required DateTime reservationDate,
    required int durationMinutes,
    required String paymentMethod,
    required String createdBy,
    required String requestPlatform,
  });
}
