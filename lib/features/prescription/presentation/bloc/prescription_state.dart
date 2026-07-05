import 'package:equatable/equatable.dart';
import 'package:viora_app/features/prescription/domain/entities/prescription.dart';

abstract class PrescriptionState extends Equatable {
  const PrescriptionState();

  @override
  List<Object?> get props => [];
}

class PrescriptionInitial extends PrescriptionState {}

class PrescriptionLoading extends PrescriptionState {}

class PrescriptionError extends PrescriptionState {
  final String message;

  const PrescriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class PrescriptionLoaded extends PrescriptionState {
  final Prescription prescription;

  const PrescriptionLoaded(this.prescription);

  @override
  List<Object?> get props => [prescription];
}
