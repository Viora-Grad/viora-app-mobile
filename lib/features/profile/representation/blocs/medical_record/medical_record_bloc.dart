import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';
import 'package:viora_app/features/profile/domain/usecases/create_medical_record_usecase.dart';
import 'package:viora_app/features/profile/domain/usecases/get_medical_record_usecase.dart';
import 'package:viora_app/features/profile/domain/usecases/update_medical_record_usecase.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_event.dart';
import 'package:viora_app/features/profile/representation/blocs/medical_record/medical_record_state.dart';

class MedicalRecordBloc
    extends Bloc<MedicalRecordEvent, MedicalRecordState> {
  final GetMedicalRecordUseCase getMedicalRecord;
  final CreateMedicalRecordUseCase createMedicalRecord;
  final UpdateMedicalRecordUseCase updateMedicalRecord;

  MedicalRecordBloc({
    required this.getMedicalRecord,
    required this.createMedicalRecord,
    required this.updateMedicalRecord,
  }) : super(const MedicalRecordState()) {
    on<LoadMedicalRecord>(_onLoad);
    on<CreateMedicalRecordEvent>(_onCreate);
    on<UpdateMedicalRecordEvent>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadMedicalRecord event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(state.copyWith(status: MedicalRecordStatus.loading));
    final result = await getMedicalRecord();
    result.fold(
      (failure) =>
          emit(state.copyWith(status: MedicalRecordStatus.failure, error: failure.message)),
      (record) =>
          emit(state.copyWith(status: MedicalRecordStatus.success, record: record)),
    );
  }

  Future<void> _onCreate(
    CreateMedicalRecordEvent event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(state.copyWith(status: MedicalRecordStatus.loading));
    final result = await createMedicalRecord(
      systolic: event.systolic,
      diastolic: event.diastolic,
      weight: event.weight,
      heartRate: event.heartRate,
      bloodGlucose: event.bloodGlucose,
      allergies: event.allergies,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(status: MedicalRecordStatus.failure, error: failure.message)),
      (id) => emit(state.copyWith(
        status: MedicalRecordStatus.saved,
        record: MedicalRecord(
          id: id,
          systolic: event.systolic,
          diastolic: event.diastolic,
          weight: event.weight,
          heartRate: event.heartRate,
          bloodGlucose: event.bloodGlucose,
          allergies: event.allergies,
        ),
      )),
    );
  }

  Future<void> _onUpdate(
    UpdateMedicalRecordEvent event,
    Emitter<MedicalRecordState> emit,
  ) async {
    emit(state.copyWith(status: MedicalRecordStatus.loading));
    final result = await updateMedicalRecord(
      systolic: event.systolic,
      diastolic: event.diastolic,
      weight: event.weight,
      heartRate: event.heartRate,
      bloodGlucose: event.bloodGlucose,
      allergies: event.allergies,
    );
    final existing = state.record;
    result.fold(
      (failure) =>
          emit(state.copyWith(status: MedicalRecordStatus.failure, error: failure.message)),
      (_) => emit(state.copyWith(
        status: MedicalRecordStatus.saved,
        record: MedicalRecord(
          id: existing?.id ?? '',
          systolic: event.systolic ?? existing?.systolic ?? 0,
          diastolic: event.diastolic ?? existing?.diastolic ?? 0,
          weight: event.weight ?? existing?.weight ?? 0,
          heartRate: event.heartRate ?? existing?.heartRate ?? 0,
          bloodGlucose: event.bloodGlucose ?? existing?.bloodGlucose ?? 0,
          allergies: event.allergies ?? existing?.allergies ?? [],
        ),
      )),
    );
  }
}
