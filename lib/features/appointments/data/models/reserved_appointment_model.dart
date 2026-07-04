import 'package:viora_app/features/appointments/domain/entities/reserved_appointment.dart';

class ReservedAppointmentModel {
  final String appointmentId;
  final String serviceId;
  final String? customerId;
  final String staffId;
  final String branchId;
  final String? paymentId;
  final DateTime reservationDate;
  final String paymentMethod;
  final String status;
  final String estimatedDuration;
  final String? customerName;
  final String? serviceName;
  String? staffName;
  String? branchName;
  String? organizationName;
  final String? cost;

  ReservedAppointmentModel({
    required this.appointmentId,
    required this.serviceId,
    required this.staffId,
    required this.branchId,
    required this.reservationDate,
    required this.paymentMethod,
    required this.status,
    required this.estimatedDuration,
    this.customerId,
    this.paymentId,
    this.customerName,
    this.serviceName,
    this.staffName,
    this.branchName,
    this.organizationName,
    this.cost,
  });

  factory ReservedAppointmentModel.fromJson(Map<String, dynamic> json) {
    final estDur = json['estimatedDuration'] as String? ?? '00:00:00';
    return ReservedAppointmentModel(
      appointmentId: json['appointmentId'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      customerId: json['customerId'] as String?,
      staffId: json['staffId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      paymentId: json['paymentId'] as String?,
      reservationDate:
          DateTime.tryParse(json['reservationDate'] as String? ?? '') ??
              DateTime.now(),
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      status: json['status'] as String? ?? 'NotArrived',
      estimatedDuration: estDur,
      customerName: json['customerName'] as String?,
      serviceName: json['serviceName'] as String?,
      staffName: _nullIfEmpty(json['staffName'] as String?),
      branchName: json['branchName'] as String?,
      organizationName: json['organizationName'] as String?,
      cost: json['cost'] as String?,
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
      serviceId: serviceId,
      staffId: staffId,
      branchId: branchId,
      reservationDate: reservationDate,
      paymentMethod: paymentMethod,
      status: status,
      estimatedDuration: duration,
      customerName: customerName,
      serviceName: serviceName,
      staffName: staffName,
      branchName: branchName,
      organizationName: organizationName,
      cost: cost,
    );
  }

  static String? _nullIfEmpty(String? value) =>
      (value == null || value.isEmpty) ? null : value;
}
