import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';

class ReservedAppointmentModel {
  final String appointmentId;
  final DateTime reservationDate;
  final String estimatedDuration;
  final String? customerName;
  final String? serviceName;

  const ReservedAppointmentModel({
    required this.appointmentId,
    required this.reservationDate,
    required this.estimatedDuration,
    this.customerName,
    this.serviceName,
  });

  factory ReservedAppointmentModel.fromJson(Map<String, dynamic> json) {
    final estDur = json['estimatedDuration'] as String? ?? '00:00:00';
    return ReservedAppointmentModel(
      appointmentId: json['appointmentId'] as String? ?? '',
      reservationDate: DateTime.tryParse(json['reservationDate'] as String? ?? '') ?? DateTime.now(),
      estimatedDuration: estDur,
      customerName: json['customerName'] as String?,
      serviceName: json['serviceName'] as String?,
    );
  }

  ReservedAppointment toEntity() {
    final parts = estimatedDuration.split(':');
    final duration = Duration(
      hours: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      minutes: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      seconds: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
    );
    return ReservedAppointment(
      id: appointmentId,
      reservationDate: reservationDate,
      estimatedDuration: duration,
      customerName: customerName,
      serviceName: serviceName,
    );
  }
}
