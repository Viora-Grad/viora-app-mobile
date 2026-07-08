import 'package:equatable/equatable.dart';

abstract class MedicalRecordEvent extends Equatable {
  const MedicalRecordEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicalRecord extends MedicalRecordEvent {}

class CreateMedicalRecordEvent extends MedicalRecordEvent {
  final int systolic;
  final int diastolic;
  final double weight;
  final int heartRate;
  final int bloodGlucose;
  final List<String> allergies;

  const CreateMedicalRecordEvent({
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.heartRate,
    required this.bloodGlucose,
    required this.allergies,
  });

  @override
  List<Object?> get props => [
    systolic,
    diastolic,
    weight,
    heartRate,
    bloodGlucose,
    allergies,
  ];
}

class UpdateMedicalRecordEvent extends MedicalRecordEvent {
  final int? systolic;
  final int? diastolic;
  final double? weight;
  final int? heartRate;
  final int? bloodGlucose;
  final List<String>? allergies;

  const UpdateMedicalRecordEvent({
    this.systolic,
    this.diastolic,
    this.weight,
    this.heartRate,
    this.bloodGlucose,
    this.allergies,
  });

  @override
  List<Object?> get props => [
    systolic,
    diastolic,
    weight,
    heartRate,
    bloodGlucose,
    allergies,
  ];
}
