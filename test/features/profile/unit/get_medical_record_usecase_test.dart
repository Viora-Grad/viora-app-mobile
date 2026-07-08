import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/features/profile/domain/entities/medical_record.dart';
import 'package:viora_app/features/profile/domain/repositories/medical_record_repository.dart';
import 'package:viora_app/features/profile/domain/usecases/get_medical_record_usecase.dart';

class MockMedicalRecordRepository extends Mock implements MedicalRecordRepository {}

void main() {
  late MockMedicalRecordRepository mockRepo;
  late GetMedicalRecordUseCase subject;

  setUp(() {
    mockRepo = MockMedicalRecordRepository();
    subject = GetMedicalRecordUseCase(mockRepo);
  });

  test('delegates to repository and returns medical record', () async {
    final record = MedicalRecord(id: 'r1', systolic: 120, diastolic: 80, weight: 70.0, heartRate: 72, bloodGlucose: 90, allergies: []);
    when(() => mockRepo.getMedicalRecord()).thenAnswer((_) async => Right(record));

    final res = await subject.call();
    expect(res.isRight(), isTrue);
    res.fold((_) {}, (r) => expect(r, equals(record)));
    verify(() => mockRepo.getMedicalRecord()).called(1);
  });
}
