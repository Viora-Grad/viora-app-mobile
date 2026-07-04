import 'package:equatable/equatable.dart';

class ReservedAppointment extends Equatable {
  final String id;
  final String serviceId;
  final String staffId;
  final String branchId;
  final DateTime reservationDate;
  final String paymentMethod;
  final String status;
  final Duration estimatedDuration;
  final String? customerName;
  final String? serviceName;
  final String? staffName;
  final String? branchName;
  final String? organizationName;
  final String? cost;

  const ReservedAppointment({
    required this.id,
    required this.serviceId,
    required this.staffId,
    required this.branchId,
    required this.reservationDate,
    required this.paymentMethod,
    required this.status,
    required this.estimatedDuration,
    this.customerName,
    this.serviceName,
    this.staffName,
    this.branchName,
    this.organizationName,
    this.cost,
  });

  DateTime get endTime => reservationDate.add(estimatedDuration);

  @override
  List<Object?> get props => [
        id,
        reservationDate,
        estimatedDuration,
        status,
        branchId,
        staffId,
        serviceId,
      ];
}
