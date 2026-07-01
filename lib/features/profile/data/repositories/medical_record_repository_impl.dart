import 'package:dartz/dartz.dart';
import 'package:viora_app/core/errors/error_handler.dart';
import 'package:viora_app/core/errors/exceptions.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/profile/data/datasources/remote/medical_record_remote.dart';
import 'package:viora_app/features/profile/data/models/medical_record_model.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';
import 'package:viora_app/features/profile/domain/repositories/medical_record_repository.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final MedicalRecordRemote remote;

  MedicalRecordRepositoryImpl(this.remote);

  MedicalRecord _toEntity(MedicalRecordModel model) => MedicalRecord(
    id: model.id,
    systolic: model.systolic,
    diastolic: model.diastolic,
    weight: model.weight,
    heartRate: model.heartRate,
    bloodGlucose: model.bloodGlucose,
    allergies: model.allergies,
  );

  @override
  Future<Either<Failure, MedicalRecord>> getMedicalRecord() async {
    try {
      final model = await remote.getMedicalRecord();
      return Right(_toEntity(model));
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> createMedicalRecord({
    required int systolic,
    required int diastolic,
    required double weight,
    required int heartRate,
    required int bloodGlucose,
    required List<String> allergies,
  }) async {
    try {
      final id = await remote.createMedicalRecord(
        systolic: systolic,
        diastolic: diastolic,
        weight: weight,
        heartRate: heartRate,
        bloodGlucose: bloodGlucose,
        allergies: allergies,
      );
      return Right(id);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicalRecord({
    int? systolic,
    int? diastolic,
    double? weight,
    int? heartRate,
    int? bloodGlucose,
    List<String>? allergies,
  }) async {
    try {
      await remote.updateMedicalRecord(
        systolic: systolic,
        diastolic: diastolic,
        weight: weight,
        heartRate: heartRate,
        bloodGlucose: bloodGlucose,
        allergies: allergies,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(handleException(e));
    }
  }
}
