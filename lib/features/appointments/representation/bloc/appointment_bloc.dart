import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/appointments/domain/entities/available_slot.dart';
import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';
import 'package:viora_app/features/appointments/domain/entities/staff_day_schedule.dart';
import 'package:viora_app/features/appointments/domain/usecases/book_appointment.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_doctor_appointments.dart';
import 'package:viora_app/features/appointments/domain/usecases/get_staff_schedule.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_event.dart';
import 'package:viora_app/features/appointments/representation/bloc/appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetDoctorAppointmentsUseCase getDoctorAppointments;
  final GetDoctorDayShiftUseCase getStaffSchedule;
  final BookAppointmentUseCase bookAppointment;
  int _serviceDurationMinutes = 0;

  AppointmentBloc({
    required this.getDoctorAppointments,
    required this.getStaffSchedule,
    required this.bookAppointment,
  }) : super(const AppointmentInitial()) {
    on<LoadDoctorAppointments>(_onLoadDoctorAppointments);
    on<SetAppointmentTime>(_onSetAppointmentTime);
    on<ConfirmBooking>(_onConfirmBooking);
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

  Future<void> _onLoadDoctorAppointments(
    LoadDoctorAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    _serviceDurationMinutes = event.serviceDurationMinutes;
    emit(const AppointmentsLoading());

    final results = await Future.wait([
      getDoctorAppointments(
        doctorId: event.staffId,
        date: event.selectedDate,
      ),
      getStaffSchedule(
        branchId: event.branchId,
        staffId: event.staffId,
      ),
    ]);

    final appointmentsResult =
        results[0] as Either<Failure, List<ReservedAppointment>>;
    final scheduleResult =
        results[1] as Either<Failure, List<StaffDaySchedule>>;

    String? shiftStart;
    String? shiftEnd;

    if (scheduleResult.isRight()) {
      final dayName = _getDayName(event.selectedDate.weekday);
      final schedules = scheduleResult.getOrElse(() => []);
      final daySchedule = schedules.where(
        (s) => s.day.toLowerCase() == dayName.toLowerCase(),
      );
      if (daySchedule.isNotEmpty) {
        final s = daySchedule.first;
        shiftStart = s.startTime;
        shiftEnd = s.endTime;
      }
    }

    final availableSlots = _generateAvailableSlots(
      shiftStart: shiftStart,
      shiftEnd: shiftEnd,
      selectedDate: event.selectedDate,
      serviceDurationMinutes: _serviceDurationMinutes,
      reservedAppointments: appointmentsResult.getOrElse(() => []),
    );

    appointmentsResult.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (appointments) => emit(DoctorAppointmentsLoaded(
        reservedAppointments: appointments,
        selectedDate: event.selectedDate,
        shiftStartTime: shiftStart,
        shiftEndTime: shiftEnd,
        availableSlots: availableSlots,
      )),
    );
  }

  void _onSetAppointmentTime(
    SetAppointmentTime event,
    Emitter<AppointmentState> emit,
  ) {
    final current = state;
    if (current is! DoctorAppointmentsLoaded) return;

    final endTime =
        event.startTime.add(Duration(minutes: _serviceDurationMinutes));
    String? conflictMessage;

    for (final apt in current.reservedAppointments) {
      final blockedEnd = apt.reservationDate.add(
        Duration(minutes: _serviceDurationMinutes),
      );
      if (event.startTime.isBefore(blockedEnd) &&
          endTime.isAfter(apt.reservationDate)) {
        conflictMessage =
            'This time conflicts with an existing appointment (${_formatTime(apt.reservationDate)} - ${_formatTime(blockedEnd)}). Please choose a different time.';
        break;
      }
    }

    emit(current.copyWith(
      manualStartTime: event.startTime,
      calculatedEndTime: endTime,
      conflictMessage: conflictMessage,
    ));
  }

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<AppointmentState> emit,
  ) async {
    final current = state;
    if (current is! DoctorAppointmentsLoaded || current.manualStartTime == null) {
      return;
    }
    if (current.conflictMessage != null) return;

    emit(current.copyWith(isBooking: true));

    final result = await bookAppointment(
      serviceId: event.serviceId,
      staffId: event.staffId,
      branchId: event.branchId,
      reservationDate: current.manualStartTime!,
      durationMinutes: event.durationMinutes,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (appointmentId) => emit(BookingSuccess(appointmentId: appointmentId)),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<AvailableSlot> _generateAvailableSlots({
    required String? shiftStart,
    required String? shiftEnd,
    required DateTime selectedDate,
    required int serviceDurationMinutes,
    required List<ReservedAppointment> reservedAppointments,
  }) {
    if (shiftStart == null || shiftEnd == null) return [];

    final start = _parseTime(shiftStart, selectedDate);
    final end = _parseTime(shiftEnd, selectedDate);
    final duration = Duration(minutes: serviceDurationMinutes);
    final slots = <AvailableSlot>[];

    var current = start;
    while (!current.add(duration).isAfter(end)) {
      final slotEnd = current.add(duration);

      var isReserved = false;
      for (final apt in reservedAppointments) {
        final blockedEnd = apt.reservationDate.add(duration);
        if (current.isBefore(blockedEnd) &&
            slotEnd.isAfter(apt.reservationDate)) {
          isReserved = true;
          break;
        }
      }

      if (!isReserved) {
        slots.add(AvailableSlot(startTime: current, endTime: slotEnd));
      }

      current = current.add(const Duration(minutes: 10));
    }

    return slots;
  }

  DateTime _parseTime(String time, DateTime date) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}
