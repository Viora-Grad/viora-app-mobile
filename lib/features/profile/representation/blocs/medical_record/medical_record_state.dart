import 'package:equatable/equatable.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';

enum MedicalRecordStatus { initial, loading, success, failure, saved }

class MedicalRecordState extends Equatable {
  final MedicalRecordStatus status;
  final MedicalRecord? record;
  final String? error;

  const MedicalRecordState({
    this.status = MedicalRecordStatus.initial,
    this.record,
    this.error,
  });

  MedicalRecordState copyWith({
    MedicalRecordStatus? status,
    MedicalRecord? record,
    String? error,
  }) {
    return MedicalRecordState(
      status: status ?? this.status,
      record: record ?? this.record,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, record, error];
}
