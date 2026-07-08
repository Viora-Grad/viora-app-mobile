import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  final String id;
  final int systolic;
  final int diastolic;
  final double weight;
  final int heartRate;
  final int bloodGlucose;
  final List<String> allergies;

  const MedicalRecord({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.heartRate,
    required this.bloodGlucose,
    this.allergies = const [],
  });

  @override
  List<Object?> get props => [
    id,
    systolic,
    diastolic,
    weight,
    heartRate,
    bloodGlucose,
    allergies,
  ];
}
