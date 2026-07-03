import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';
import 'package:viora_app/features/appointments/domain/repositories/appointment_repository.dart';

class GetAvailableSlotsUseCase {
  final AppointmentRepository repository;

  GetAvailableSlotsUseCase(this.repository);

  Future<Either<Failure, List<AvailableSlot>>> call({
    required String branchId,
    required String staffId,
    required String serviceId,
    required int serviceDurationMinutes,
    required DateTime selectedDate,
  }) async {
    final dayName = _getDayName(selectedDate.weekday);

    final scheduleResult =
        await repository.getStaffSchedule(branchId, staffId);
    if (scheduleResult.isLeft()) {
      return scheduleResult.fold(
        (failure) => Left(failure),
        (_) => const Right([]),
      );
    }

    final schedules = scheduleResult.getOrElse(() => []);
    final daySchedule = schedules.where(
      (s) => s.day.toLowerCase() == dayName.toLowerCase(),
    );

    if (daySchedule.isEmpty) {
      return const Right([]);
    }

    final appointmentsResult =
        await repository.getDoctorAppointments(staffId, selectedDate);
    if (appointmentsResult.isLeft()) {
      return appointmentsResult.fold(
        (failure) => Left(failure),
        (_) => const Right([]),
      );
    }

    final appointments = appointmentsResult.getOrElse(() => []);

    // Convert UTC reservation dates to local time so they compare
    // correctly with the local-time candidate slots
    final localAppointments = appointments.map((a) => ReservedAppointment(
      id: a.id,
      reservationDate: a.reservationDate.toLocal(),
      estimatedDuration: a.estimatedDuration,
      customerName: a.customerName,
      serviceName: a.serviceName,
    )).toList();

    final allSlots = <AvailableSlot>[];
    for (final schedule in daySchedule) {
      final slots = _computeSlots(
        schedule,
        serviceDurationMinutes,
        localAppointments,
        selectedDate,
      );
      allSlots.addAll(slots);
    }

    return Right(allSlots);
  }

  List<AvailableSlot> _computeSlots(
    StaffDaySchedule schedule,
    int durationMinutes,
    List<ReservedAppointment> reserved,
    DateTime date,
  ) {
    final shiftStart = _parseTime(schedule.startTime);
    final shiftEnd = _parseTime(schedule.endTime);

    if (shiftStart == null || shiftEnd == null) return [];

    final slotDuration = Duration(minutes: durationMinutes);
    final slots = <AvailableSlot>[];

    var current = DateTime(
      date.year,
      date.month,
      date.day,
      shiftStart.hour,
      shiftStart.minute,
    );

    final endBoundary = DateTime(
      date.year,
      date.month,
      date.day,
      shiftEnd.hour,
      shiftEnd.minute,
    );

    while (current.add(slotDuration).isBefore(endBoundary) ||
        current.add(slotDuration).isAtSameMomentAs(endBoundary)) {
      final slotEnd = current.add(slotDuration);

      if (!_isReserved(current, slotEnd, reserved)) {
        slots.add(AvailableSlot(startTime: current, endTime: slotEnd));
      }

      current = slotEnd;
    }

    return slots;
  }

  bool _isReserved(
    DateTime slotStart,
    DateTime slotEnd,
    List<ReservedAppointment> reserved,
  ) {
    for (final r in reserved) {
      if (slotStart.isBefore(r.endTime) && slotEnd.isAfter(r.reservationDate)) {
        return true;
      }
    }
    return false;
  }

  DateTime? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(2000, 1, 1, hour, minute);
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}
