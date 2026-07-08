import 'package:equatable/equatable.dart';

abstract class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrescription extends PrescriptionEvent {
  final String appointmentId;

  const LoadPrescription(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}
