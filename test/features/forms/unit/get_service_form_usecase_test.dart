import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';
import 'package:viora_app/features/forms/domain/usecases/get_service_form.dart';

class MockFormRepository extends Mock implements FormRepository {}

void main() {
  late MockFormRepository mockRepo;
  late GetServiceFormUseCase subject;

  setUp(() {
    mockRepo = MockFormRepository();
    subject = GetServiceFormUseCase(mockRepo);
  });

  test('returns validation failure when serviceId empty', () async {
    final res = await subject.call('');
    expect(res.isLeft(), isTrue);
    res.fold((l) => expect(l, isA<ValidationFailure>()), (_) {});
  });

  test('delegates to repository when serviceId provided', () async {
    final form = FormEntity(id: 'f', staffId: 's', serviceId: 'sv', name: 'n', questions: []);
    when(() => mockRepo.getServiceForm(any())).thenAnswer((_) async => Right(form));

    final res = await subject.call('sv');
    expect(res.isRight(), isTrue);
    res.fold((_) {}, (r) => expect(r, equals(form)));
    verify(() => mockRepo.getServiceForm('sv')).called(1);
  });
}
