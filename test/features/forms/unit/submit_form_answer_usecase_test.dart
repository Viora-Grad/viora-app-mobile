import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:viora_app/core/errors/failure.dart';
import 'package:viora_app/features/forms/domain/entities/form_entity.dart';
import 'package:viora_app/features/forms/domain/repositories/form_repository.dart';
import 'package:viora_app/features/forms/domain/usecases/submit_form_answer.dart';

class MockFormRepository extends Mock implements FormRepository {}

void main() {
  late MockFormRepository mockRepo;
  late SubmitFormAnswerUseCase subject;

  setUp(() {
    mockRepo = MockFormRepository();
    subject = SubmitFormAnswerUseCase(mockRepo);
  });

  test('returns validation failure when appointmentId empty', () async {
    final res = await subject.call(appointmentId: '', formId: 'f', answers: [AnswerData(id: 'a', type: 't', answer: 'x')]);
    expect(res.isLeft(), isTrue);
    res.fold((l) => expect(l, isA<ValidationFailure>()), (_) {});
  });

  test('returns validation failure when formId empty', () async {
    final res = await subject.call(appointmentId: 'a', formId: '', answers: [AnswerData(id: 'a', type: 't', answer: 'x')]);
    expect(res.isLeft(), isTrue);
    res.fold((l) => expect(l, isA<ValidationFailure>()), (_) {});
  });

  test('returns validation failure when answers empty', () async {
    final res = await subject.call(appointmentId: 'a', formId: 'f', answers: []);
    expect(res.isLeft(), isTrue);
    res.fold((l) => expect(l, isA<ValidationFailure>()), (_) {});
  });

  test('delegates to repository on valid input', () async {
    when(() => mockRepo.submitFormAnswers(appointmentId: any(named: 'appointmentId'), formId: any(named: 'formId'), answers: any(named: 'answers')))
        .thenAnswer((_) async => const Right('submission-id'));

    final res = await subject.call(appointmentId: 'a', formId: 'f', answers: [AnswerData(id: 'a', type: 't', answer: 'x')]);

    expect(res.isRight(), isTrue);
    res.fold((_) {}, (r) => expect(r, equals('submission-id')));
    verify(() => mockRepo.submitFormAnswers(appointmentId: 'a', formId: 'f', answers: any(named: 'answers'))).called(1);
  });
}
