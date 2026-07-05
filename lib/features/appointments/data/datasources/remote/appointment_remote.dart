import 'package:viora_app/features/appointments/data/models/reserved_appointment_model.dart';
import 'package:viora_app/features/appointments/data/models/staff_day_schedule_model.dart';
import 'package:viora_app/features/appointments/data/models/staff_day_shift_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<StaffDayScheduleModel>> getStaffSchedule(
    String branchId,
    String staffId,
  );

  Future<List<ReservedAppointmentModel>> getDoctorAppointments(
    String doctorId,
    DateTime date,
  );

  Future<StaffDayShiftModel> getStaffDayShift({
    required String staffId,
    required String shiftId,
    required DateTime day,
  });

  Future<String> createAppointment({
    required String serviceId,
    required String staffId,
    required String branchId,
    required DateTime reservationDate,
    required int durationMinutes,
    required String paymentMethod,
    required String createdBy,
    required String requestPlatform,
  });

  Future<List<ReservedAppointmentModel>> getCustomerAppointments(
    String customerId, {
    int page = 1,
    int pageSize = 50,
    String? status,
  });

  Future<String?> getStaffName(String staffId);

  Future<Map<String, String?>> getBranchInfo(String branchId);
}
