import 'package:equatable/equatable.dart';

class ReservedAppointment extends Equatable {
  final String id;
  final DateTime reservationDate;
  final Duration estimatedDuration;
  final String? customerName;
  final String? serviceName;

  const ReservedAppointment({
    required this.id,
    required this.reservationDate,
    required this.estimatedDuration,
    this.customerName,
    this.serviceName,
  });

  DateTime get endTime => reservationDate.add(estimatedDuration);

  @override
  List<Object?> get props => [id, reservationDate, estimatedDuration];
}
